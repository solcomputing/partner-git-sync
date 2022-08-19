#!/bin/bash

# call script with the following parameters
# ./runPipeline.sh <PAT> <source branch> <target branch>

ORGANIZATION="organisation_name"
PROJECT="project-name"
PIPELINE="pipeline name"
# If pipeline rans in a special branch
# BRANCH=<branch name>

# download latest release for linux
curl -L -o runPipeline.tar.gz https://github.com/IntershopCommunicationsAG/runPipeline/releases/latest/download/runPipeline.linux.amd64.tar.gz

# unpack download
gunzip -c runPipeline.tar.gz | tar xopf -

# run application
./runPipeline -org $ORGANIZATION -prj $PROJECT -token $1 -pipeline \"$PIPELINE\" -param sourceBranch=$2 -param targetBranchName=$2