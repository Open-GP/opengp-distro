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

1. [Docker](https://docs.docker.com/get-docker/)
2. Java 8+ 
3. [Maven](https://maven.apache.org/install.html)
4. [OpenMRS SDK](https://wiki.openmrs.org/display/docs/OpenMRS+SDK#OpenMRSSDK-Installation) (the sdk is a maven plugin)  
5. (Optionally) [Postman](https://www.postman.com/downloads/)

Starting OpenGp locally:

For the ***first*** time?
> See our [wiki]()

<br/>

Subsequent times, after making changes?

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