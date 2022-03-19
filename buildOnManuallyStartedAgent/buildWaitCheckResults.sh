#!/bin/bash

../common/scripts/buildPeassAndPeassCI.sh "$@"
./buildOnManuallyStartedAgent.sh "$@"
./waitForJenkinsStartup.sh
./registerAgentToController.sh
./waitForBuildEnd.sh
./checkResults.sh
