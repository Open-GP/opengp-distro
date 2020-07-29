cd docker || exit
docker-compose stop web && docker-compose rm -f web
cd .. && sh update_gpconnect_and_start.sh "../openmrs-module-gpconnect" web
