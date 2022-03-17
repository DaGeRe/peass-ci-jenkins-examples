#!/bin/bash

set -e

docker build -t jenkins_controller ../common/controller

cp ../common/controller/casc.yaml ../jenkins_controller_home

mkdir -p ../jenkins_controller_home/plugins
cp ../common/peass-ci-plugin/target/peass-ci.hpi ../jenkins_controller_home/plugins

mkdir -p ../jenkins_controller_home/jobs/buildOnController
cp config.xml ../jenkins_controller_home/jobs/buildOnController

tar -xf ../common/demo-project.tar.xz --directory ../jenkins_controller_home/jobs/buildOnController

docker run -d --name jenkins_controller --rm --publish 8080:8080 \
    --volume $(pwd)/../jenkins_controller_home:/var/jenkins_home \
    --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=123 \
    -uroot jenkins_controller
    
if [ "$1" == "develop" ]; then
	docker exec -t jenkins_controller bash -c 'cd home && git clone --branch develop https://github.com/DaGeRe/KoPeMe && cd KoPeMe && mvn clean install -DskipTests'
fi
