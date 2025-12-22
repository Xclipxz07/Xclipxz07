# 🚀 Quick Start Guide

Welcome to the AWS & Azure Learning Path! Follow this guide to get started on your cloud journey.

## 📋 Before You Begin

### ✅ Prerequisites Checklist

- [ ] Basic understanding of:
  - How websites work
  - Command line basics
  - Programming fundamentals (any language)
- [ ] Computer with internet connection
- [ ] 10-15 hours per week for study
- [ ] Credit/debit card for account creation (free tiers available)

### 💻 Install Required Tools

**1. Text Editor / IDE**
```bash
# Download and install VS Code
https://code.visualstudio.com/
```

**2. Git**
```bash
# Windows
https://git-scm.com/download/win

# Mac
brew install git

# Linux
sudo apt-get install git
```

**3. AWS CLI**
```bash
# Windows
https://awscli.amazonaws.com/AWSCLIV2.msi

# Mac
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**4. Azure CLI**
```bash
# Windows
https://aka.ms/installazurecliwindows

# Mac
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

## 🎯 Week 1: Setup and Orientation

### Day 1: Create Accounts (2 hours)

**Create AWS Account**:
1. Go to https://aws.amazon.com/free/
2. Click "Create a Free Account"
3. Enter email and password
4. Complete registration
5. Add payment method (won't be charged with free tier)
6. Verify phone number
7. Select "Basic Support (Free)"

**Set Up Billing Alerts** (IMPORTANT!):
```bash
# After login, go to Billing Dashboard
1. Preferences → "Receive Billing Alerts" → Enable
2. CloudWatch → Billing → Create Alarm
3. Set threshold: $10
4. Add email notification
```

**Create Azure Account**:
1. Go to https://azure.microsoft.com/free/
2. Click "Start free"
3. Sign in with Microsoft account
4. Complete profile
5. Verify phone number
6. Add payment method
7. Get $200 free credit

**Set Up Cost Alerts**:
```bash
# In Azure Portal
1. Cost Management + Billing
2. Cost alerts → Add
3. Budget: $50
4. Alert at 80%, 90%, 100%
5. Add email notification
```

### Day 2: Configure CLI Tools (2 hours)

**Configure AWS CLI**:
```bash
# Create IAM user (not root!)
1. AWS Console → IAM
2. Users → Add user
3. Name: "cli-user"
4. Access type: Programmatic access
5. Permissions: AdministratorAccess (for learning)
6. Download credentials

# Configure CLI
aws configure
# Enter Access Key ID
# Enter Secret Access Key
# Default region: us-east-1
# Default output: json

# Test
aws sts get-caller-identity
```

**Configure Azure CLI**:
```bash
# Login
az login
# Browser will open, sign in

# List subscriptions
az account list --output table

# Set default subscription
az account set --subscription "Your-Subscription-Name"

# Test
az account show
```

### Day 3-4: Learn Cloud Fundamentals (4 hours)

Read:
- [Cloud Computing Concepts](./Phase-1-Cloud-Fundamentals/01-Introduction-to-Cloud/cloud-concepts.md)
- Understand: IaaS, PaaS, SaaS
- Understand: Regions, Availability Zones

Watch:
- AWS Overview video
- Azure Overview video

### Day 5-7: First Project (6 hours)

Deploy your first website:
- [AWS Static Website Guide](./Phase-1-Cloud-Fundamentals/03-First-Project/aws-static-website/README.md)
- [Azure Static Website Guide](./Phase-1-Cloud-Fundamentals/03-First-Project/azure-static-website/README.md)

**Deliverable**: Live website on both platforms! 🎉

---

## 📅 First Month Plan

### Week 1: Setup & First Project ✅
- Complete account setup
- Deploy static website
- Understand cloud basics

### Week 2: Cloud Fundamentals
- [Phase 1 Complete](./Phase-1-Cloud-Fundamentals/)
- Practice with S3 and Blob Storage
- Understand pricing models
- Take notes

### Week 3: Compute Services - Part 1
- [Phase 2 Start](./Phase-2-Compute-Services/)
- Launch EC2 instances
- Create Azure VMs
- Connect via SSH/RDP

### Week 4: Compute Services - Part 2
- Set up Load Balancers
- Configure Auto Scaling
- Deploy web application
- Start studying for certifications

---

## 🎓 First Certification (Month 2)

After completing Phase 1-2, you're ready for:

**AWS Cloud Practitioner**
- 1 week preparation
- Cost: $100
- [Study Guide](./Certification-Guide/README.md#1-aws-certified-cloud-practitioner-clf-c02)

**Azure Fundamentals (AZ-900)**
- 1 week preparation
- Cost: $99
- [Study Guide](./Certification-Guide/README.md#1-microsoft-certified-azure-fundamentals-az-900)

---

## 💡 Study Tips

### Time Management
```
Daily Schedule (2 hours):
- 60 min: Theory/Reading
- 30 min: Hands-on practice
- 30 min: Review/Documentation
```

### Learning Strategy
1. **Don't just read - DO!**
   - Type every command
   - Make mistakes and fix them
   - Experiment with settings

2. **Take Notes**
   - Use Notion, Obsidian, or simple text files
   - Document commands that work
   - Save error messages and solutions

3. **Build Portfolio**
   - Create GitHub repository
   - Add README for each project
   - Include screenshots
   - Document challenges and solutions

4. **Join Communities**
   - Reddit: r/aws, r/azure
   - Discord servers
   - LinkedIn groups
   - Local meetups

### Cost Management
```
⚠️ ALWAYS:
- Set billing alerts
- Use Free Tier resources
- Delete resources after practice
- Check billing dashboard weekly

💰 Free Tier Limits:
AWS:
- 750 hours EC2 t2.micro/month
- 5 GB S3 storage
- 1 million Lambda requests

Azure:
- $200 credit (first 30 days)
- 12 months free services
- Always free services
```

---

## 🗺️ Learning Path Overview

### Beginner (Months 1-2)
- ✅ Phase 1: Cloud Fundamentals
- ✅ Phase 2: Compute Services
- ✅ AWS Cloud Practitioner cert
- ✅ Azure Fundamentals cert

### Intermediate (Months 3-4)
- ✅ Phase 3: Storage & Databases
- ✅ Phase 4: Networking & Security
- ✅ AWS Solutions Architect Associate
- ✅ Azure Administrator Associate

### Advanced (Months 5-6)
- ✅ Phase 5: DevOps & Automation
- ✅ Phase 6: Serverless & Containers
- ✅ Build portfolio projects

### Job Ready (Months 7-8)
- ✅ Phase 7: Monitoring & Optimization
- ✅ Capstone project
- ✅ Professional certifications
- ✅ Job applications

---

## 📚 Resources Bookmarks

Save these links:

**AWS**:
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Console](https://console.aws.amazon.com/)
- [AWS Training](https://www.aws.training/)

**Azure**:
- [Azure Free Account](https://azure.microsoft.com/free/)
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [Azure Portal](https://portal.azure.com/)
- [Microsoft Learn](https://learn.microsoft.com/azure/)

**Communities**:
- [r/aws](https://reddit.com/r/aws)
- [r/azure](https://reddit.com/r/azure)
- [r/devops](https://reddit.com/r/devops)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/amazon-web-services)

---

## ❓ FAQ

**Q: Do I need to learn both AWS and Azure?**  
A: Yes! Many companies use both. Learning both makes you more marketable. The concepts transfer between platforms.

**Q: Will this really cost me nothing?**  
A: AWS and Azure offer generous free tiers. If you follow the guides and clean up resources, costs should be $0-10/month.

**Q: How long does this take?**  
A: 6-8 months part-time (10-15 hours/week). Faster if you study full-time.

**Q: Can I get a job after this?**  
A: Yes! With certifications and projects, you'll be qualified for entry-level cloud roles ($70k-95k).

**Q: I have no IT background. Can I still do this?**  
A: Yes! Start with Phase 1 and take your time. The prerequisites are minimal.

**Q: What if I get stuck?**  
A: 
- Read error messages carefully
- Google the error
- Check AWS/Azure documentation
- Ask in Reddit communities
- Review the troubleshooting sections

---

## ✅ Daily Checklist Template

Copy this for daily tracking:

```markdown
## Day X - [Date]

### Learning Goals
- [ ] Read: [topic]
- [ ] Complete: [lab/exercise]
- [ ] Practice: [skill]

### Time Spent
- Theory: ___ min
- Hands-on: ___ min
- Review: ___ min

### What I Learned
- 

### Challenges Faced
- 

### Solutions Found
- 

### Tomorrow's Plan
- 
```

---

## 🎯 First Week Action Items

Start here, right now:

**Today**:
- [ ] Create AWS account
- [ ] Create Azure account
- [ ] Set up billing alerts on both

**Tomorrow**:
- [ ] Install AWS CLI
- [ ] Install Azure CLI
- [ ] Configure credentials
- [ ] Test CLI with simple commands

**This Week**:
- [ ] Read cloud fundamentals guide
- [ ] Create simple website (HTML/CSS)
- [ ] Deploy to AWS S3
- [ ] Deploy to Azure Blob Storage
- [ ] Celebrate! 🎉

---

## 🎉 Ready to Start?

1. **Bookmark this repository**
2. **Create your free accounts TODAY**
3. **Join the community on Reddit**
4. **Start with Phase 1**

→ [Begin Phase 1: Cloud Fundamentals](./Phase-1-Cloud-Fundamentals/)

---

## 💬 Need Help?

- Issues with accounts: Check FAQ sections
- Technical questions: AWS/Azure documentation
- Community support: Reddit, Stack Overflow
- Motivation: Remember your goals! 💪

---

**Welcome to your cloud journey! You've got this! 🚀**

