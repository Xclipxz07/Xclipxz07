# Project 6: Microservices E-commerce Platform

## 🎯 Project Overview

Build a complete microservices-based e-commerce platform using serverless functions and containers, deployed on both AWS and Azure.

**What You'll Build**:
- Event-driven microservices architecture
- Containerized services (Docker + Kubernetes)
- Serverless APIs (Lambda/Azure Functions)
- Service mesh for communication
- Message queues for async processing
- API Gateway for routing
- Distributed caching
- Monitoring and tracing

**Time Required**: 15-20 hours  
**Difficulty**: Advanced  
**Cost**: $10-25/month

---

## 📋 Microservices Architecture

```
                [API Gateway]
                      ↓
        ┌─────────────┼─────────────┐
        ↓             ↓             ↓
[User Service]  [Product Service] [Order Service]
(Containerized) (Containerized)   (Serverless)
        ↓             ↓             ↓
   [User DB]     [Product DB]   [Order DB]
(PostgreSQL)    (PostgreSQL)   (DynamoDB/Cosmos)
        └─────────────┬─────────────┘
                      ↓
            [Message Queue/Event Bus]
                      ↓
        ┌─────────────┼─────────────┐
        ↓             ↓             ↓
[Payment Service] [Notification] [Inventory]
  (Serverless)     (Serverless)  (Serverless)
```

**Services**:
1. **User Service** (ECS/AKS) - Authentication, profiles
2. **Product Service** (ECS/AKS) - Catalog management
3. **Order Service** (Lambda/Functions) - Order processing
4. **Payment Service** (Lambda/Functions) - Payment processing
5. **Notification Service** (Lambda/Functions) - Email/SMS
6. **Inventory Service** (Lambda/Functions) - Stock management

---

## 🐳 Containerized Services

### User Service (Node.js + Express)

**Dockerfile**:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Run application
CMD ["node", "server.js"]
```

**server.js**:

```javascript
const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port: 5432,
});

// Register user
app.post('/api/users/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Insert user
    const result = await pool.query(
      'INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3) RETURNING id, username, email',
      [username, email, hashedPassword]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// Login
app.post('/api/users/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // Get user
    const result = await pool.query(
      'SELECT * FROM users WHERE username = $1',
      [username]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const user = result.rows[0];
    
    // Verify password
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.json({ token, user: { id: user.id, username: user.username, email: user.email } });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Get user profile
app.get('/api/users/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, username, email, created_at FROM users WHERE id = $1',
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

// Health check
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'healthy', service: 'user-service' });
  } catch (error) {
    res.status(503).json({ status: 'unhealthy', error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`User service running on port ${PORT}`);
});
```

**Kubernetes Deployment**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  labels:
    app: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: myregistry.azurecr.io/user-service:latest
        ports:
        - containerPort: 3000
        env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: host
        - name: DB_NAME
          value: "users"
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: password
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: jwt-secret
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP
```

---

## ⚡ Serverless Services

### Order Service (AWS Lambda - Python)

**lambda_function.py**:

```python
import json
import os
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')
sns = boto3.client('sns')

table = dynamodb.Table(os.environ['ORDERS_TABLE'])
queue_url = os.environ['ORDER_QUEUE_URL']
topic_arn = os.environ['NOTIFICATION_TOPIC_ARN']

def lambda_handler(event, context):
    """
    Process order creation
    """
    try:
        # Parse request
        body = json.loads(event['body'])
        
        order_id = generate_order_id()
        order = {
            'orderId': order_id,
            'userId': body['userId'],
            'items': body['items'],
            'totalAmount': Decimal(str(body['totalAmount'])),
            'status': 'pending',
            'createdAt': int(time.time())
        }
        
        # Save to DynamoDB
        table.put_item(Item=order)
        
        # Send to payment queue
        sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps({
                'orderId': order_id,
                'amount': body['totalAmount'],
                'userId': body['userId']
            })
        )
        
        # Send notification
        sns.publish(
            TopicArn=topic_arn,
            Message=json.dumps({
                'type': 'order_created',
                'orderId': order_id,
                'userId': body['userId']
            })
        )
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'orderId': order_id,
                'status': 'pending'
            })
        }
        
    except Exception as e:
        print(f'Error: {str(e)}')
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Order creation failed'})
        }

def generate_order_id():
    import uuid
    return f"ORD-{uuid.uuid4().hex[:8].upper()}"
```

**SAM Template** (AWS):

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  OrderFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: order-service/
      Handler: lambda_function.lambda_handler
      Runtime: python3.9
      Timeout: 30
      MemorySize: 512
      Environment:
        Variables:
          ORDERS_TABLE: !Ref OrdersTable
          ORDER_QUEUE_URL: !Ref OrderQueue
          NOTIFICATION_TOPIC_ARN: !Ref NotificationTopic
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref OrdersTable
        - SQSSendMessagePolicy:
            QueueName: !GetAtt OrderQueue.QueueName
        - SNSPublishMessagePolicy:
            TopicName: !GetAtt NotificationTopic.TopicName
      Events:
        CreateOrder:
          Type: Api
          Properties:
            Path: /orders
            Method: post

  OrdersTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: orders
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: orderId
          AttributeType: S
      KeySchema:
        - AttributeName: orderId
          KeyType: HASH

  OrderQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: order-processing-queue
      VisibilityTimeout: 300

  NotificationTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: order-notifications
```

---

## 🚀 AWS Deployment

### EKS Deployment

```bash
#!/bin/bash
# Deploy microservices to AWS EKS

# 1. Create EKS cluster
eksctl create cluster \
  --name ecommerce-cluster \
  --version 1.27 \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 2 \
  --nodes-max 5 \
  --managed

# 2. Configure kubectl
aws eks update-kubeconfig --name ecommerce-cluster --region us-east-1

# 3. Create ECR repositories
aws ecr create-repository --repository-name user-service
aws ecr create-repository --repository-name product-service

# 4. Build and push Docker images
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

docker build -t user-service ./user-service
docker tag user-service:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/user-service:latest
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/user-service:latest

# 5. Deploy to Kubernetes
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/product-service.yaml
kubectl apply -f k8s/ingress.yaml

# 6. Deploy Lambda functions
cd lambda/
sam build
sam deploy --guided

# 7. Set up API Gateway
aws apigatewayv2 create-api \
  --name ecommerce-api \
  --protocol-type HTTP \
  --target arn:aws:lambda:us-east-1:ACCOUNT_ID:function:order-function
```

---

## ☁️ Azure Deployment

### AKS Deployment

```bash
#!/bin/bash
# Deploy microservices to Azure AKS

# 1. Create AKS cluster
az aks create \
  --resource-group ecommerce-rg \
  --name ecommerce-cluster \
  --node-count 3 \
  --node-vm-size Standard_B2s \
  --enable-addons monitoring \
  --generate-ssh-keys

# 2. Get credentials
az aks get-credentials --resource-group ecommerce-rg --name ecommerce-cluster

# 3. Create ACR
az acr create \
  --resource-group ecommerce-rg \
  --name ecommerceacr \
  --sku Basic

# 4. Attach ACR to AKS
az aks update \
  --resource-group ecommerce-rg \
  --name ecommerce-cluster \
  --attach-acr ecommerceacr

# 5. Build and push images
az acr build \
  --registry ecommerceacr \
  --image user-service:latest \
  ./user-service

# 6. Deploy to Kubernetes
kubectl apply -f k8s/user-service.yaml

# 7. Deploy Azure Functions
cd azure-functions/
func azure functionapp publish ecommerce-functions
```

---

## 🎓 Learning Objectives

✅ Microservices architecture patterns  
✅ Docker containerization  
✅ Kubernetes orchestration  
✅ Serverless functions (Lambda/Functions)  
✅ Event-driven design  
✅ API Gateway patterns  
✅ Service mesh concepts  
✅ Distributed tracing  
✅ Message queues (SQS/Service Bus)  
✅ Container registries (ECR/ACR)  

---

## ✅ Project Checklist

- [ ] User service containerized and deployed
- [ ] Product service containerized and deployed
- [ ] Order service as Lambda/Function
- [ ] Payment service as Lambda/Function
- [ ] Message queue configured
- [ ] API Gateway routing working
- [ ] Inter-service communication tested
- [ ] Distributed tracing enabled
- [ ] Monitoring dashboards created
- [ ] Load testing completed

---

**Next**: [Phase 7: Monitoring & Optimization](../../Phase-7-Monitoring-Optimization/)
