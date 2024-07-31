# From WSL VM in /home/gatus, we need DockerFile

docker build -t gatus-aviatrix .
docker tag gatus-aviatrix aweiss4876/gatus-aviatrix
docker push aweiss4876/gatus-aviatrix:latest