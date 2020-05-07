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
