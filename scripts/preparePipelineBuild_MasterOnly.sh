#!/bin/bash

docker build -t jenkins_master ../files/master

mkdir -p ../jenkins_master_home/jobs/demo-pipeline_masterOnly/peass-ci_scripts
cp ../files/master/casc.yaml ../jenkins_master_home
cp checkResults.sh ../jenkins_master_home/jobs/demo-pipeline_masterOnly/peass-ci_scripts

mkdir -p ../jenkins_master_home/plugins
cp ../files/peass-ci.hpi ../jenkins_master_home/plugins

cp ../files/master/demo-pipeline_masterOnly/config.xml ../jenkins_master_home/jobs/demo-pipeline_masterOnly

docker run -d --name jenkins_master --rm --publish 8080:8080 --volume $(pwd)/../jenkins_master_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker \
    --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=123 -uroot jenkins_master
