#!/bin/bash

docker rm -f jenkins_controller
docker rm -f jenkins_agent-1

rm -rf ../jenkins_controller_home/{*,.*}
rm -rf ../jenkins_agent-1_home/{*,.*}
rm -rf ../common/peass
rm -rf ../common/peass-ci-plugin

cd ../jenkins_controller_home

cat << EOF > .gitignore
*
!.gitignore
EOF

cp .gitignore ../jenkins_agent-1_home
