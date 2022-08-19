partner-git-sync
================

Overview
--------

This repository provides a template for Azure pipelines to synchronize an own Git repository wiht Azure DevOps,
so that all build processes can run on Azure DevOps.

How to user the pipeline template
---------------------------------

Add a file synch-pipelines.yml to the root directory of your project with the following content.
Following a new pipline can be created based on the existing file.

.. code-block:: yaml

  # Create a repository resource to the Github repo, that is providing the centrally managed template.
  resources:
    repositories:
      - repository: partner-git-sync
        type: github
        endpoint: INTERSHOP_GITHUB
        name: intershop/partner-git-sync
        ref: main

  parameters:
  - name: targetBranch
    displayName: target branch for synchronization
    type: string
    default: develop
  - name: sourceBranch
    displayName: source branch for synchronization
    type: string
    default: develop

  variables:
  - name:  REPO_USER_NAME
    value: "<repo user name>"
  - name:  REPO_USER_PASSWORD
    value: "<repo user password or token>"
  - name:  REPO
    value: "<repo without protocol, eg. bitbucket.org/organization/repository.git>"

  trigger: none

  stages:
  - stage: SyncGitSources

    # optional
    # pool: '$(BUILD_AGENT_POOL)'

    jobs:  
      - template: git-synchronization-template.yml@partner-git-sync
        externalRepoUser:     $(REPO_USER_NAME)
        externalRepoPassword: $(REPO_USER_PASSWORD)
        externalRepo:         $(REPO)
        targetBranchName:     ${{ parameters.targetBranch }}
        sourceBranchName:     ${{ parameters.sourceBranch }}

It is possible to store the variables in a Azure DevOPS library or get the token from a key vault.

Azure DevOps configuration
--------------------------

1. Create a service connection "INTERSHOP_GITHUB", see `Microsoft Documentation <https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#github-service-connection>`_.

2. Assign the necessary permissions to the build user service for the Git repository in Azure DevOps. 

    - Select "Manage repositories" in the repositories menu. 
    - Select your repository.
    - Adapt the security configuration for the project build service user.
    
      - Select "Security"
      - Select "<project name> Build Service (project name)"
      - Change the configuration to "Allow" for "Contribute" and "Create branch"

3. Create pipeline configuration on Azure DevOps, see `Microsoft Documentation <https://docs.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline>`
4. Create a job that runs with each commit on the original system. This job should call the pipeline on Azure DevOps.
    - It is possible to do this over REST, but it is possible to use a prepared client. See https://github.com/IntershopCommunicationsAG/runPipeline
    - Shell script example:

      .. code-block:: shell
        
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

      The shell script runs aslong the pipeline runs.