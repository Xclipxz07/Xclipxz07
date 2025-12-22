# Phase 6: Serverless & Containers (Advanced)

**Duration**: 3-4 weeks | **Level**: Advanced

## 🎯 Overview

Learn serverless computing and container orchestration. Build modern, scalable applications.

## 📚 Topics Covered

### Serverless
- **AWS Lambda** and **Azure Functions**
- **API Gateway** and **Azure API Management**
- **Event-Driven Architecture**
- **Step Functions** and **Logic Apps**
- **Serverless Framework**
- **Cold Starts and Optimization**
- **Cost Optimization**

### Containers
- **Docker Fundamentals**
- **Container Images**
- **Docker Compose**
- **Amazon ECS** and **Azure Container Instances**
- **Amazon EKS** and **Azure AKS**
- **Kubernetes Basics**
- **Helm Charts**
- **Service Mesh (Istio)**

## 🚀 Project 6: Microservices E-commerce Platform

Build event-driven microservices architecture:

**Microservices**:
1. **User Service** (Containerized)
   - User registration, authentication
   - Deployed on ECS/AKS

2. **Product Service** (Containerized)
   - Product catalog management
   - Deployed on ECS/AKS

3. **Order Service** (Serverless)
   - Order processing
   - Lambda/Functions triggered by events

4. **Payment Service** (Serverless)
   - Payment processing
   - Lambda/Functions with SQS/Service Bus

5. **Notification Service** (Serverless)
   - Email/SMS notifications
   - Lambda/Functions with SNS/Event Grid

**Architecture**:
- API Gateway for routing
- DynamoDB/Cosmos DB for data
- SQS/Service Bus for messaging
- S3/Blob for product images
- CloudWatch/Azure Monitor for logging

**Technologies**:
- Docker, Kubernetes
- Lambda, API Gateway, DynamoDB
- Azure Functions, API Management, Cosmos DB
- Terraform for infrastructure

[Next: Phase 7](../Phase-7-Monitoring-Optimization/)
