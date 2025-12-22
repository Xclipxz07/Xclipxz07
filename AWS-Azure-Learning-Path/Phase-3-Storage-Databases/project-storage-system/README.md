# Project 3: Image/Document Management System

## 🎯 Project Overview

Build a complete data storage and management solution using multiple storage types and databases on AWS and Azure.

**What You'll Build**:
- Image and document upload system
- Metadata storage in relational database
- Fast session management with NoSQL
- Automated lifecycle management
- Multi-region replication
- Search and retrieval system

**Time Required**: 8-10 hours  
**Difficulty**: Intermediate  
**Cost**: $0-5/month with free tier

---

## 📋 Architecture

```
              [User Upload]
                    ↓
            [API Gateway/App Service]
                    ↓
        ┌───────────┼───────────┐
        ↓           ↓           ↓
[S3/Blob Storage] [RDS/SQL]  [DynamoDB/Cosmos]
   (Images)       (Metadata)   (Sessions)
        ↓
[Glacier/Archive]
 (Old files)
```

**Storage Types**:
- **Object Storage**: For images, documents, videos
- **Relational DB**: For structured metadata
- **NoSQL DB**: For session data and fast lookups
- **Archive Storage**: For old/infrequently accessed files

---

## 🚀 Application: Media Management Platform

**Features**:
- Upload images/documents (up to 10MB)
- Automatic thumbnail generation
- Metadata extraction and storage
- Full-text search
- Folder organization
- Share links with expiration
- Automatic archival after 90 days
- Multi-user support with sessions

**Technology Stack**:
- **Backend**: Python Flask/FastAPI
- **Storage**: S3/Blob + lifecycle policies
- **Database**: PostgreSQL (metadata)
- **NoSQL**: DynamoDB/Cosmos DB (sessions)
- **Cache**: ElastiCache/Azure Cache (optional)
- **Search**: Basic SQL search or ElasticSearch

---

## 📁 Project Structure

```
project-storage-system/
├── README.md
├── app-code/
│   ├── app.py (Flask API)
│   ├── storage_handler.py (S3/Blob operations)
│   ├── db_handler.py (Database operations)
│   ├── nosql_handler.py (DynamoDB/Cosmos operations)
│   ├── thumbnail_generator.py (Image processing)
│   ├── requirements.txt
│   └── config.py
├── aws/
│   ├── deploy.sh (Infrastructure setup)
│   ├── terraform/ (IaC option)
│   ├── lambda/ (Thumbnail generation)
│   └── cleanup.sh
└── azure/
    ├── deploy.sh
    ├── terraform/
    ├── function/ (Thumbnail generation)
    └── cleanup.sh
```

---

## 💻 Application Code

### Main API (app.py)

```python
from flask import Flask, request, jsonify, send_file
from storage_handler import StorageHandler
from db_handler import DatabaseHandler
from nosql_handler import SessionHandler
import uuid
from datetime import datetime, timedelta

app = Flask(__name__)

storage = StorageHandler()
db = DatabaseHandler()
sessions = SessionHandler()

@app.route('/upload', methods=['POST'])
def upload_file():
    """Upload a file to cloud storage"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    user_id = request.headers.get('X-User-ID')
    
    # Generate unique file ID
    file_id = str(uuid.uuid4())
    
    # Upload to storage
    file_url = storage.upload(file, file_id)
    
    # Generate thumbnail for images
    if file.content_type.startswith('image/'):
        thumbnail_url = storage.generate_thumbnail(file, file_id)
    else:
        thumbnail_url = None
    
    # Save metadata to database
    metadata = {
        'file_id': file_id,
        'filename': file.filename,
        'size': file.content_length,
        'content_type': file.content_type,
        'url': file_url,
        'thumbnail_url': thumbnail_url,
        'user_id': user_id,
        'uploaded_at': datetime.utcnow()
    }
    
    db.save_file_metadata(metadata)
    
    return jsonify({
        'file_id': file_id,
        'url': file_url,
        'thumbnail': thumbnail_url
    }), 201

@app.route('/files', methods=['GET'])
def list_files():
    """List all files for a user"""
    user_id = request.headers.get('X-User-ID')
    files = db.get_user_files(user_id)
    return jsonify({'files': files})

@app.route('/files/<file_id>', methods=['GET'])
def get_file(file_id):
    """Get file metadata and download URL"""
    metadata = db.get_file_metadata(file_id)
    if not metadata:
        return jsonify({'error': 'File not found'}), 404
    
    # Generate presigned URL for download
    download_url = storage.get_presigned_url(file_id, expires_in=3600)
    metadata['download_url'] = download_url
    
    return jsonify(metadata)

@app.route('/files/<file_id>', methods=['DELETE'])
def delete_file(file_id):
    """Delete a file"""
    # Delete from storage
    storage.delete(file_id)
    
    # Delete metadata
    db.delete_file_metadata(file_id)
    
    return jsonify({'message': 'File deleted'}), 200

@app.route('/search', methods=['GET'])
def search_files():
    """Search files by filename or tags"""
    query = request.args.get('q')
    user_id = request.headers.get('X-User-ID')
    
    results = db.search_files(user_id, query)
    return jsonify({'results': results})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### Storage Handler (AWS S3)

```python
import boto3
from PIL import Image
import io

class StorageHandler:
    def __init__(self):
        self.s3 = boto3.client('s3')
        self.bucket = 'my-storage-bucket'
    
    def upload(self, file, file_id):
        """Upload file to S3"""
        key = f"uploads/{file_id}/{file.filename}"
        
        self.s3.upload_fileobj(
            file,
            self.bucket,
            key,
            ExtraArgs={
                'ContentType': file.content_type,
                'Metadata': {
                    'file-id': file_id
                }
            }
        )
        
        return f"https://{self.bucket}.s3.amazonaws.com/{key}"
    
    def generate_thumbnail(self, file, file_id):
        """Generate thumbnail for images"""
        img = Image.open(file.stream)
        img.thumbnail((200, 200))
        
        buffer = io.BytesIO()
        img.save(buffer, format='JPEG')
        buffer.seek(0)
        
        key = f"thumbnails/{file_id}.jpg"
        self.s3.upload_fileobj(
            buffer,
            self.bucket,
            key,
            ExtraArgs={'ContentType': 'image/jpeg'}
        )
        
        return f"https://{self.bucket}.s3.amazonaws.com/{key}"
    
    def get_presigned_url(self, file_id, expires_in=3600):
        """Generate presigned URL for download"""
        key = f"uploads/{file_id}"
        
        url = self.s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': self.bucket, 'Key': key},
            ExpiresIn=expires_in
        )
        
        return url
    
    def delete(self, file_id):
        """Delete file from S3"""
        key = f"uploads/{file_id}"
        self.s3.delete_object(Bucket=self.bucket, Key=key)
```

---

## ☁️ AWS Deployment

### Services Used:
- **S3**: Object storage for files
- **S3 Glacier**: Archive storage
- **RDS PostgreSQL**: Metadata storage
- **DynamoDB**: Session storage
- **Lambda**: Thumbnail generation
- **API Gateway**: REST API
- **CloudWatch**: Monitoring

### Deployment Steps:

```bash
cd aws/

# 1. Create S3 bucket
aws s3 mb s3://my-storage-bucket-unique-name

# 2. Enable versioning
aws s3api put-bucket-versioning \
    --bucket my-storage-bucket-unique-name \
    --versioning-configuration Status=Enabled

# 3. Configure lifecycle policy (move to Glacier after 90 days)
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-storage-bucket-unique-name \
    --lifecycle-configuration file://lifecycle-policy.json

# 4. Create RDS database
aws rds create-db-instance \
    --db-instance-identifier storage-app-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --allocated-storage 20 \
    --master-username admin \
    --master-user-password SecurePass123!

# 5. Create DynamoDB table
aws dynamodb create-table \
    --table-name user-sessions \
    --attribute-definitions \
        AttributeName=session_id,AttributeType=S \
    --key-schema \
        AttributeName=session_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# 6. Deploy Lambda function for thumbnails
cd lambda/
zip function.zip thumbnail_generator.py
aws lambda create-function \
    --function-name thumbnail-generator \
    --runtime python3.9 \
    --role arn:aws:iam::ACCOUNT:role/lambda-role \
    --handler thumbnail_generator.lambda_handler \
    --zip-file fileb://function.zip

# 7. Configure S3 trigger
aws lambda create-event-source-mapping \
    --function-name thumbnail-generator \
    --event-source-arn arn:aws:s3:::my-storage-bucket-unique-name
```

### Lifecycle Policy (lifecycle-policy.json):

```json
{
  "Rules": [
    {
      "Id": "MoveToGlacier",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "NoncurrentVersionTransitions": [
        {
          "NoncurrentDays": 30,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
```

---

## ☁️ Azure Deployment

### Services Used:
- **Blob Storage**: Object storage
- **Archive Tier**: Long-term storage
- **Azure SQL Database**: Metadata
- **Cosmos DB**: Session storage
- **Azure Functions**: Thumbnail generation
- **API Management**: REST API
- **Azure Monitor**: Monitoring

### Deployment Steps:

```bash
cd azure/

# 1. Create storage account
az storage account create \
    --name mystorageaccount123 \
    --resource-group storage-app-rg \
    --location eastus \
    --sku Standard_LRS

# 2. Create blob container
az storage container create \
    --name uploads \
    --account-name mystorageaccount123 \
    --public-access off

# 3. Configure lifecycle management
az storage account management-policy create \
    --account-name mystorageaccount123 \
    --policy @lifecycle-policy.json

# 4. Create Azure SQL Database
az sql server create \
    --name storage-app-sql \
    --resource-group storage-app-rg \
    --location eastus \
    --admin-user sqladmin \
    --admin-password SecurePass123!

az sql db create \
    --resource-group storage-app-rg \
    --server storage-app-sql \
    --name metadata-db \
    --service-objective S0

# 5. Create Cosmos DB
az cosmosdb create \
    --name storage-app-cosmos \
    --resource-group storage-app-rg \
    --kind GlobalDocumentDB

# 6. Deploy Azure Function
cd function/
func azure functionapp publish storage-app-function
```

---

## 📊 Features Comparison

| Feature | AWS | Azure |
|---------|-----|-------|
| Setup Time | 30 min | 35 min |
| Storage Cost/GB | $0.023 | $0.018 |
| Database Cost | $15/mo | $15/mo |
| Scalability | Excellent | Excellent |
| Global Replication | S3 CRR | Blob Replication |

---

## 🎓 Learning Objectives

✅ Object storage (S3/Blob)  
✅ Relational databases (RDS/Azure SQL)  
✅ NoSQL databases (DynamoDB/Cosmos DB)  
✅ Storage lifecycle policies  
✅ Database migrations and backups  
✅ Presigned URLs and SAS tokens  
✅ Event-driven processing (Lambda/Functions)  
✅ Multi-tier data architecture

---

## ✅ Project Checklist

- [ ] S3/Blob storage configured
- [ ] Lifecycle policies set up
- [ ] RDS/Azure SQL database created
- [ ] DynamoDB/Cosmos DB table created
- [ ] Application deployed
- [ ] Upload functionality working
- [ ] Search functionality working
- [ ] Thumbnails generating
- [ ] Lifecycle archival tested
- [ ] Backup and recovery tested

---

**Next**: [Phase 4: Networking & Security](../../Phase-4-Networking-Security/)
