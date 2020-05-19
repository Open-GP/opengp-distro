echo "-----"
cat ~/.m2/settings.xml
echo "-----"
version=$(./get-version.sh)

mvn openmrs-sdk:build-distro -B -Ddir=docker
docker build docker/web -t opengp/opengp:$version
docker tag opengp/opengp:$version 270649891125.dkr.ecr.eu-west-2.amazonaws.com/opengp:$version

docker push 270649891125.dkr.ecr.eu-west-2.amazonaws.com/opengp:$version