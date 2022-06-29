#!/bin/bash

../common/scripts/buildPeassAndPeassCI.sh "$@"
./buildOnController.sh "$@"
./checkResults.sh
