# NGINX-LAB

# Deployment

Create the RG : az group create -n MyResourceGroupName -l MyLocation

Deploy : az deployment group create -n deploy-nginx --resource-group MyResourceGroupName --template-file ./main.bicep