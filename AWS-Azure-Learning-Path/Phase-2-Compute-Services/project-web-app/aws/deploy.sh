#!/bin/bash
# AWS Deployment Script for Phase 2 Project
# Blog Application with Auto Scaling

set -e

echo "==================================="
echo "AWS Blog App Deployment"
echo "==================================="

# Variables
PROJECT_NAME="blog-app"
REGION="${AWS_REGION:-us-east-1}"
VPC_CIDR="10.0.0.0/16"
SUBNET1_CIDR="10.0.1.0/24"
SUBNET2_CIDR="10.0.2.0/24"
DB_NAME="blogdb"
DB_USER="blogadmin"
DB_PASSWORD="BlogSecure123!"  # Change in production!
INSTANCE_TYPE="t2.micro"
KEY_NAME="blog-app-key"

echo "Region: $REGION"
echo "Project: $PROJECT_NAME"

# Step 1: Create VPC
echo ""
echo "Step 1: Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --region $REGION \
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$PROJECT_NAME-vpc}]" \
    --query 'Vpc.VpcId' \
    --output text)

echo "Created VPC: $VPC_ID"

# Enable DNS
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames

# Step 2: Create Internet Gateway
echo ""
echo "Step 2: Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$PROJECT_NAME-igw}]" \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
echo "Created IGW: $IGW_ID"

# Step 3: Create Subnets
echo ""
echo "Step 3: Creating Subnets..."
SUBNET1_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $SUBNET1_CIDR \
    --availability-zone ${REGION}a \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$PROJECT_NAME-subnet-1}]" \
    --query 'Subnet.SubnetId' \
    --output text)

SUBNET2_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $SUBNET2_CIDR \
    --availability-zone ${REGION}b \
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$PROJECT_NAME-subnet-2}]" \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Created Subnets: $SUBNET1_ID, $SUBNET2_ID"

# Step 4: Create Route Table
echo ""
echo "Step 4: Creating Route Table..."
RTB_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$PROJECT_NAME-rtb}]" \
    --query 'RouteTable.RouteTableId' \
    --output text)

aws ec2 create-route --route-table-id $RTB_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --route-table-id $RTB_ID --subnet-id $SUBNET1_ID
aws ec2 associate-route-table --route-table-id $RTB_ID --subnet-id $SUBNET2_ID

echo "Created Route Table: $RTB_ID"

# Step 5: Create Security Groups
echo ""
echo "Step 5: Creating Security Groups..."

# ALB Security Group
ALB_SG_ID=$(aws ec2 create-security-group \
    --group-name $PROJECT_NAME-alb-sg \
    --description "Security group for ALB" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

aws ec2 authorize-security-group-ingress --group-id $ALB_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $ALB_SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0

echo "Created ALB Security Group: $ALB_SG_ID"

# Web Server Security Group
WEB_SG_ID=$(aws ec2 create-security-group \
    --group-name $PROJECT_NAME-web-sg \
    --description "Security group for web servers" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID --protocol tcp --port 5000 --source-group $ALB_SG_ID
aws ec2 authorize-security-group-ingress --group-id $WEB_SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

echo "Created Web Security Group: $WEB_SG_ID"

# Database Security Group
DB_SG_ID=$(aws ec2 create-security-group \
    --group-name $PROJECT_NAME-db-sg \
    --description "Security group for database" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

aws ec2 authorize-security-group-ingress --group-id $DB_SG_ID --protocol tcp --port 5432 --source-group $WEB_SG_ID

echo "Created DB Security Group: $DB_SG_ID"

# Step 6: Create DB Subnet Group
echo ""
echo "Step 6: Creating DB Subnet Group..."
aws rds create-db-subnet-group \
    --db-subnet-group-name $PROJECT_NAME-db-subnet-group \
    --db-subnet-group-description "Subnet group for blog database" \
    --subnet-ids $SUBNET1_ID $SUBNET2_ID

# Step 7: Create RDS Database
echo ""
echo "Step 7: Creating RDS Database (this takes 10-15 minutes)..."
aws rds create-db-instance \
    --db-instance-identifier $PROJECT_NAME-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --master-username $DB_USER \
    --master-user-password $DB_PASSWORD \
    --allocated-storage 20 \
    --vpc-security-group-ids $DB_SG_ID \
    --db-subnet-group-name $PROJECT_NAME-db-subnet-group \
    --db-name $DB_NAME \
    --backup-retention-period 7 \
    --no-publicly-accessible \
    --tags "Key=Name,Value=$PROJECT_NAME-db"

echo "Waiting for database to be available..."
aws rds wait db-instance-available --db-instance-identifier $PROJECT_NAME-db

DB_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier $PROJECT_NAME-db \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

echo "Database ready at: $DB_ENDPOINT"

# Step 8: Create Key Pair
echo ""
echo "Step 8: Creating Key Pair..."
if [ ! -f "$KEY_NAME.pem" ]; then
    aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > $KEY_NAME.pem
    chmod 400 $KEY_NAME.pem
    echo "Key pair saved to: $KEY_NAME.pem"
else
    echo "Key pair already exists"
fi

# Step 9: Create Launch Template
echo ""
echo "Step 9: Creating Launch Template..."

# Get latest Amazon Linux 2 AMI
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text)

echo "Using AMI: $AMI_ID"

# Create user data script
cat > /tmp/user-data.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y python3 python3-pip git

# Install application
cd /home/ec2-user
git clone https://github.com/yourusername/blog-app.git || echo "Using local code"

# Copy application code (you'll need to upload this separately)
mkdir -p /home/ec2-user/blog-app
cd /home/ec2-user/blog-app

# Install dependencies
pip3 install flask flask-sqlalchemy flask-login psycopg2-binary gunicorn

# Set environment variables
export DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_ENDPOINT}/${DB_NAME}"
export SECRET_KEY="change-this-in-production"

# Create systemd service
cat > /etc/systemd/system/blog-app.service << 'SEOF'
[Unit]
Description=Blog Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/blog-app
Environment="DATABASE_URL=postgresql://DB_USER:DB_PASSWORD@DB_ENDPOINT/DB_NAME"
Environment="SECRET_KEY=change-this-secret"
ExecStart=/usr/local/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
SEOF

systemctl daemon-reload
systemctl enable blog-app
systemctl start blog-app
EOF

# Replace placeholders in user-data
sed -i "s/DB_USER/$DB_USER/g" /tmp/user-data.sh
sed -i "s/DB_PASSWORD/$DB_PASSWORD/g" /tmp/user-data.sh
sed -i "s/DB_ENDPOINT/$DB_ENDPOINT/g" /tmp/user-data.sh
sed -i "s/DB_NAME/$DB_NAME/g" /tmp/user-data.sh

aws ec2 create-launch-template \
    --launch-template-name $PROJECT_NAME-template \
    --version-description "Version 1" \
    --launch-template-data "{
        \"ImageId\": \"$AMI_ID\",
        \"InstanceType\": \"$INSTANCE_TYPE\",
        \"KeyName\": \"$KEY_NAME\",
        \"SecurityGroupIds\": [\"$WEB_SG_ID\"],
        \"UserData\": \"$(base64 -w 0 /tmp/user-data.sh)\"
    }"

echo "Launch template created"

# Step 10: Create Target Group
echo ""
echo "Step 10: Creating Target Group..."
TG_ARN=$(aws elbv2 create-target-group \
    --name $PROJECT_NAME-tg \
    --protocol HTTP \
    --port 5000 \
    --vpc-id $VPC_ID \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

echo "Target Group ARN: $TG_ARN"

# Step 11: Create Application Load Balancer
echo ""
echo "Step 11: Creating Application Load Balancer..."
ALB_ARN=$(aws elbv2 create-load-balancer \
    --name $PROJECT_NAME-alb \
    --subnets $SUBNET1_ID $SUBNET2_ID \
    --security-groups $ALB_SG_ID \
    --scheme internet-facing \
    --type application \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

echo "Waiting for ALB to be active..."
aws elbv2 wait load-balancer-available --load-balancer-arns $ALB_ARN

ALB_DNS=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns $ALB_ARN \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo "ALB DNS: $ALB_DNS"

# Step 12: Create Listener
echo ""
echo "Step 12: Creating ALB Listener..."
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN

# Step 13: Create Auto Scaling Group
echo ""
echo "Step 13: Creating Auto Scaling Group..."
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name $PROJECT_NAME-asg \
    --launch-template "LaunchTemplateName=$PROJECT_NAME-template,Version=\$Latest" \
    --min-size 2 \
    --max-size 5 \
    --desired-capacity 2 \
    --target-group-arns $TG_ARN \
    --vpc-zone-identifier "$SUBNET1_ID,$SUBNET2_ID" \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --tags "Key=Name,Value=$PROJECT_NAME-instance,PropagateAtLaunch=true"

# Step 14: Create Scaling Policies
echo ""
echo "Step 14: Creating Scaling Policies..."

# Scale up policy
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name $PROJECT_NAME-asg \
    --policy-name scale-up \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration "{
        \"PredefinedMetricSpecification\": {
            \"PredefinedMetricType\": \"ASGAverageCPUUtilization\"
        },
        \"TargetValue\": 70.0
    }"

echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="
echo ""
echo "Application URL: http://$ALB_DNS"
echo "Database Endpoint: $DB_ENDPOINT"
echo "Key Pair: $KEY_NAME.pem"
echo ""
echo "Wait 5-10 minutes for instances to initialize..."
echo ""
echo "Test health check:"
echo "curl http://$ALB_DNS/health"
echo ""
echo "To cleanup resources, run: ./cleanup.sh"
