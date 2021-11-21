#!/bin/bash

set -e

cd ../common

if [ "$#" -lt 1 ]; then
	branch="main"
else
	branch=$1
fi

git clone --branch $branch https://github.com/dagere/peass && \
    cd peass && \
    ./mvnw clean install -pl dependency,measurement,analysis -DskipTests

cd ..

git clone --branch $branch https://github.com/dagere/peass-ci && \
    cd peass-ci && \
    ./mvnw clean -B package --file pom.xml -DskipTests

