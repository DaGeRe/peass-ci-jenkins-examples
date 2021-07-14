waitForJenkinsStartup () {

    command="{ echo 'println(jenkins.model.Jenkins.instance''.getItem(\"$1\"))' | java -jar ../common/jenkins-cli.jar -s \
        http://localhost:8080 -auth admin:123 groovy =; } &>/dev/null"

    online=1
    while [ $online -ne 0 ]
    do
	    echo 'Waiting for jenkins startup...'
        sleep 3
        eval $command
        online=$?
    done

    echo "------------------------------------"
    echo "Jenkins is fully started."
    echo "------------------------------------"
}

waitForBuildEnd () {

    command="echo 'println(jenkins.model.Jenkins.instance''.getItem(\"$1\").lastBuild.building)' | java -jar ../common/jenkins-cli.jar -s \
            http://localhost:8080 -auth admin:123 groovy ="

    building=$(eval $command)
    while [ "$building" = true ]
    do
        sleep 5
	    building=$(eval $command)
        echo 'Jenkins is still building...'
    done

    echo "------------------------------------"
    echo 'Jenkins finished building.'
    echo "------------------------------------"
}

checkResults () {

    echo "------------------------------------"
    java -jar ../common/jenkins-cli.jar -s http://localhost:8080 -auth admin:123 console "$1" 1
    echo "------------------------------------"

    DEMO_PROJECT_NAME=demo-project
    if [ $1 == "buildOnControllerCompileError" ]
    then
        DEMO_PROJECT_NAME=demo-project-compile-error
    fi

    JOB_FOLDER=$(pwd)/../jenkins_controller_home/jobs/$1
    DEMO_HOME=$JOB_FOLDER/$DEMO_PROJECT_NAME
    PEASS_DATA=$JOB_FOLDER/peass-data
    CHANGES_DEMO_PROJECT=$PEASS_DATA/changes.json

    WORKSPACE="workspace_peass"
    EXECUTION_FILE=$PEASS_DATA/execute_workspace.json
    DEPENDENCY_FILE=$PEASS_DATA/deps_workspace.json
    if [ $1 == "buildOnManuallyStartedAgent" ]
    then
        DEMO_HOME=../jenkins_agent-1_home/$DEMO_PROJECT_NAME
        WORKSPACE=$1"_peass"
        EXECUTION_FILE=$PEASS_DATA/execute_$1.json
        DEPENDENCY_FILE=$PEASS_DATA/deps_$1.json
    fi

    VERSION="$(cd "$DEMO_HOME" && git rev-parse HEAD)"

    INITIALVERSION="f2de60284ff832d5232870da6ace172ab1361eb7"
    if [ $1 == "buildOnControllerCompileError" ]
    then
        INITIALVERSION="696131783b5ea6b9299b45a888d0f60f38547547"
    fi

    INITIAL_SELECTED=$(grep "initialversion" -A 1 $DEPENDENCY_FILE | grep "\"version\"" | tr -d " \"," | awk -F':' '{print $2}')
    if [ "$INITIAL_SELECTED" != "$INITIALVERSION" ]
    then
	    echo "Initialversion should be $INITIALVERSION, but was $INITIAL_SELECTED"
        exit 1
    fi

    if [ ! -f $EXECUTION_FILE ]
    then
        echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        echo "$EXECUTION_FILE could not be found!"
        echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        exit 1
    fi

    #Check, if $CHANGES_DEMO_PROJECT contains the correct commit-SHA
    TEST_SHA=$(grep -A1 'versionChanges" : {' $CHANGES_DEMO_PROJECT | grep -v '"versionChanges' | grep -Po '"\K.*(?=")')
    if [ "$VERSION" != "$TEST_SHA" ]
    then
        echo "commit-SHA ("$VERSION") is not equal to the SHA in $CHANGES_DEMO_PROJECT ("$TEST_SHA")!"
	    cat $CHANGES_DEMO_PROJECT
	    exit 1
    else
	    echo "$CHANGES_DEMO_PROJECT contains the correct commit-SHA."
    fi

    #Check, if a slowdown is detected for innerMethod
    STATE=$(grep -A21 '"call" : "de.dagere.peass.Callee#innerMethod",' $PEASS_DATA/visualization/$VERSION/de.dagere.peass.ExampleTest_test.js \
        | grep '"state" : "SLOWER",' \
        | grep -o 'SLOWER')
    if [ "$STATE" != "SLOWER" ]
    then
        echo "State for Callee#innerMethod in de.dagere.peass.ExampleTest_test.js has not the expected value SLOWER, but was $STATE!"
        cat $PEASS_DATA/visualization/$VERSION/de.dagere.peass.ExampleTest_test.js
	    exit 1
    else
	    echo "Slowdown is detected for innerMethod."
    fi

    SOURCE_METHOD_LINE=$(grep "Callee.method1_" $PEASS_DATA/visualization/$VERSION/de.dagere.peass.ExampleTest_test.js -A 3 \
        | head -n 3 \
        | grep innerMethod)
    if [[ "$SOURCE_METHOD_LINE" != *"innerMethod();" ]]
    then
        echo "Line could not be detected - source reading probably failed."
        echo "SOURCE_METHOD_LINE: $SOURCE_METHOD_LINE"
        exit 1
    else
        echo "SOURCE_METHOD_LINE is correct."
    fi
}
