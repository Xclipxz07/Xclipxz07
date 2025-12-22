# Deploy Static Website on Azure (Blob Storage + CDN)

## 📋 Project Overview

In this project, you'll deploy a static website using Azure Blob Storage and Azure CDN for content delivery. This is Azure's equivalent to AWS S3 + CloudFront and is equally cost-effective and scalable.

## 🎯 What You'll Learn

- Creating Azure Storage Accounts
- Enabling static website hosting on Blob Storage
- Configuring public access
- Creating Azure CDN endpoint
- Configuring custom domains
- Enabling HTTPS
- Deploying and updating websites

## 🏗️ Architecture

```
User Request
     ↓
[Azure DNS] - DNS (optional)
     ↓
[Azure CDN] - Content Delivery with SSL/TLS
     ↓
[Blob Storage] - Static Website Files ($web container)
```

## 📦 Prerequisites

- Azure account with $200 free credit
- Azure CLI installed and configured
- A static website (HTML, CSS, JS files)
- (Optional) A custom domain name

## 💾 Sample Website

Use the same sample website from the AWS guide, or create your own.

---

## 🚀 Step-by-Step Implementation

### Step 1: Create Resource Group

Resource groups are logical containers for Azure resources.

#### Using Azure Portal:
1. Go to Azure Portal: https://portal.azure.com
2. Click "Resource groups"
3. Click "+ Create"
4. Fill in:
   - Subscription: Your subscription
   - Resource group name: `portfolio-website-rg`
   - Region: `East US` (or closest to you)
5. Click "Review + Create"
6. Click "Create"

#### Using Azure CLI:
```bash
# Set variables
RG_NAME="portfolio-website-rg"
LOCATION="eastus"
STORAGE_ACCOUNT="myportfoliostorage123"  # Must be globally unique, lowercase
CDN_PROFILE="portfolio-cdn-profile"
CDN_ENDPOINT="myportfolio123"  # Must be globally unique

# Login to Azure
az login

# Create resource group
az group create \
    --name $RG_NAME \
    --location $LOCATION
```

---

### Step 2: Create Storage Account

#### Using Portal:
1. Go to "Storage accounts"
2. Click "+ Create"
3. Configure:
   - Resource group: `portfolio-website-rg`
   - Storage account name: `myportfoliostorage123` (must be unique)
   - Region: Same as resource group
   - Performance: Standard
   - Redundancy: LRS (Locally Redundant Storage)
4. Click "Review + Create"
5. Click "Create"

#### Using CLI:
```bash
# Create storage account
az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RG_NAME \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access true
```

Wait for creation to complete (1-2 minutes).

---

### Step 3: Enable Static Website Hosting

#### Using Portal:
1. Go to your storage account
2. In left menu, find "Static website" under "Data management"
3. Click "Enabled"
4. Set:
   - Index document name: `index.html`
   - Error document path: `error.html`
5. Click "Save"
6. Note the **Primary endpoint** URL

#### Using CLI:
```bash
# Enable static website hosting
az storage blob service-properties update \
    --account-name $STORAGE_ACCOUNT \
    --static-website \
    --404-document error.html \
    --index-document index.html

# Get the static website URL
az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RG_NAME \
    --query "primaryEndpoints.web" \
    --output tsv
```

The URL will look like: `https://myportfoliostorage123.z13.web.core.windows.net/`

---

### Step 4: Upload Website Files

When you enable static website hosting, Azure creates a special container called `$web`.

#### Using Portal:
1. Go to your storage account
2. Click "Containers" under "Data storage"
3. Click on `$web` container
4. Click "Upload"
5. Select your files (index.html, styles.css, script.js, error.html)
6. Click "Upload"

#### Using CLI:
```bash
# Upload all files from local directory
az storage blob upload-batch \
    --account-name $STORAGE_ACCOUNT \
    --source ./website/ \
    --destination '$web' \
    --auth-mode login

# Verify upload
az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --container-name '$web' \
    --output table \
    --auth-mode login
```

#### Upload with Cache Control (Recommended):
```bash
# HTML files (short cache)
az storage blob upload \
    --account-name $STORAGE_ACCOUNT \
    --container-name '$web' \
    --name index.html \
    --file ./website/index.html \
    --content-cache-control "max-age=300" \
    --content-type "text/html" \
    --auth-mode login

# CSS files (longer cache)
az storage blob upload \
    --account-name $STORAGE_ACCOUNT \
    --container-name '$web' \
    --name styles.css \
    --file ./website/styles.css \
    --content-cache-control "max-age=86400" \
    --content-type "text/css" \
    --auth-mode login

# JavaScript files
az storage blob upload \
    --account-name $STORAGE_ACCOUNT \
    --container-name '$web' \
    --name script.js \
    --file ./website/script.js \
    --content-cache-control "max-age=86400" \
    --content-type "application/javascript" \
    --auth-mode login
```

---

### Step 5: Test Blob Storage Website

Open your browser and visit the static website URL:
```
https://myportfoliostorage123.z13.web.core.windows.net/
```

Your website should load! ✅

---

### Step 6: Create Azure CDN Profile

Azure CDN provides:
- Global content delivery
- HTTPS support
- Better performance
- Custom domain support
- DDoS protection

#### Using Portal:
1. Search for "CDN profiles"
2. Click "+ Create"
3. Configure:
   - Resource group: `portfolio-website-rg`
   - Name: `portfolio-cdn-profile`
   - Pricing tier: **Microsoft CDN (classic)** or **Standard Akamai**
   - Create a new CDN endpoint: ✓
   - CDN endpoint name: `myportfolio123` (must be unique)
   - Origin type: Custom origin
   - Origin hostname: Your storage static website URL (without https://)
     - Example: `myportfoliostorage123.z13.web.core.windows.net`
4. Click "Review + Create"
5. Click "Create"

#### Using CLI:
```bash
# Create CDN profile
az cdn profile create \
    --name $CDN_PROFILE \
    --resource-group $RG_NAME \
    --sku Standard_Microsoft

# Get storage website endpoint (remove https:// prefix)
ORIGIN_HOST=$(az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RG_NAME \
    --query "primaryEndpoints.web" \
    --output tsv | sed 's|https://||' | sed 's|/$||')

# Create CDN endpoint
az cdn endpoint create \
    --name $CDN_ENDPOINT \
    --profile-name $CDN_PROFILE \
    --resource-group $RG_NAME \
    --origin $ORIGIN_HOST \
    --origin-host-header $ORIGIN_HOST \
    --enable-compression true \
    --query-string-caching-behavior IgnoreQueryString

echo "CDN Endpoint: https://$CDN_ENDPOINT.azureedge.net"
```

Wait for CDN deployment (10-15 minutes).

---

### Step 7: Configure CDN Settings

#### Enable Compression:
1. Go to your CDN endpoint
2. Click "Compression" under Settings
3. Enable compression
4. Add MIME types:
   - text/html
   - text/css
   - application/javascript
   - application/json
5. Save

#### Configure Caching Rules:
1. Go to "Caching rules"
2. Set query string caching behavior
3. Configure cache duration

---

### Step 8: Test CDN Endpoint

Visit your CDN URL:
```
https://myportfolio123.azureedge.net/
```

Your website should load through CDN! ✅

---

### Step 9: (Optional) Configure Custom Domain with HTTPS

#### Step 9.1: Prepare Your Domain

You need to own a domain name and have access to DNS settings.

#### Step 9.2: Create CNAME Record

In your domain DNS settings, create:
```
Type: CNAME
Name: www (or your subdomain)
Value: myportfolio123.azureedge.net
TTL: 3600
```

Wait for DNS propagation (5 minutes to 24 hours).

#### Step 9.3: Add Custom Domain to CDN

##### Using Portal:
1. Go to your CDN endpoint
2. Click "+ Custom domain"
3. Enter your custom hostname: `www.yourdomain.com`
4. Click "Add"

##### Using CLI:
```bash
# Add custom domain
az cdn custom-domain create \
    --endpoint-name $CDN_ENDPOINT \
    --profile-name $CDN_PROFILE \
    --resource-group $RG_NAME \
    --name www-yourdomain-com \
    --hostname www.yourdomain.com
```

#### Step 9.4: Enable HTTPS

##### Using Portal:
1. Go to your CDN endpoint
2. Click on your custom domain
3. Turn on "Custom domain HTTPS"
4. Certificate management type: **CDN managed**
5. Click "Save"

Wait 6-8 hours for certificate provisioning.

##### Using CLI:
```bash
# Enable HTTPS
az cdn custom-domain enable-https \
    --endpoint-name $CDN_ENDPOINT \
    --profile-name $CDN_PROFILE \
    --resource-group $RG_NAME \
    --name www-yourdomain-com \
    --min-tls-version 1.2
```

---

## 📊 Cost Estimation

### Azure Storage (First Month - Free Credits)
- **Storage**: First 5 GB free
- **Requests**: 20,000 free
- **Data transfer**: First 100 GB free

**Typical website**: $0.02-0.50/month after credits

### Azure CDN (First Month - Free Credits)
- **Data transfer**: First 10 GB free
- **HTTP/HTTPS requests**: Included

**Typical website**: $0.10-2/month after credits

### After Free Credits Expire
- **Storage**: ~$0.02-1/month
- **CDN**: ~$0.50-5/month
- **Total**: ~$1-6/month for typical portfolio site

---

## 🔄 Updating Your Website

### Simple Update Process

```bash
# Update files locally, then sync
az storage blob upload-batch \
    --account-name $STORAGE_ACCOUNT \
    --source ./website/ \
    --destination '$web' \
    --auth-mode login \
    --overwrite

# Purge CDN cache (if needed)
az cdn endpoint purge \
    --resource-group $RG_NAME \
    --profile-name $CDN_PROFILE \
    --name $CDN_ENDPOINT \
    --content-paths '/*'
```

---

## ✅ Testing Checklist

- [ ] Website loads from Blob Storage URL
- [ ] Website loads from CDN endpoint
- [ ] HTTPS works on CDN
- [ ] All pages and resources load correctly
- [ ] Mobile responsive design works
- [ ] 404 error page works
- [ ] Performance is good (test with GTmetrix)
- [ ] Custom domain works (if configured)
- [ ] HTTPS works on custom domain (if configured)

---

## 🔧 Troubleshooting

### Issue: 404 Not Found on CDN

**Solution**:
1. Wait for CDN propagation (10-15 minutes)
2. Check origin hostname is correct
3. Verify files are in `$web` container
4. Purge CDN cache

### Issue: Custom Domain Not Working

**Solution**:
1. Verify CNAME record is correct
2. Wait for DNS propagation
3. Check domain validation status
4. Ensure no conflicting DNS records

### Issue: HTTPS Certificate Not Provisioning

**Solution**:
1. Verify CNAME record is correct
2. Wait up to 8 hours
3. Check domain validation
4. Contact Azure support if still failing

### Issue: Changes Not Reflecting

**Solution**:
1. Purge CDN cache
2. Clear browser cache
3. Use incognito/private browsing
4. Wait for cache TTL expiration

---

## 🎯 Best Practices

1. **Use Standard tier CDN**: Better features and performance
2. **Enable Compression**: Reduce bandwidth
3. **Set Cache-Control Headers**: Optimize caching
4. **Use Custom Domain**: Professional appearance
5. **Enable HTTPS**: Security and SEO
6. **Set up Monitoring**: Track usage and issues
7. **Regular Backups**: Keep local copies
8. **Version Control**: Use Git
9. **Cost Alerts**: Monitor spending

---

## 📈 Performance Optimization

### 1. Compress Images
Same as AWS guide - use ImageOptim, TinyPNG, etc.

### 2. Minify CSS and JavaScript
Same as AWS guide - use minification tools.

### 3. Enable CDN Compression
Already done in Step 7.

### 4. Set Long Cache Times
Use Cache-Control headers when uploading files.

---

## 🔒 Security Best Practices

1. **Never commit credentials to Git**
2. **Use Azure AD authentication**
3. **Enable MFA on Azure account**
4. **Use HTTPS only**
5. **Limit storage account access**
6. **Enable Azure Security Center**
7. **Regular security audits**
8. **Keep dependencies updated**

---

## 🔍 Comparison: Azure vs AWS

| Feature | Azure | AWS |
|---------|-------|-----|
| Storage Service | Blob Storage | S3 |
| CDN Service | Azure CDN | CloudFront |
| DNS Service | Azure DNS | Route 53 |
| Certificate | Free (CDN managed) | ACM (Free) |
| Setup Complexity | Similar | Similar |
| Free Tier | $200 credit + free services | 12-month free tier |
| Pricing (after free) | ~$1-6/month | ~$1-5/month |

**Verdict**: Both platforms are excellent for static hosting. Choose based on:
- Existing cloud infrastructure
- Team expertise
- Integration requirements
- Geographic locations

---

## 📚 Additional Resources

- [Azure Static Website Hosting](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website)
- [Azure CDN Documentation](https://docs.microsoft.com/en-us/azure/cdn/)
- [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)

---

## 🎉 Congratulations!

You've successfully deployed a static website on Azure! Now you can compare it with your AWS deployment.

### Key Differences You Learned:
- ✅ Resource Groups (Azure) vs No equivalent (AWS)
- ✅ Blob Storage ($web) vs S3 buckets
- ✅ Azure CDN vs CloudFront
- ✅ Azure CLI vs AWS CLI

**Next Steps**:
1. Compare costs between Azure and AWS
2. Test performance from different locations
3. Try deploying the same site to both platforms
4. Document differences and preferences

→ [Continue to Phase 2: Compute Services](../../Phase-2-Compute-Services/)

