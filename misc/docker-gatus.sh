
# Using Docker
# From WSL VM in /home/gatus, we need DockerFile

docker build -t gatus-aviatrix .
docker tag gatus-aviatrix aweiss4876/gatus-aviatrix
docker push aweiss4876/gatus-aviatrix:latest


# Using Azure Container Registry
# Create ACR
az acr create --resource-group acr-lab --name aviatrixacr --sku Standard
# Anonymous pull enabled
az acr login --name aviatrixacr
docker build -t gatus-aviatrix .
docker tag gatus-aviatrix aviatrixacr.azurecr.io/gatus-aviatrix
docker push aviatrixacr.azurecr.io/aviatrix/gatus-aviatrix
az acr update --name aviatrixacr --anonymous-pull-enabled
