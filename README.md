# OpenGP EHR system
OpenGP is an OpenMRS distribution aimed at General Practitioners (GPs).

## Context
* [OpenMRS](https://openmrs.org) 
* [OpenMRS distributions](https://wiki.openmrs.org/display/docs/OpenMRS+Distributions)
* [NHS and General Practitioners](https://www.healthcareers.nhs.uk/explore-roles/doctors/roles-doctors/general-practice-gp)

## Demo
A deployment of OpenGP can be found at [demo.opengp.org](http://demo.opengp.org).

## Deployment
The demo is deployed on AWS using ECS. For provisioning and deployment terraform is used.

## Next Steps
* Implementing the [GPConnect API](https://digital.nhs.uk/services/gp-connect) - which is an NHS-tailored extensions of [FHIR APIs](https://digital.nhs.uk/services/fhir-apis) aimed at GPs

## Developer setup

### Prerequisites:

1. [Docker](https://docs.docker.com/get-docker/)
2. [Java 8+](https://java.com/en/download/help/download_options.xml)
3. [Maven](https://maven.apache.org/install.html)
4. [OpenMRS SDK](https://wiki.openmrs.org/display/docs/OpenMRS+SDK#OpenMRSSDK-Installation) (the sdk is a maven plugin)  
5. [Postman](https://www.postman.com/downloads/) (Optional) 

### On Starting OpenGp locally:

Starting OpenGp for the ***first*** time:
> See our [wiki](https://github.com/Open-GP/opengp-distro/wiki/Onboarding-Developer-Setup)

<br/>

Starting OpenGp ***when doing QA***:

In ```opengp-distro/docker```:

> Make sure Maven builds the most up to date version of the code
```shell script
mvn openmrs-sdk:build-distro -Ddir=docker
```
<br/>

> Delete the volumes to build the distro correctly
```shell script
docker-compose down -v
```
<br/>

> Then follow the steps below

<br/>

Starting OpenGp ***subsequent times*** after code changes:

In ```opengp-distro/docker```:

> Check the containers currently running
```shell script
cd docker && docker-compose ps
```
<br/>

> Stop the web container & rebuild with new config
```shell script
docker-compose stop web && docker-compose rm -f web
```
<br/>

> Start the container
```shell script
cd .. && sh update_gpconnect_and_start.sh "../openmrs-module-gpconnect" web
```
<br/>

> Check the docker logs
```shell script
cd docker && docker-compose logs -f
```
