# Phase 4: Networking & Security (Intermediate)

**Duration**: 3-4 weeks | **Level**: Intermediate

## 🎯 Overview

Learn cloud networking fundamentals and security best practices. Design secure, scalable network architectures.

## 📚 Topics Covered

### Networking
- **Virtual Private Cloud (VPC/VNet)**
- **Subnets**: Public and Private
- **Route Tables and Internet Gateways**
- **NAT Gateways**
- **VPN Connections**
- **Direct Connect / ExpressRoute**
- **VPC Peering / VNet Peering**
- **Load Balancers**

### Security
- **Identity and Access Management (IAM)**
- **Security Groups and NACLs**
- **Network Security Groups (NSG)**
- **Web Application Firewall (WAF)**
- **DDoS Protection**
- **Encryption at Rest and in Transit**
- **Key Management Service (KMS)**
- **Secrets Manager**
- **Security Best Practices**

## 🚀 Project 4: Secure Multi-Tier Architecture

Deploy a production-grade secure architecture:
- **Public Subnet**: Load balancer, Bastion host
- **Private Subnet**: Application servers
- **Private Subnet**: Database servers
- **Security**: WAF, Security Groups, IAM roles
- **Monitoring**: CloudWatch/Azure Monitor
- **VPN**: Administrative access

**Security Features**:
- No direct internet access to app/database servers
- Bastion host for SSH/RDP access
- IAM roles instead of credentials
- Encrypted storage and transit
- Security group rules (least privilege)
- VPN for admin access
- CloudTrail/Activity logs

[Next: Phase 5](../Phase-5-DevOps-Automation/)
