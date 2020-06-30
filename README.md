# OpenGP EHR system
OpenGP is an OpenMRS distribution aimed at GPs. Read more about what OpenMRS is [here](https://openmrs.org) and more about distributions in 
context of OpenMRS [here](https://wiki.openmrs.org/display/docs/OpenMRS+Distributions)

## Demo
There a deployment of OpenGP found at [demo.opengp.org](http://demo.opengp.org) - at the moment is just a vanilla OpenMRS distributions
with no enhancements

## Deployment
The demo is deployed on AWS using ECS. For provisioning and deployment terraform is used.

## Next Steps
* Implementing the [GPConnect API](https://digital.nhs.uk/services/gp-connect) - which is an NHS-tailored extensions of [FHIR APIs](https://digital.nhs.uk/services/fhir-apis) aimed at GPs

## Developer setup

Prerequisites:

1. Docker https://docs.docker.com/get-docker/
2. Java 8+ 
3. Maven https://maven.apache.org/install.html
4. OpenMRS SDK https://wiki.openmrs.org/display/docs/OpenMRS+SDK#OpenMRSSDK-Installation (the sdk is a maven plugin)  
5. (Optionally) Postman https://www.postman.com/downloads/

Starting OpenGP locally:
1. `mvn openmrs-sdk:build-distro -Ddir=docker`
2. `docker-compose up -d` in the`docker` folder
3. Go to `localhost:8080/openmrs` wait to be redirected to a login page
4. Use `admin` and ask for the default password

