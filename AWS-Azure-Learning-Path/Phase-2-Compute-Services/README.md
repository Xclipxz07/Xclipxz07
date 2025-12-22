# Phase 2: Compute Services (Beginner-Intermediate)

**Duration**: 3-4 weeks | **Level**: Beginner to Intermediate

---

## 📚 Overview

In Phase 2, you'll learn about cloud compute services - the virtual machines that run your applications. You'll understand how to provision, configure, and manage compute resources on both AWS and Azure.

## 🎯 Learning Objectives

By completing this phase, you will:

- ✅ Understand EC2 and Azure VM fundamentals
- ✅ Choose appropriate instance/VM types
- ✅ Launch and configure virtual machines
- ✅ Set up security groups and network security groups
- ✅ Connect to instances via SSH/RDP
- ✅ Install and configure web servers
- ✅ Implement load balancing
- ✅ Configure auto-scaling
- ✅ Deploy multi-tier applications

## 📖 Curriculum

### Week 1: Virtual Machine Fundamentals

#### Module 1: Introduction to Compute Services
- Understanding virtual machines
- EC2 (Elastic Compute Cloud) overview
- Azure Virtual Machines overview
- Instance types and VM sizes
- Operating system choices
- Pricing models

#### Module 2: Launching Your First Instance
- AWS EC2 launch wizard
- Azure VM creation
- SSH key pairs
- Security groups vs NSGs
- User data / custom scripts
- Connecting to instances

### Week 2: Load Balancing and High Availability

#### Module 3: Load Balancers
- Classic Load Balancer (AWS)
- Application Load Balancer (AWS)
- Network Load Balancer (AWS)
- Azure Load Balancer
- Azure Application Gateway
- Health checks
- Target groups / Backend pools

#### Module 4: Auto-Scaling
- Auto Scaling Groups (AWS)
- VM Scale Sets (Azure)
- Scaling policies
- Launch templates / configurations
- Monitoring metrics

### Week 3-4: Project - Multi-Tier Web Application

#### Module 5: Real-World Deployment
- Architecture design
- Frontend tier setup
- Application tier setup
- Database tier configuration
- Load balancer configuration
- Testing and optimization

---

## 🚀 Project 2: Deploy Web Application with Load Balancer

### Project Description

Deploy a production-ready web application with:
- Load balancer for traffic distribution
- Multiple application servers for high availability
- Auto-scaling for handling traffic spikes
- Database backend
- Monitoring and logging

### Application Options

Choose one:
1. **Python Flask Blog**: Simple blog with posts, comments
2. **Node.js Todo App**: Task management application
3. **WordPress**: Popular CMS (easier option)
4. **E-commerce Site**: Product catalog with shopping cart

### Architecture

```
                    [Users]
                       ↓
              [Load Balancer] (HTTPS)
                       ↓
        ┌──────────────┼──────────────┐
        ↓              ↓               ↓
   [Web Server 1] [Web Server 2] [Web Server 3]
        └──────────────┴───────────────┘
                       ↓
                [Database Server]
              (RDS / Azure SQL)
```

### Requirements

**Infrastructure**:
- Load balancer with HTTPS
- 2-3 web server instances
- Database (RDS / Azure SQL Database)
- Auto-scaling configuration
- Security groups properly configured
- Health checks enabled

**Application**:
- Working web application
- Connected to database
- Session management
- Error handling
- Logging

### Implementation Guide

#### AWS Implementation

**Step 1: Set Up VPC and Subnets**
```bash
# Create VPC
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-app-vpc}]'

# Create public subnets (2 for high availability)
aws ec2 create-subnet \
    --vpc-id vpc-xxxxx \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a

aws ec2 create-subnet \
    --vpc-id vpc-xxxxx \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1b
```

**Step 2: Create Security Groups**
```bash
# Security group for load balancer
aws ec2 create-security-group \
    --group-name alb-sg \
    --description "Security group for ALB" \
    --vpc-id vpc-xxxxx

# Allow HTTP/HTTPS from internet
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxx \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxx \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# Security group for web servers
aws ec2 create-security-group \
    --group-name web-sg \
    --description "Security group for web servers" \
    --vpc-id vpc-xxxxx

# Allow traffic from ALB only
aws ec2 authorize-security-group-ingress \
    --group-id sg-yyyyy \
    --protocol tcp \
    --port 80 \
    --source-group sg-xxxxx
```

**Step 3: Launch EC2 Instances**

Create a user data script (`user-data.sh`):
```bash
#!/bin/bash
# Update system
yum update -y

# Install Node.js (or your runtime)
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install and start nginx
amazon-linux-extras install nginx1 -y
systemctl start nginx
systemctl enable nginx

# Clone your application
cd /home/ec2-user
git clone https://github.com/yourusername/your-app.git
cd your-app

# Install dependencies
npm install

# Start application with PM2
npm install -g pm2
pm2 start app.js
pm2 startup
pm2 save

# Configure nginx as reverse proxy
cat > /etc/nginx/conf.d/app.conf << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

systemctl restart nginx
```

Launch instances:
```bash
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --count 2 \
    --instance-type t2.micro \
    --key-name my-key-pair \
    --security-group-ids sg-yyyyy \
    --subnet-id subnet-xxxxx \
    --user-data file://user-data.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server}]'
```

**Step 4: Create Application Load Balancer**
```bash
# Create ALB
aws elbv2 create-load-balancer \
    --name my-app-alb \
    --subnets subnet-xxxxx subnet-yyyyy \
    --security-groups sg-xxxxx \
    --scheme internet-facing \
    --type application

# Create target group
aws elbv2 create-target-group \
    --name web-servers-tg \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-xxxxx \
    --health-check-path /health

# Register targets
aws elbv2 register-targets \
    --target-group-arn arn:aws:elasticloadbalancing:... \
    --targets Id=i-xxxxx Id=i-yyyyy

# Create listener
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:... \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:...
```

**Step 5: Set Up Auto Scaling**
```bash
# Create launch template
aws ec2 create-launch-template \
    --launch-template-name web-server-template \
    --version-description "Version 1" \
    --launch-template-data file://launch-template.json

# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name web-servers-asg \
    --launch-template LaunchTemplateName=web-server-template,Version='$Latest' \
    --min-size 2 \
    --max-size 5 \
    --desired-capacity 2 \
    --target-group-arns arn:aws:elasticloadbalancing:... \
    --vpc-zone-identifier "subnet-xxxxx,subnet-yyyyy"

# Create scaling policies
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name web-servers-asg \
    --policy-name scale-up \
    --scaling-adjustment 1 \
    --adjustment-type ChangeInCapacity
```

#### Azure Implementation

**Step 1: Create Resource Group and VNet**
```bash
# Variables
RG_NAME="webapp-rg"
LOCATION="eastus"
VNET_NAME="webapp-vnet"
LB_NAME="webapp-lb"
VMSS_NAME="webapp-vmss"

# Create resource group
az group create --name $RG_NAME --location $LOCATION

# Create VNet with subnets
az network vnet create \
    --resource-group $RG_NAME \
    --name $VNET_NAME \
    --address-prefix 10.0.0.0/16 \
    --subnet-name frontend \
    --subnet-prefix 10.0.1.0/24
```

**Step 2: Create Load Balancer**
```bash
# Create public IP
az network public-ip create \
    --resource-group $RG_NAME \
    --name lb-public-ip \
    --sku Standard

# Create load balancer
az network lb create \
    --resource-group $RG_NAME \
    --name $LB_NAME \
    --sku Standard \
    --public-ip-address lb-public-ip \
    --frontend-ip-name lb-frontend \
    --backend-pool-name lb-backend-pool

# Create health probe
az network lb probe create \
    --resource-group $RG_NAME \
    --lb-name $LB_NAME \
    --name health-probe \
    --protocol http \
    --port 80 \
    --path /health

# Create load balancing rule
az network lb rule create \
    --resource-group $RG_NAME \
    --lb-name $LB_NAME \
    --name http-rule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name lb-frontend \
    --backend-pool-name lb-backend-pool \
    --probe-name health-probe
```

**Step 3: Create VM Scale Set**

Create cloud-init file (`cloud-init.txt`):
```yaml
#cloud-config
package_upgrade: true
packages:
  - nginx
  - nodejs
  - npm
write_files:
  - path: /etc/nginx/sites-available/default
    content: |
      server {
        listen 80;
        location / {
          proxy_pass http://localhost:3000;
        }
      }
runcmd:
  - systemctl restart nginx
  - cd /home/azureuser && git clone https://github.com/yourusername/your-app.git
  - cd /home/azureuser/your-app && npm install
  - npm install -g pm2
  - cd /home/azureuser/your-app && pm2 start app.js
```

```bash
# Create VMSS
az vmss create \
    --resource-group $RG_NAME \
    --name $VMSS_NAME \
    --image UbuntuLTS \
    --upgrade-policy-mode automatic \
    --admin-username azureuser \
    --generate-ssh-keys \
    --instance-count 2 \
    --vnet-name $VNET_NAME \
    --subnet frontend \
    --lb $LB_NAME \
    --backend-pool-name lb-backend-pool \
    --custom-data cloud-init.txt

# Configure auto-scaling
az monitor autoscale create \
    --resource-group $RG_NAME \
    --resource $VMSS_NAME \
    --resource-type Microsoft.Compute/virtualMachineScaleSets \
    --name autoscale-rule \
    --min-count 2 \
    --max-count 5 \
    --count 2

# Scale up rule (CPU > 70%)
az monitor autoscale rule create \
    --resource-group $RG_NAME \
    --autoscale-name autoscale-rule \
    --condition "Percentage CPU > 70 avg 5m" \
    --scale out 1

# Scale down rule (CPU < 30%)
az monitor autoscale rule create \
    --resource-group $RG_NAME \
    --autoscale-name autoscale-rule \
    --condition "Percentage CPU < 30 avg 5m" \
    --scale in 1
```

---

## ✅ Testing Your Deployment

### Functional Testing
```bash
# Get load balancer URL
# AWS
aws elbv2 describe-load-balancers --names my-app-alb

# Azure
az network public-ip show --resource-group $RG_NAME --name lb-public-ip

# Test the application
curl http://your-lb-url/

# Test health endpoint
curl http://your-lb-url/health
```

### Load Testing

Use Apache Bench or similar:
```bash
# Install Apache Bench
sudo yum install httpd-tools

# Run load test (1000 requests, 10 concurrent)
ab -n 1000 -c 10 http://your-lb-url/

# Watch auto-scaling trigger
# AWS
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names web-servers-asg

# Azure
az vmss list-instances --resource-group $RG_NAME --name $VMSS_NAME
```

---

## 📊 Cost Estimation

### AWS Costs (Monthly)
- **EC2 t2.micro**: 2-5 instances × $8.50 = $17-43
- **Application Load Balancer**: ~$16
- **Data Transfer**: ~$5-10
- **Total**: ~$38-69/month

### Azure Costs (Monthly)
- **B2s VMs**: 2-5 instances × $30 = $60-150
- **Load Balancer**: ~$18
- **Data Transfer**: ~$5-10
- **Total**: ~$83-178/month

**Note**: Use Free Tier credits during learning!

---

## 📚 Key Concepts Learned

1. **Virtual Machines**: Infrastructure as a Service
2. **Load Balancing**: Distribute traffic across multiple servers
3. **Auto-Scaling**: Automatically adjust capacity
4. **High Availability**: Deploy across multiple AZs/zones
5. **Security Groups**: Control network traffic
6. **Health Checks**: Monitor application health

---

## 🎓 Assessment

Test your knowledge:
1. Explain the difference between vertical and horizontal scaling
2. When would you use ALB vs NLB?
3. How does auto-scaling decide when to scale?
4. What is the purpose of health checks?
5. How do security groups differ from NACLs?

---

## 🔄 Next Steps

Once you've completed Phase 2, move on to:

**[Phase 3: Storage & Databases](../Phase-3-Storage-Databases/)** where you'll learn about:
- Object storage (S3, Blob Storage)
- Block storage (EBS, Azure Disks)
- Relational databases (RDS, Azure SQL)
- NoSQL databases (DynamoDB, Cosmos DB)

---

**Need Help?** Check troubleshooting guides or join community forums.

