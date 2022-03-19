#!/bin/bash

set -e

cd ../common

if [ "$#" -lt 1 ]; then
	branch="main"
else
	branch=$1
fi

if [ "$1" == "develop" ]; then
	start=$(pwd)
	echo "Cloning KoPeMe"
	git clone --branch develop https://github.com/DaGeRe/KoPeMe && \
		cd KoPeMe && \
		./mvnw clean install -DskipTests
	cd $start
fi
	  

git clone --branch $branch https://github.com/dagere/peass && \
    cd peass && \
    ./mvnw clean install -P buildStarter -DskipTests

cd ..

git clone --branch $branch https://github.com/jenkinsci/peass-ci-plugin && \
    cd peass-ci-plugin && \
    ./mvnw clean -B package --file pom.xml -DskipTests

