FROM ubuntu:latest

# Avoid manual timezone configuration
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && \
	apt install -y openssh-server sudo curl openjdk-11-jdk maven git

RUN java -version

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 jenkins

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

RUN  echo 'jenkins:jenkins' | chpasswd

#RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

USER root
RUN service ssh start

# Standard SSH port
EXPOSE 22

# Define default command.
CMD ["/usr/sbin/sshd","-D"]
