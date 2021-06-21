#!/bin/bash

set -e

cd ../common

git clone https://github.com/dagere/peass && \
    cd peass && \
    git reset --hard d385da0e && \
    ./mvnw clean install -pl dependency,measurement,analysis -DskipTests

cd ..

git clone https://github.com/dagere/peass-ci && \
    cd peass-ci && \
    git reset --hard e15f7ed && \
    ./mvnw clean -B package --file pom.xml -DskipTests

