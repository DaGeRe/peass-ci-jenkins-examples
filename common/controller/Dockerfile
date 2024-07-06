FROM jenkins/jenkins:2.452.2

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false -Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true"
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml

#COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
#RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml

# Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "/var/jenkins_home/.m2"

USER root
RUN apt-get update && apt-get install -y maven git

RUN jenkins-plugin-cli --plugins "pipeline-stage-step:latest pipeline-build-step:latest pipeline-model-definition:latest workflow-aggregator:latest workflow-api:latest workflow-step-api:latest workflow-job:latest workflow-support:latest credentials:latest jaxb:latest git:latest ssh-slaves:latest"

# Standard SSH port
EXPOSE 22
