#!/bin/bash
# Azure Cleanup Script

echo "Cleaning up Azure resources..."

RG_NAME="blog-app-rg"

echo "Deleting Resource Group: $RG_NAME"
echo "This will delete all resources in the group..."

az group delete --name $RG_NAME --yes --no-wait

echo "Cleanup initiated. Resources will be deleted in the background."
echo "Check status: az group show --name $RG_NAME"
