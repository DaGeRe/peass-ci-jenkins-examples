#!/bin/bash

set -e

docker build -t jenkins_controller ../common/controller

cp ../common/controller/casc.yaml ../jenkins_controller_home

mkdir -p ../jenkins_controller_home/plugins
cp ../common/peass-ci-plugin/target/peass-ci.hpi ../jenkins_controller_home/plugins

mkdir -p ../jenkins_controller_home/jobs/buildOnJenkinsStartedAgent
cp config.xml ../jenkins_controller_home/jobs/buildOnJenkinsStartedAgent

tar -xf ../common/demo-project.tar.xz --directory ../jenkins_controller_home/jobs/buildOnJenkinsStartedAgent

docker run -d --name jenkins_controller --rm --publish 8080:8080 \
    --volume $(pwd)/../jenkins_controller_home:/var/jenkins_home \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume $(which docker):/usr/bin/docker \
    --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=123 \
    -uroot jenkins_controller
