rm -rf tmp
mkdir tmp
wget -O - http://demo.opengp.org/openmrs/module/fhir/rest/swaggercodegen?language=swagger > tmp/swagger.zip
unzip tmp/swagger.zip -d tmp/
mv tmp/swagger.json swagger.json
rm -rf tmp/