mvn openmrs-sdk:build-distro -B -Ddir=docker
version=$(./get-version.sh)

docker build docker/web -t opengp/opengp:$version
docker tag opengp/opengp:$version 270649891125.dkr.ecr.eu-west-2.amazonaws.com/opengp:$version

docker push 270649891125.dkr.ecr.eu-west-2.amazonaws.com/opengp:$version