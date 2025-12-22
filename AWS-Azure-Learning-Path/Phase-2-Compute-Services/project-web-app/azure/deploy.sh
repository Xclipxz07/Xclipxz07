#!/bin/bash
# Azure Deployment Script for Phase 2 Project

set -e

echo "==================================="
echo "Azure Blog App Deployment"
echo "==================================="

# Variables
PROJECT_NAME="blog-app"
LOCATION="${AZURE_LOCATION:-eastus}"
RG_NAME="$PROJECT_NAME-rg"
VNET_NAME="$PROJECT_NAME-vnet"
DB_NAME="blogdb"
DB_USER="blogadmin"
DB_PASSWORD="BlogSecure123!"
VMSS_NAME="$PROJECT_NAME-vmss"

echo "Location: $LOCATION"
echo "Resource Group: $RG_NAME"

# Step 1: Create Resource Group
echo ""
echo "Step 1: Creating Resource Group..."
az group create --name $RG_NAME --location $LOCATION

# Step 2: Create VNet
echo ""
echo "Step 2: Creating Virtual Network..."
az network vnet create \
    --resource-group $RG_NAME \
    --name $VNET_NAME \
    --address-prefix 10.0.0.0/16 \
    --subnet-name frontend \
    --subnet-prefix 10.0.1.0/24

# Step 3: Create Database
echo ""
echo "Step 3: Creating PostgreSQL Database (10-15 minutes)..."
az postgres server create \
    --resource-group $RG_NAME \
    --name $PROJECT_NAME-db \
    --location $LOCATION \
    --admin-user $DB_USER \
    --admin-password $DB_PASSWORD \
    --sku-name B_Gen5_1 \
    --version 11

# Configure firewall for Azure services
az postgres server firewall-rule create \
    --resource-group $RG_NAME \
    --server $PROJECT_NAME-db \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# Create database
az postgres db create \
    --resource-group $RG_NAME \
    --server-name $PROJECT_NAME-db \
    --name $DB_NAME

DB_HOST="$PROJECT_NAME-db.postgres.database.azure.com"

echo "Database created: $DB_HOST"

# Step 4: Create Public IP for Load Balancer
echo ""
echo "Step 4: Creating Public IP..."
az network public-ip create \
    --resource-group $RG_NAME \
    --name lb-public-ip \
    --sku Standard

# Step 5: Create Load Balancer
echo ""
echo "Step 5: Creating Load Balancer..."
az network lb create \
    --resource-group $RG_NAME \
    --name $PROJECT_NAME-lb \
    --sku Standard \
    --public-ip-address lb-public-ip \
    --frontend-ip-name lb-frontend \
    --backend-pool-name lb-backend-pool

# Create health probe
az network lb probe create \
    --resource-group $RG_NAME \
    --lb-name $PROJECT_NAME-lb \
    --name health-probe \
    --protocol http \
    --port 5000 \
    --path /health

# Create load balancing rule
az network lb rule create \
    --resource-group $RG_NAME \
    --lb-name $PROJECT_NAME-lb \
    --name http-rule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 5000 \
    --frontend-ip-name lb-frontend \
    --backend-pool-name lb-backend-pool \
    --probe-name health-probe

# Step 6: Create NSG
echo ""
echo "Step 6: Creating Network Security Group..."
az network nsg create \
    --resource-group $RG_NAME \
    --name $PROJECT_NAME-nsg

az network nsg rule create \
    --resource-group $RG_NAME \
    --nsg-name $PROJECT_NAME-nsg \
    --name AllowHTTP \
    --priority 100 \
    --destination-port-ranges 5000 \
    --protocol Tcp \
    --access Allow

# Step 7: Create VM Scale Set with cloud-init
echo ""
echo "Step 7: Creating VM Scale Set..."

cat > /tmp/cloud-init.yaml << EOF
#cloud-config
package_upgrade: true
packages:
  - python3-pip
  - git

write_files:
  - path: /etc/systemd/system/blog-app.service
    content: |
      [Unit]
      Description=Blog Application
      After=network.target
      
      [Service]
      User=azureuser
      WorkingDirectory=/home/azureuser/blog-app
      Environment="DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST/$DB_NAME"
      Environment="SECRET_KEY=change-this-secret"
      ExecStart=/usr/local/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app
      
      [Install]
      WantedBy=multi-user.target

runcmd:
  - pip3 install flask flask-sqlalchemy flask-login psycopg2-binary gunicorn
  - mkdir -p /home/azureuser/blog-app
  - systemctl daemon-reload
  - systemctl enable blog-app
  - systemctl start blog-app
EOF

az vmss create \
    --resource-group $RG_NAME \
    --name $VMSS_NAME \
    --image UbuntuLTS \
    --vm-sku Standard_B1s \
    --instance-count 2 \
    --vnet-name $VNET_NAME \
    --subnet frontend \
    --lb $PROJECT_NAME-lb \
    --backend-pool-name lb-backend-pool \
    --custom-data /tmp/cloud-init.yaml \
    --admin-username azureuser \
    --generate-ssh-keys \
    --upgrade-policy-mode automatic

# Step 8: Configure Auto-scaling
echo ""
echo "Step 8: Configuring Auto-scaling..."
az monitor autoscale create \
    --resource-group $RG_NAME \
    --resource $VMSS_NAME \
    --resource-type Microsoft.Compute/virtualMachineScaleSets \
    --name autoscale-rule \
    --min-count 2 \
    --max-count 5 \
    --count 2

# Scale up rule
az monitor autoscale rule create \
    --resource-group $RG_NAME \
    --autoscale-name autoscale-rule \
    --condition "Percentage CPU > 70 avg 5m" \
    --scale out 1

# Scale down rule
az monitor autoscale rule create \
    --resource-group $RG_NAME \
    --autoscale-name autoscale-rule \
    --condition "Percentage CPU < 30 avg 5m" \
    --scale in 1

# Get Public IP
LB_IP=$(az network public-ip show \
    --resource-group $RG_NAME \
    --name lb-public-ip \
    --query ipAddress \
    --output tsv)

echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="
echo ""
echo "Application URL: http://$LB_IP"
echo "Database Host: $DB_HOST"
echo ""
echo "Wait 5-10 minutes for VMs to initialize..."
echo ""
echo "Test health check:"
echo "curl http://$LB_IP/health"
echo ""
echo "To cleanup: ./cleanup.sh"
