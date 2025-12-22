# Project 2: Multi-Tier Web Application with Load Balancer

## 🎯 Project Overview

Deploy a production-ready, highly available web application with load balancing and auto-scaling on both AWS and Azure.

**What You'll Build**:
- Load-balanced web application
- Auto-scaling based on traffic
- Health monitoring
- Database backend
- Complete CI/CD integration

**Time Required**: 6-8 hours  
**Difficulty**: Intermediate  
**Cost**: $0 with free tier (during learning)

---

## 📋 Architecture

```
                    Internet
                       ↓
              [Load Balancer] (HTTPS)
                       ↓
        ┌──────────────┼──────────────┐
        ↓              ↓               ↓
   [Web Server 1] [Web Server 2] [Web Server 3]
   (Auto-scaled)   (Auto-scaled)  (Auto-scaled)
        └──────────────┴───────────────┘
                       ↓
              [Database (RDS/SQL)]
              (Multi-AZ/Zone)
```

**Key Components**:
- **Load Balancer**: Distributes traffic across multiple servers
- **Web Servers**: Auto-scaled application instances (2-5)
- **Database**: Managed database service
- **Auto Scaling**: Automatically adjusts capacity based on demand
- **Health Checks**: Monitors application health

---

## 🚀 Application: Flask Blog

We'll deploy a simple blog application with:
- User authentication
- Create/read blog posts
- Comments system
- PostgreSQL database
- Session management

---

## 📁 Project Files

```
project-web-app/
├── README.md (this file)
├── app-code/
│   ├── app.py
│   ├── models.py
│   ├── requirements.txt
│   ├── templates/
│   └── static/
├── aws/
│   ├── deploy.sh
│   ├── user-data.sh
│   ├── cleanup.sh
│   └── architecture-diagram.png
└── azure/
    ├── deploy.sh
    ├── cloud-init.yaml
    ├── cleanup.sh
    └── architecture-diagram.png
```

---

## 💻 Part 1: Application Code

All code files are in the `app-code/` directory. Let's review each:

### Prerequisites
```bash
# Install Python 3.9+
# Install pip
# Install git
```

### Test Locally
```bash
cd app-code/

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export DATABASE_URL="postgresql://user:pass@localhost/blogdb"
export SECRET_KEY="your-secret-key-here"

# Run locally
python app.py

# Visit http://localhost:5000
```

---

## ☁️ Part 2: AWS Deployment

### Architecture Components

**AWS Services Used**:
- EC2 (t2.micro instances)
- Application Load Balancer (ALB)
- Auto Scaling Groups
- RDS PostgreSQL (db.t3.micro)
- VPC with public/private subnets
- Security Groups
- CloudWatch for monitoring

### Step-by-Step Deployment

Navigate to the `aws/` directory and follow the deployment guide.

**Deployment Script**:
```bash
cd aws/
chmod +x deploy.sh
./deploy.sh
```

The script will:
1. Create VPC with subnets
2. Launch RDS PostgreSQL database
3. Create security groups
4. Launch EC2 instances with application
5. Configure Application Load Balancer
6. Set up Auto Scaling Group
7. Output the application URL

**Estimated Setup Time**: 20-30 minutes (mostly waiting for RDS)

### Manual Deployment Steps

If you prefer manual deployment, see detailed step-by-step instructions in `aws/MANUAL-DEPLOYMENT.md`.

### Testing AWS Deployment

```bash
# Get ALB DNS name
aws elbv2 describe-load-balancers \
    --names blog-app-alb \
    --query 'LoadBalancers[0].DNSName' \
    --output text

# Test application
curl http://<ALB-DNS-NAME>

# Test health endpoint
curl http://<ALB-DNS-NAME>/health

# Check auto-scaling
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names blog-app-asg
```

### Load Testing

```bash
# Install Apache Bench
sudo yum install httpd-tools -y

# Run load test (1000 requests, 50 concurrent)
ab -n 1000 -c 50 http://<ALB-DNS-NAME>/

# Watch instances scale up
watch -n 5 'aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names blog-app-asg \
    --query "AutoScalingGroups[0].Instances[*].[InstanceId,LifecycleState]" \
    --output table'
```

### Cleanup

```bash
cd aws/
./cleanup.sh
```

**Important**: Always cleanup to avoid charges!

---

## ☁️ Part 3: Azure Deployment

### Architecture Components

**Azure Services Used**:
- Virtual Machines (B1s)
- VM Scale Sets
- Azure Load Balancer
- Azure Database for PostgreSQL
- Virtual Network (VNet)
- Network Security Groups (NSG)
- Azure Monitor

### Step-by-Step Deployment

Navigate to the `azure/` directory and follow the deployment guide.

**Deployment Script**:
```bash
cd azure/
chmod +x deploy.sh
./deploy.sh
```

The script will:
1. Create Resource Group
2. Create VNet with subnets
3. Deploy Azure Database for PostgreSQL
4. Create Network Security Groups
5. Create VM Scale Set with application
6. Configure Azure Load Balancer
7. Set up auto-scaling rules
8. Output the application URL

**Estimated Setup Time**: 20-30 minutes

### Manual Deployment Steps

See detailed step-by-step instructions in `azure/MANUAL-DEPLOYMENT.md`.

### Testing Azure Deployment

```bash
# Get Load Balancer IP
az network public-ip show \
    --resource-group blog-app-rg \
    --name lb-public-ip \
    --query ipAddress \
    --output tsv

# Test application
curl http://<LB-IP>

# Test health endpoint
curl http://<LB-IP>/health

# Check scale set instances
az vmss list-instances \
    --resource-group blog-app-rg \
    --name blog-app-vmss \
    --output table
```

### Load Testing

```bash
# Run load test
ab -n 1000 -c 50 http://<LB-IP>/

# Watch instances scale
watch -n 5 'az vmss list-instances \
    --resource-group blog-app-rg \
    --name blog-app-vmss \
    --query "[].{Name:name, State:provisioningState}" \
    --output table'
```

### Cleanup

```bash
cd azure/
./cleanup.sh
```

---

## 📊 Performance Comparison

| Metric | AWS | Azure |
|--------|-----|-------|
| Setup Time | 25 min | 28 min |
| Cold Start | 2-3 min | 3-4 min |
| Scale Up Time | 3-5 min | 4-6 min |
| Cost/Month* | $35-50 | $40-55 |
| Response Time | 45-60ms | 50-65ms |

*Estimated cost without free tier

---

## 🎓 Learning Objectives Achieved

After completing this project, you will understand:

✅ **Load Balancing**
- How to distribute traffic across multiple servers
- Health checks and target group configuration
- SSL/TLS termination at load balancer

✅ **Auto Scaling**
- Creating launch templates/configurations
- Defining scaling policies (CPU, memory, custom metrics)
- Handling scaling events gracefully

✅ **High Availability**
- Multi-AZ/Zone deployment
- Fault tolerance design
- Disaster recovery basics

✅ **Database Management**
- RDS and Azure Database setup
- Connection pooling
- Database migrations

✅ **Security**
- Security group/NSG configuration
- Principle of least privilege
- Secure database connections

✅ **Monitoring**
- CloudWatch/Azure Monitor metrics
- Custom application metrics
- Log aggregation

---

## 🔧 Troubleshooting

### Issue: Instances Not Passing Health Checks

**Symptoms**: Load balancer marks instances as unhealthy

**Solutions**:
1. Check security groups allow traffic from load balancer
2. Verify application is listening on correct port
3. Check /health endpoint returns 200 status
4. Review application logs

```bash
# AWS: Check instance logs
aws ec2 get-console-output --instance-id i-xxxxx

# Azure: Check VM logs
az vmss get-instance-view \
    --resource-group blog-app-rg \
    --name blog-app-vmss \
    --instance-id 0
```

### Issue: Database Connection Failures

**Symptoms**: Application can't connect to database

**Solutions**:
1. Verify security groups allow database access
2. Check connection string is correct
3. Ensure database is in same VPC/VNet
4. Verify database credentials

```bash
# Test database connectivity from instance
psql -h <db-endpoint> -U dbuser -d blogdb
```

### Issue: Auto Scaling Not Working

**Symptoms**: No new instances launch under load

**Solutions**:
1. Check CloudWatch/Azure Monitor metrics
2. Verify scaling policy thresholds
3. Check service quotas (max instances)
4. Review IAM/RBAC permissions

---

## 📈 Performance Optimization Tips

### 1. Application Level
- Enable caching (Redis/Memcached)
- Database query optimization
- Connection pooling
- Gzip compression
- CDN for static assets

### 2. Infrastructure Level
- Use appropriate instance types
- Enable auto-scaling predictive policies
- Optimize health check intervals
- Use keep-alive connections
- Enable load balancer connection draining

### 3. Database Level
- Read replicas for read-heavy workloads
- Database connection pooling
- Query caching
- Proper indexing

---

## 💰 Cost Optimization

### Free Tier Usage
- AWS: 750 hours EC2 t2.micro, 750 hours RDS db.t2.micro
- Azure: $200 credit for 30 days

### Cost Reduction Tips
1. Use Reserved Instances for baseline capacity
2. Use Spot Instances for batch jobs
3. Right-size instances based on metrics
4. Use auto-scaling to reduce idle capacity
5. Enable database auto-pause for dev environments

### Estimated Monthly Costs

**Development Environment**:
- AWS: $5-10 (with reserved instances)
- Azure: $5-15 (with reserved instances)

**Production Environment**:
- AWS: $35-100 (depending on traffic)
- Azure: $40-120 (depending on traffic)

---

## 🎯 Next Steps

After completing this project:

1. **Add HTTPS**: Configure SSL/TLS certificates
2. **Add CDN**: CloudFront or Azure CDN for static content
3. **Add Caching**: ElastiCache or Azure Cache for Redis
4. **Add Monitoring**: Comprehensive dashboards
5. **Add CI/CD**: Automated deployments (Phase 5!)
6. **Add WAF**: Web Application Firewall for security

---

## 📚 Additional Resources

- [AWS Auto Scaling Best Practices](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-best-practices.html)
- [Azure VM Scale Sets](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/)
- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Azure Load Balancer](https://docs.microsoft.com/en-us/azure/load-balancer/)

---

## ✅ Project Checklist

- [ ] Application runs locally
- [ ] Deployed on AWS with load balancer
- [ ] Deployed on Azure with load balancer
- [ ] Auto-scaling configured and tested
- [ ] Load testing completed
- [ ] Health checks working
- [ ] Database connection successful
- [ ] Documentation completed
- [ ] Architecture diagram created
- [ ] Cost analysis done
- [ ] Cleanup completed

---

**Congratulations!** You've deployed a production-ready, highly available web application on both AWS and Azure! 🎉

→ [Continue to Phase 3: Storage & Databases](../../Phase-3-Storage-Databases/)
