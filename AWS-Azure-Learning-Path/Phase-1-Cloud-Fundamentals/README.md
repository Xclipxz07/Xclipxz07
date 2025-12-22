# Phase 1: Cloud Fundamentals (Beginner)

**Duration**: 2-3 weeks | **Level**: Beginner | **Prerequisites**: Basic computer knowledge

---

## 📚 Overview

Welcome to Phase 1! This phase will introduce you to cloud computing fundamentals and get you hands-on with both AWS and Azure platforms. By the end of this phase, you'll have deployed your first cloud application.

## 🎯 Learning Objectives

By completing this phase, you will:

- ✅ Understand what cloud computing is and its benefits
- ✅ Know the differences between IaaS, PaaS, and SaaS
- ✅ Navigate AWS and Azure management consoles
- ✅ Understand cloud pricing models
- ✅ Deploy your first application on both platforms
- ✅ Understand regions and availability zones
- ✅ Learn basic cloud security concepts

## 📖 Curriculum

### Week 1: Cloud Computing Fundamentals

#### Module 1: Introduction to Cloud Computing
- [Cloud Computing Concepts](./01-Introduction-to-Cloud/cloud-concepts.md)
  - What is cloud computing?
  - IaaS vs PaaS vs SaaS
  - Public vs Private vs Hybrid cloud
  - Benefits of cloud computing
  - Cloud use cases

#### Module 2: AWS Overview
- [AWS Platform Overview](./01-Introduction-to-Cloud/aws-overview.md)
  - AWS history and market position
  - Core AWS services overview
  - AWS global infrastructure
  - AWS Free Tier offerings
  - AWS Management Console tour

#### Module 3: Azure Overview
- [Azure Platform Overview](./01-Introduction-to-Cloud/azure-overview.md)
  - Microsoft Azure history
  - Core Azure services overview
  - Azure global infrastructure
  - Azure Free Account benefits
  - Azure Portal tour

### Week 2: Getting Started with Cloud Platforms

#### Module 4: Account Setup and Configuration
- [AWS Account Setup](./02-Getting-Started/aws-account-setup.md)
  - Creating AWS account
  - Setting up billing alerts
  - Enabling MFA (Multi-Factor Authentication)
  - Understanding AWS Free Tier limits
  - AWS Organizations basics

- [Azure Account Setup](./02-Getting-Started/azure-account-setup.md)
  - Creating Azure account
  - Understanding subscriptions
  - Setting up cost alerts
  - Enabling MFA
  - Azure Free Tier services

- [CLI Configuration](./02-Getting-Started/cli-configuration.md)
  - Installing AWS CLI
  - Installing Azure CLI
  - Configuring credentials
  - Basic CLI commands
  - Testing your setup

### Week 3: First Real Project

#### Module 5: Deploy Your First Application
- [Project Overview](./03-First-Project/project-overview.md)
  - Project requirements
  - Architecture diagram
  - Step-by-step guide
  - Troubleshooting tips

- [AWS Implementation](./03-First-Project/aws-static-website/)
  - Creating S3 bucket
  - Configuring static website hosting
  - Uploading website files
  - Setting up CloudFront CDN
  - Custom domain with Route 53
  - Enabling HTTPS

- [Azure Implementation](./03-First-Project/azure-static-website/)
  - Creating Storage Account
  - Enabling static website hosting
  - Uploading website files
  - Setting up Azure CDN
  - Custom domain configuration
  - Enabling HTTPS

---

## 🚀 Hands-On Labs

### Lab 1: AWS Console Navigation (30 minutes)
**Objective**: Familiarize yourself with AWS Console

**Tasks**:
1. Log into AWS Console
2. Explore the Services menu
3. Change your region
4. Access AWS Cost Explorer
5. Set up a billing alarm
6. Enable MFA on root account

**Deliverable**: Screenshot of your billing alarm

---

### Lab 2: Azure Portal Navigation (30 minutes)
**Objective**: Familiarize yourself with Azure Portal

**Tasks**:
1. Log into Azure Portal
2. Explore the Azure services
3. Create a Resource Group
4. Access Cost Management
5. Set up budget alerts
6. Enable MFA on your account

**Deliverable**: Screenshot of your budget alert

---

### Lab 3: AWS CLI Basics (1 hour)
**Objective**: Learn basic AWS CLI commands

**Tasks**:
```bash
# Configure AWS CLI
aws configure

# List S3 buckets
aws s3 ls

# Get your identity
aws sts get-caller-identity

# List EC2 regions
aws ec2 describe-regions --output table

# Check your account limits
aws service-quotas list-service-quotas --service-code ec2
```

**Deliverable**: Screenshot showing successful CLI commands

---

### Lab 4: Azure CLI Basics (1 hour)
**Objective**: Learn basic Azure CLI commands

**Tasks**:
```bash
# Login to Azure
az login

# List subscriptions
az account list --output table

# Set active subscription
az account set --subscription "Your-Subscription-Name"

# List resource groups
az group list --output table

# List locations
az account list-locations --output table

# Check your account
az account show
```

**Deliverable**: Screenshot showing successful CLI commands

---

## 📝 Project 1: Deploy Static Portfolio Website

### Project Description

Deploy your personal portfolio website (or any static website) to both AWS and Azure. This project will teach you the fundamentals of cloud storage, content delivery, and DNS management.

### Requirements

**Website Requirements**:
- HTML/CSS/JavaScript files
- Images and other static assets
- Responsive design (mobile-friendly)
- Contact form (using serverless function - optional)

**Cloud Requirements**:
- **AWS**:
  - S3 bucket for storage
  - CloudFront for CDN
  - Route 53 for DNS (optional)
  - ACM for SSL certificate
  
- **Azure**:
  - Storage Account with static website
  - Azure CDN
  - Azure DNS (optional)
  - SSL certificate

### Project Architecture

```
User Request
     ↓
[CloudFront/CDN] ← SSL Certificate
     ↓
[S3/Blob Storage] ← Website Files
     ↓
[Route 53/Azure DNS] ← Custom Domain (optional)
```

### Step-by-Step Guide

#### AWS Implementation

**Step 1: Create S3 Bucket**
```bash
# Create bucket (replace with your unique name)
aws s3 mb s3://my-portfolio-website-unique-name

# Enable static website hosting
aws s3 website s3://my-portfolio-website-unique-name --index-document index.html --error-document error.html
```

**Step 2: Configure Bucket Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-portfolio-website-unique-name/*"
    }
  ]
}
```

**Step 3: Upload Website Files**
```bash
# Upload all files
aws s3 sync ./website/ s3://my-portfolio-website-unique-name/

# Verify upload
aws s3 ls s3://my-portfolio-website-unique-name/
```

**Step 4: Set Up CloudFront** (See detailed guide in project folder)

#### Azure Implementation

**Step 1: Create Storage Account**
```bash
# Create resource group
az group create --name my-portfolio-rg --location eastus

# Create storage account
az storage account create \
  --name myportfoliostorage \
  --resource-group my-portfolio-rg \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2

# Enable static website
az storage blob service-properties update \
  --account-name myportfoliostorage \
  --static-website \
  --404-document error.html \
  --index-document index.html
```

**Step 2: Upload Website Files**
```bash
# Upload files to $web container
az storage blob upload-batch \
  --account-name myportfoliostorage \
  --source ./website/ \
  --destination '$web'
```

**Step 3: Set Up Azure CDN** (See detailed guide in project folder)

### Testing Your Deployment

**AWS Testing Checklist**:
- [ ] Website loads from S3 URL
- [ ] CloudFront distribution is active
- [ ] HTTPS works correctly
- [ ] All pages and assets load
- [ ] Performance is good (use GTmetrix)

**Azure Testing Checklist**:
- [ ] Website loads from Azure Storage URL
- [ ] CDN endpoint is working
- [ ] HTTPS works correctly
- [ ] All pages and assets load
- [ ] Performance is good (use GTmetrix)

### Cost Analysis

**AWS Estimated Monthly Cost** (Free Tier):
- S3 Storage: $0 (first 5GB free)
- CloudFront: $0 (first 1TB transfer free)
- Route 53: $0.50/month per hosted zone (if used)
- **Total: $0-1/month**

**Azure Estimated Monthly Cost** (Free Tier):
- Storage Account: $0 (first 5GB free)
- Azure CDN: $0 (first 10GB free)
- Azure DNS: $0.50/month per zone (if used)
- **Total: $0-1/month**

---

## 📊 Project Deliverables

By the end of Phase 1, you should have:

1. **Live Websites**
   - ✅ Website hosted on AWS S3 + CloudFront
   - ✅ Website hosted on Azure Blob + CDN
   - ✅ Both websites accessible via HTTPS

2. **Documentation**
   - ✅ README with deployment steps
   - ✅ Architecture diagram
   - ✅ Screenshots of working websites
   - ✅ Cost comparison analysis

3. **Learning Journal**
   - ✅ Key concepts learned
   - ✅ Challenges faced and solutions
   - ✅ Differences between AWS and Azure
   - ✅ Questions and notes

4. **GitHub Repository**
   - ✅ Website source code
   - ✅ Deployment scripts
   - ✅ Documentation
   - ✅ Configuration files

---

## 🎓 Assessment

Test your knowledge with these questions:

### Theoretical Questions

1. What are the main differences between IaaS, PaaS, and SaaS? Provide examples.
2. Explain the concept of regions and availability zones.
3. What is the AWS Free Tier and what are its limitations?
4. How does cloud pricing typically work?
5. What is a CDN and why is it important?

### Practical Assessment

1. Deploy a static website to S3 with CloudFront
2. Set up billing alerts on both AWS and Azure
3. Configure custom domain for your website (optional)
4. Implement proper security (HTTPS, bucket policies)
5. Document the entire process

### Self-Evaluation Checklist

- [ ] I can explain what cloud computing is to a beginner
- [ ] I can navigate AWS Console confidently
- [ ] I can navigate Azure Portal confidently
- [ ] I understand how cloud pricing works
- [ ] I have deployed a website to both platforms
- [ ] I can use AWS CLI for basic operations
- [ ] I can use Azure CLI for basic operations
- [ ] I understand regions and availability zones
- [ ] I have set up billing alerts
- [ ] I understand basic cloud security

---

## 🔄 Next Steps

Once you've completed Phase 1, you're ready to move on to:

**[Phase 2: Compute Services](../Phase-2-Compute-Services/)** where you'll learn about:
- EC2 and Azure Virtual Machines
- Load balancing
- Auto-scaling
- Deploying dynamic applications

---

## 📚 Additional Resources

### AWS Resources
- [AWS Getting Started Guide](https://aws.amazon.com/getting-started/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS YouTube Channel](https://www.youtube.com/user/AmazonWebServices)

### Azure Resources
- [Azure Get Started Guide](https://azure.microsoft.com/en-us/get-started/)
- [Azure Free Account](https://azure.microsoft.com/en-us/free/)
- [Microsoft Learn - Azure](https://learn.microsoft.com/en-us/azure/)
- [Azure YouTube Channel](https://www.youtube.com/c/MicrosoftAzure)

### Community Resources
- [Reddit r/aws](https://www.reddit.com/r/aws/)
- [Reddit r/azure](https://www.reddit.com/r/azure/)
- [Stack Overflow - AWS Tag](https://stackoverflow.com/questions/tagged/amazon-web-services)
- [Stack Overflow - Azure Tag](https://stackoverflow.com/questions/tagged/azure)

### Books
- "Amazon Web Services in Action" by Andreas Wittig and Michael Wittig
- "Azure for Architects" by Ritesh Modi
- "Cloud Computing: Concepts, Technology & Architecture" by Thomas Erl

---

## 💡 Pro Tips

1. **Always use Free Tier resources** when learning
2. **Set up billing alerts immediately** - don't wait!
3. **Clean up resources after practice** to avoid charges
4. **Use Infrastructure as Code early** (we'll learn Terraform in Phase 5)
5. **Document everything** - your future self will thank you
6. **Join cloud communities** for support and networking
7. **Practice regularly** - consistency is key
8. **Compare AWS and Azure** as you learn each concept

---

**Need Help?** 
- Review the documentation
- Check Stack Overflow
- Join Discord/Slack communities
- Ask in Reddit communities

---

**Ready to start?** → [Go to Module 1: Cloud Concepts](./01-Introduction-to-Cloud/cloud-concepts.md)

