# Deploy Static Website on AWS (S3 + CloudFront)

## 📋 Project Overview

In this project, you'll deploy a static website using Amazon S3 for storage and Amazon CloudFront for content delivery. This is one of the most cost-effective and scalable ways to host a static website.

## 🎯 What You'll Learn

- Creating and configuring S3 buckets
- Enabling static website hosting
- Setting up bucket policies for public access
- Creating CloudFront distribution
- Configuring custom domains
- Enabling HTTPS with AWS Certificate Manager
- Deploying updates efficiently

## 🏗️ Architecture

```
User Request
     ↓
[Route 53] - DNS (optional)
     ↓
[CloudFront] - CDN with SSL/TLS
     ↓
[S3 Bucket] - Static Website Files
```

## 📦 Prerequisites

- AWS account with Free Tier
- AWS CLI installed and configured
- A static website (HTML, CSS, JS files)
- (Optional) A custom domain name

## 💾 Sample Website

If you don't have a website, use this simple template:

**index.html**:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Cloud Portfolio</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header>
        <h1>Welcome to My Cloud Journey</h1>
        <p>Learning AWS & Azure</p>
    </header>
    
    <main>
        <section class="hero">
            <h2>About This Project</h2>
            <p>This website is hosted on AWS S3 and delivered via CloudFront CDN.</p>
        </section>
        
        <section class="skills">
            <h2>Cloud Skills</h2>
            <ul>
                <li>AWS S3 - Object Storage</li>
                <li>CloudFront - Content Delivery Network</li>
                <li>Route 53 - DNS Management</li>
                <li>ACM - SSL/TLS Certificates</li>
            </ul>
        </section>
        
        <section class="projects">
            <h2>My Cloud Projects</h2>
            <div class="project-card">
                <h3>Phase 1: Cloud Fundamentals</h3>
                <p>Static website hosting on AWS and Azure</p>
            </div>
        </section>
    </main>
    
    <footer>
        <p>&copy; 2025 My Cloud Portfolio | Hosted on AWS</p>
    </footer>
    
    <script src="script.js"></script>
</body>
</html>
```

**styles.css**:
```css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: #333;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

header {
    background: rgba(255, 255, 255, 0.95);
    padding: 2rem;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

header h1 {
    color: #667eea;
    margin-bottom: 0.5rem;
}

main {
    max-width: 1200px;
    margin: 2rem auto;
    padding: 0 1rem;
}

section {
    background: white;
    padding: 2rem;
    margin-bottom: 2rem;
    border-radius: 10px;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.hero {
    text-align: center;
}

.skills ul {
    list-style: none;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1rem;
    margin-top: 1rem;
}

.skills li {
    background: #f8f9fa;
    padding: 1rem;
    border-radius: 5px;
    border-left: 4px solid #667eea;
}

.project-card {
    background: #f8f9fa;
    padding: 1.5rem;
    border-radius: 5px;
    margin-top: 1rem;
}

.project-card h3 {
    color: #667eea;
    margin-bottom: 0.5rem;
}

footer {
    text-align: center;
    padding: 2rem;
    color: white;
}

@media (max-width: 768px) {
    .skills ul {
        grid-template-columns: 1fr;
    }
}
```

**script.js**:
```javascript
// Simple script to demonstrate JavaScript loading
document.addEventListener('DOMContentLoaded', function() {
    console.log('Website loaded successfully!');
    console.log('Hosting: AWS S3 + CloudFront');
    
    // Add animation to project cards
    const cards = document.querySelectorAll('.project-card');
    cards.forEach((card, index) => {
        setTimeout(() => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            card.style.transition = 'all 0.5s ease';
            
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, 100);
        }, index * 200);
    });
});
```

**error.html**:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        h1 { font-size: 72px; margin: 0; }
        p { font-size: 24px; }
        a { color: white; text-decoration: underline; }
    </style>
</head>
<body>
    <h1>404</h1>
    <p>Page Not Found</p>
    <a href="/">Go Home</a>
</body>
</html>
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Create S3 Bucket

#### Option A: Using AWS Console

1. **Go to S3 Console**: https://console.aws.amazon.com/s3/
2. **Click "Create bucket"**
3. **Configure bucket**:
   - Bucket name: `my-portfolio-website-12345` (must be globally unique)
   - Region: Choose closest to your users (e.g., `us-east-1`)
   - Uncheck "Block all public access"
   - Acknowledge warning
   - Leave other settings as default
4. **Click "Create bucket"**

#### Option B: Using AWS CLI

```bash
# Set variables
BUCKET_NAME="my-portfolio-website-12345"  # Change this
REGION="us-east-1"

# Create bucket
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Enable static website hosting
aws s3 website s3://$BUCKET_NAME \
    --index-document index.html \
    --error-document error.html
```

---

### Step 2: Configure Bucket Policy for Public Access

Create a file named `bucket-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-portfolio-website-12345/*"
    }
  ]
}
```

**Apply the policy**:

#### Using Console:
1. Go to your bucket
2. Click "Permissions" tab
3. Scroll to "Bucket policy"
4. Paste the policy
5. Click "Save changes"

#### Using CLI:
```bash
# Apply bucket policy
aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file://bucket-policy.json
```

---

### Step 3: Upload Website Files

#### Using Console:
1. Go to your bucket
2. Click "Upload"
3. Drag and drop your files
4. Click "Upload"

#### Using CLI:
```bash
# Upload all files from local directory
aws s3 sync ./website/ s3://$BUCKET_NAME/

# Verify upload
aws s3 ls s3://$BUCKET_NAME/
```

#### Using CLI with Cache Control (Recommended):
```bash
# HTML files (short cache)
aws s3 cp index.html s3://$BUCKET_NAME/ \
    --cache-control "max-age=300" \
    --content-type "text/html"

# CSS and JS files (longer cache)
aws s3 cp styles.css s3://$BUCKET_NAME/ \
    --cache-control "max-age=86400" \
    --content-type "text/css"

aws s3 cp script.js s3://$BUCKET_NAME/ \
    --cache-control "max-age=86400" \
    --content-type "application/javascript"

# Images (longest cache)
aws s3 cp images/ s3://$BUCKET_NAME/images/ \
    --recursive \
    --cache-control "max-age=2592000"
```

---

### Step 4: Test S3 Website Endpoint

Get your website URL:

```bash
# Get website endpoint
echo "http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
```

Example: `http://my-portfolio-website-12345.s3-website-us-east-1.amazonaws.com`

**Test in browser**: Your website should load!

---

### Step 5: Create CloudFront Distribution

CloudFront provides:
- Global content delivery
- HTTPS support
- Better performance
- DDoS protection

#### Using Console:

1. **Go to CloudFront Console**: https://console.aws.amazon.com/cloudfront/
2. **Click "Create distribution"**
3. **Configure**:
   - Origin domain: Select your S3 bucket
   - Origin path: Leave empty
   - Name: Auto-filled
   - Origin access: Public
   - Viewer protocol policy: Redirect HTTP to HTTPS
   - Allowed HTTP methods: GET, HEAD
   - Cache policy: CachingOptimized
   - Default root object: `index.html`
4. **Click "Create distribution"**

Wait 10-15 minutes for deployment.

#### Using CLI:

Create `cloudfront-config.json`:

```json
{
  "CallerReference": "my-website-1234567890",
  "Comment": "CloudFront distribution for my portfolio",
  "Enabled": true,
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-my-portfolio-website-12345",
        "DomainName": "my-portfolio-website-12345.s3.us-east-1.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultRootObject": "index.html",
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-my-portfolio-website-12345",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "Compress": true,
    "MinTTL": 0,
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    }
  }
}
```

```bash
# Create distribution
aws cloudfront create-distribution --distribution-config file://cloudfront-config.json
```

---

### Step 6: Get CloudFront URL

After distribution is deployed:

```bash
# List distributions
aws cloudfront list-distributions \
    --query 'DistributionList.Items[*].[DomainName,Status]' \
    --output table
```

Your CloudFront URL: `https://d1234abcd5678.cloudfront.net`

**Test**: Visit the CloudFront URL in your browser!

---

### Step 7: (Optional) Configure Custom Domain

If you have a domain name:

#### Step 7.1: Request SSL Certificate

1. **Go to ACM Console** (in us-east-1 region for CloudFront)
2. **Request certificate**
3. **Add domain names**: `yourdomain.com` and `www.yourdomain.com`
4. **Choose DNS validation**
5. **Create CNAME records** in your domain DNS
6. **Wait for validation** (usually 5-30 minutes)

#### Step 7.2: Add Custom Domain to CloudFront

1. **Go to CloudFront distribution**
2. **Edit settings**
3. **Alternate domain names (CNAMEs)**: Add `www.yourdomain.com`
4. **SSL certificate**: Select your ACM certificate
5. **Save changes**

#### Step 7.3: Update DNS Records

In your domain registrar or Route 53:

```
Type: CNAME
Name: www
Value: d1234abcd5678.cloudfront.net
```

Or use Route 53 Alias record for apex domain.

---

## 📊 Cost Estimation

### S3 Costs (First 12 months - Free Tier)
- **Storage**: 5 GB free
- **Requests**: 20,000 GET requests free, 2,000 PUT requests free
- **Data transfer**: 100 GB free out to internet

**Typical personal website**: $0/month (within free tier)

### CloudFront Costs (First 12 months - Free Tier)
- **Data transfer out**: 1 TB free
- **HTTP/HTTPS requests**: 10,000,000 free

**Typical personal website**: $0/month (within free tier)

### After Free Tier
- **S3**: ~$0.50-2/month
- **CloudFront**: ~$1-5/month
- **Route 53** (if used): $0.50/month per hosted zone

---

## 🔄 Updating Your Website

### Simple Update Process

```bash
# Update files locally, then sync
aws s3 sync ./website/ s3://$BUCKET_NAME/ --delete

# Invalidate CloudFront cache (if needed)
aws cloudfront create-invalidation \
    --distribution-id YOUR_DISTRIBUTION_ID \
    --paths "/*"
```

**Note**: First 1,000 invalidations per month are free, then $0.005 per path.

---

## ✅ Testing Checklist

- [ ] Website loads from S3 endpoint
- [ ] Website loads from CloudFront URL
- [ ] HTTPS works (no certificate errors)
- [ ] All pages and resources load correctly
- [ ] Mobile responsive design works
- [ ] 404 error page works
- [ ] Performance is good (test with GTmetrix)
- [ ] Custom domain works (if configured)

---

## 🔧 Troubleshooting

### Issue: 403 Forbidden Error

**Solution**:
1. Check bucket policy is applied correctly
2. Verify "Block all public access" is OFF
3. Ensure files have correct permissions

### Issue: 404 Not Found

**Solution**:
1. Check Default Root Object in CloudFront is set to `index.html`
2. Verify files are uploaded correctly
3. Check file names are case-sensitive

### Issue: Changes Not Reflecting

**Solution**:
1. Clear browser cache
2. Create CloudFront invalidation
3. Wait for propagation (can take 10-15 minutes)

### Issue: SSL Certificate Error

**Solution**:
1. Ensure certificate is in us-east-1 region
2. Verify certificate is validated
3. Check CNAME matches certificate

---

## 🎯 Best Practices

1. **Enable CloudFront Compression**: Reduce file sizes
2. **Set Cache-Control Headers**: Optimize caching
3. **Use CloudFront Functions**: For URL redirects
4. **Enable CloudFront Logging**: For analytics
5. **Set up CloudWatch Alarms**: For monitoring
6. **Regular Backups**: Keep local copies
7. **Version Control**: Use Git for your website
8. **Cost Alerts**: Set up billing alerts

---

## 📈 Performance Optimization

### 1. Compress Images
```bash
# Use tools like ImageOptim, TinyPNG
# Or use CLI tools
imagemin input/*.png --out-dir=output
```

### 2. Minify CSS and JavaScript
```bash
# Use build tools
npm install -g minify
minify styles.css > styles.min.css
minify script.js > script.min.js
```

### 3. Enable Gzip Compression
CloudFront automatically compresses supported file types.

### 4. Set Long Cache Times
```bash
# For static assets that don't change often
aws s3 cp styles.css s3://$BUCKET_NAME/ \
    --cache-control "max-age=31536000"
```

---

## 🔒 Security Best Practices

1. **Never commit AWS credentials to Git**
2. **Use IAM users with limited permissions**
3. **Enable MFA on AWS account**
4. **Use HTTPS only (enforce via CloudFront)**
5. **Regular security audits**
6. **Keep dependencies updated**

---

## 📚 Additional Resources

- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS Free Tier Details](https://aws.amazon.com/free/)

---

## 🎉 Congratulations!

You've successfully deployed a static website on AWS! This is a foundational skill for cloud development.

**Next**: Try the same project on Azure to compare the platforms!

→ [Azure Static Website Guide](../azure-static-website/README.md)

