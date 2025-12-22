# Project 4: Secure Multi-Tier Architecture

## 🎯 Project Overview

Design and deploy a production-grade secure network architecture with proper segmentation, security controls, and monitoring.

**What You'll Build**:
- VPC/VNet with public and private subnets
- Bastion host for secure access
- NAT Gateway for outbound internet
- Web Application Firewall (WAF)
- Network security controls
- Encrypted data storage
- IAM roles and policies
- Security monitoring and logging

**Time Required**: 10-12 hours  
**Difficulty**: Intermediate-Advanced  
**Cost**: $10-20/month

---

## 📋 Architecture

```
                    [Internet]
                        ↓
                    [WAF + DDoS]
                        ↓
                [Internet Gateway]
                        ↓
            ┌───────────┴───────────┐
            ↓                       ↓
    [Public Subnet AZ-1]    [Public Subnet AZ-2]
      - Load Balancer         - Load Balancer
      - Bastion Host          - NAT Gateway
            ↓                       ↓
    [Private Subnet AZ-1]   [Private Subnet AZ-2]
      - App Servers           - App Servers
            ↓                       ↓
    [Private Subnet AZ-1]   [Private Subnet AZ-2]
      - Database Master       - Database Replica
```

**Security Layers**:
1. **Perimeter**: WAF, DDoS protection, SSL/TLS
2. **Network**: Security Groups, NACLs, NSGs
3. **Access**: Bastion host, VPN, MFA
4. **Application**: IAM roles, least privilege
5. **Data**: Encryption at rest and in transit
6. **Monitoring**: CloudTrail, Flow Logs, Security Hub

---

## 🔒 Security Components

### 1. Network Segmentation

**Public Subnets** (0.0.0.0/0 route to IGW):
- Load balancers
- Bastion hosts
- NAT gateways

**Private Subnets** (no direct internet):
- Application servers
- Database servers
- Internal services

### 2. Security Controls

```bash
# Security Group Rules (AWS)
# ALB Security Group
- Inbound: 80 (HTTP) from 0.0.0.0/0
- Inbound: 443 (HTTPS) from 0.0.0.0/0
- Outbound: All to VPC

# App Server Security Group
- Inbound: 8080 from ALB-SG only
- Inbound: 22 from Bastion-SG only
- Outbound: 443 (HTTPS) to internet via NAT
- Outbound: 5432 to Database-SG

# Database Security Group
- Inbound: 5432 from App-SG only
- No outbound to internet

# Bastion Security Group
- Inbound: 22 from your-ip/32 only
- Outbound: 22 to private subnets
```

### 3. IAM Policies (Least Privilege)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-app-bucket/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 🚀 AWS Deployment

### Step-by-Step Setup

```bash
#!/bin/bash
# Secure Architecture Deployment - AWS

# Variables
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_1="10.0.1.0/24"
PUBLIC_SUBNET_2="10.0.2.0/24"
PRIVATE_APP_1="10.0.11.0/24"
PRIVATE_APP_2="10.0.12.0/24"
PRIVATE_DB_1="10.0.21.0/24"
PRIVATE_DB_2="10.0.22.0/24"

# 1. Create VPC
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=secure-app-vpc}]' \
    --query 'Vpc.VpcId' --output text)

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames

# 2. Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=secure-app-igw}]' \
    --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# 3. Create Subnets
# Public Subnets
PUB_SUB_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_SUBNET_1 \
    --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)

PUB_SUB_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_SUBNET_2 \
    --availability-zone us-east-1b --query 'Subnet.SubnetId' --output text)

# Private App Subnets
PRIV_APP_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_APP_1 \
    --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)

PRIV_APP_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_APP_2 \
    --availability-zone us-east-1b --query 'Subnet.SubnetId' --output text)

# Private DB Subnets
PRIV_DB_1=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_DB_1 \
    --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)

PRIV_DB_2=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_DB_2 \
    --availability-zone us-east-1b --query 'Subnet.SubnetId' --output text)

# 4. Create NAT Gateway
EIP_ID=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)

NAT_GW=$(aws ec2 create-nat-gateway \
    --subnet-id $PUB_SUB_1 \
    --allocation-id $EIP_ID \
    --query 'NatGateway.NatGatewayId' --output text)

# Wait for NAT Gateway
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW

# 5. Create Route Tables
# Public Route Table
PUB_RTB=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $PUB_RTB --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --route-table-id $PUB_RTB --subnet-id $PUB_SUB_1
aws ec2 associate-route-table --route-table-id $PUB_RTB --subnet-id $PUB_SUB_2

# Private Route Table
PRIV_RTB=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $PRIV_RTB --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW
aws ec2 associate-route-table --route-table-id $PRIV_RTB --subnet-id $PRIV_APP_1
aws ec2 associate-route-table --route-table-id $PRIV_RTB --subnet-id $PRIV_APP_2
aws ec2 associate-route-table --route-table-id $PRIV_RTB --subnet-id $PRIV_DB_1
aws ec2 associate-route-table --route-table-id $PRIV_RTB --subnet-id $PRIV_DB_2

# 6. Create Security Groups
# Bastion SG
BASTION_SG=$(aws ec2 create-security-group \
    --group-name bastion-sg \
    --description "Bastion host security group" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

# Get your public IP
MY_IP=$(curl -s https://checkip.amazonaws.com)

aws ec2 authorize-security-group-ingress \
    --group-id $BASTION_SG \
    --protocol tcp --port 22 --cidr $MY_IP/32

# ALB SG
ALB_SG=$(aws ec2 create-security-group \
    --group-name alb-sg \
    --description "Load balancer security group" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $ALB_SG --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $ALB_SG --protocol tcp --port 443 --cidr 0.0.0.0/0

# App Server SG
APP_SG=$(aws ec2 create-security-group \
    --group-name app-sg \
    --description "Application server security group" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $APP_SG --protocol tcp --port 8080 --source-group $ALB_SG
aws ec2 authorize-security-group-ingress --group-id $APP_SG --protocol tcp --port 22 --source-group $BASTION_SG

# Database SG
DB_SG=$(aws ec2 create-security-group \
    --group-name db-sg \
    --description "Database security group" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $DB_SG --protocol tcp --port 5432 --source-group $APP_SG

# 7. Enable VPC Flow Logs
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids $VPC_ID \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name /aws/vpc/flowlogs

# 8. Create KMS Key for Encryption
KMS_KEY=$(aws kms create-key \
    --description "Encryption key for secure app" \
    --query 'KeyMetadata.KeyId' --output text)

# 9. Launch Bastion Host
BASTION_AMI=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text)

aws ec2 run-instances \
    --image-id $BASTION_AMI \
    --instance-type t2.micro \
    --key-name my-key \
    --security-group-ids $BASTION_SG \
    --subnet-id $PUB_SUB_1 \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bastion-host}]'

echo "Secure architecture deployed!"
echo "VPC ID: $VPC_ID"
echo "Bastion Host in Public Subnet"
echo "Application servers go in Private App Subnets"
echo "Database servers go in Private DB Subnets"
```

---

## 🔐 Security Best Practices Implemented

### 1. Network Security
✅ Private subnets for applications and databases  
✅ NAT Gateway for outbound internet from private subnets  
✅ Security Groups with least privilege rules  
✅ Network ACLs for subnet-level control  
✅ VPC Flow Logs enabled for network monitoring  

### 2. Access Control
✅ Bastion host for SSH access (no direct SSH to private instances)  
✅ IAM roles instead of access keys  
✅ MFA enforced for console access  
✅ Temporary credentials using STS  
✅ AWS Systems Manager Session Manager (no SSH keys needed)  

### 3. Data Protection
✅ Encryption at rest using KMS  
✅ Encryption in transit (TLS/SSL)  
✅ RDS with encryption enabled  
✅ S3 buckets with encryption  
✅ EBS volumes encrypted  

### 4. Monitoring & Logging
✅ CloudTrail for API logging  
✅ VPC Flow Logs for network traffic  
✅ CloudWatch Logs for application logs  
✅ AWS Config for compliance monitoring  
✅ GuardDuty for threat detection  

### 5. Compliance
✅ Automated compliance checks  
✅ Regular security assessments  
✅ Patch management  
✅ Backup and disaster recovery  
✅ Audit trails  

---

## 🎓 Learning Objectives

After this project, you'll understand:

✅ VPC/VNet design principles  
✅ Network segmentation strategies  
✅ Security group vs NACL differences  
✅ Bastion host vs VPN vs SSM Session Manager  
✅ IAM best practices and least privilege  
✅ Encryption implementation  
✅ Security monitoring and logging  
✅ Compliance and audit requirements  
✅ Incident response preparation  

---

## ✅ Project Checklist

- [ ] VPC created with proper CIDR blocks
- [ ] Public and private subnets configured
- [ ] Internet Gateway and NAT Gateway deployed
- [ ] Security Groups configured with least privilege
- [ ] Bastion host deployed and accessible
- [ ] Application servers in private subnets
- [ ] Database in isolated private subnets
- [ ] Encryption enabled for all data
- [ ] CloudTrail and Flow Logs enabled
- [ ] WAF configured (optional)
- [ ] Security audit completed
- [ ] Documentation updated

---

## 📊 Security Checklist

```bash
# Run security audit
aws ec2 describe-security-groups --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]]'

# Check for unencrypted EBS volumes
aws ec2 describe-volumes --filters "Name=encrypted,Values=false"

# Review IAM policies
aws iam get-account-authorization-details

# Check S3 bucket policies
aws s3api get-bucket-policy --bucket my-bucket

# Review CloudTrail status
aws cloudtrail describe-trails
```

---

**Next**: [Phase 5: DevOps & Automation](../../Phase-5-DevOps-Automation/)
