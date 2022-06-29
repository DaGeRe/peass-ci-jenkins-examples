#!/bin/bash

../common/scripts/buildPeassAndPeassCI.sh
./buildOnJenkinsStartedAgent.sh
./checkResults.sh
