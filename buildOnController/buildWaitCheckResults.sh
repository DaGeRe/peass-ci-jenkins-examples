#!/bin/bash

../common/scripts/buildPeassAndPeassCI.sh "$@"
./buildOnController.sh "$@"
./waitForJenkinsStartup.sh
./waitForBuildEnd.sh
./checkResults.sh
