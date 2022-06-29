#!/bin/bash

#set -e

function prepareControllerWorkspace {
	cp ../common/controller/casc.yaml ../jenkins_controller_home

	mkdir -p ../jenkins_controller_home/plugins
	cp ../common/peass-ci-plugin/target/peass-ci.hpi ../jenkins_controller_home/plugins

	mkdir -p ../jenkins_controller_home/jobs/buildOnJenkinsStartedAgent
	cp config.xml ../jenkins_controller_home/jobs/buildOnJenkinsStartedAgent

	tar -xf ../common/demo-project.tar.xz --directory ../jenkins_controller_home/jobs/buildOnJenkinsStartedAgent
}

docker run -d --name jenkins_controller --rm --publish 8080:8080 \
    --volume $(pwd)/../jenkins_controller_home:/var/jenkins_home \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume $(which docker):/usr/bin/docker \
    --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=123 \
    --env JENKINS_JAVA_OPTS=-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true \
    -uroot jenkins_controller
    
    
source ../common/functions.sh 
waitForJenkinsStartup "buildOnJenkinsStartedAgent"

waitForMetadataDownload "jenkins_controller"

installNecessaryPlugins

docker restart jenkins_controller
waitForJenkinsStartup "buildOnJenkinsStartedAgent"
waitForBuildEnd "buildOnJenkinsStartedAgent"
