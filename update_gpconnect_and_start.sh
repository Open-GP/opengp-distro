DIR=$(pwd)
cd $1 || exit
mvn clean install
cd $DIR || exit
pwd
cp -f $1/omod/target/gpconnect*.omod ./docker/web/modules/
cd docker || exit
sh start.sh