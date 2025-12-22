#!/bin/bash
# AWS Cleanup Script

echo "Cleaning up AWS resources..."

PROJECT_NAME="blog-app"

# Delete Auto Scaling Group
echo "Deleting Auto Scaling Group..."
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $PROJECT_NAME-asg --force-delete || true

# Wait for instances to terminate
sleep 30

# Delete Launch Template
echo "Deleting Launch Template..."
aws ec2 delete-launch-template --launch-template-name $PROJECT_NAME-template || true

# Delete Load Balancer
echo "Deleting Load Balancer..."
ALB_ARN=$(aws elbv2 describe-load-balancers --names $PROJECT_NAME-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null)
if [ "$ALB_ARN" != "None" ]; then
    aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
    sleep 30
fi

# Delete Target Group
echo "Deleting Target Group..."
TG_ARN=$(aws elbv2 describe-target-groups --names $PROJECT_NAME-tg --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null)
if [ "$TG_ARN" != "None" ]; then
    aws elbv2 delete-target-group --target-group-arn $TG_ARN || true
fi

# Delete RDS Instance
echo "Deleting RDS Database..."
aws rds delete-db-instance --db-instance-identifier $PROJECT_NAME-db --skip-final-snapshot || true

# Delete DB Subnet Group
aws rds delete-db-subnet-group --db-subnet-group-name $PROJECT_NAME-db-subnet-group || true

# Delete Security Groups
echo "Deleting Security Groups..."
sleep 60  # Wait for resources to detach

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$PROJECT_NAME-vpc" --query 'Vpcs[0].VpcId' --output text)

for sg in $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text); do
    aws ec2 delete-security-group --group-id $sg || true
done

# Delete Subnets
echo "Deleting Subnets..."
for subnet in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text); do
    aws ec2 delete-subnet --subnet-id $subnet || true
done

# Detach and Delete Internet Gateway
echo "Deleting Internet Gateway..."
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text)
if [ "$IGW_ID" != "None" ]; then
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID || true
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID || true
fi

# Delete Route Tables
echo "Deleting Route Tables..."
for rtb in $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text); do
    aws ec2 delete-route-table --route-table-id $rtb || true
done

# Delete VPC
echo "Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID || true

# Delete Key Pair
echo "Deleting Key Pair..."
aws ec2 delete-key-pair --key-name blog-app-key || true
rm -f blog-app-key.pem

echo "Cleanup complete!"
