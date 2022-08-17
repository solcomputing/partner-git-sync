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
    default: master
  - name: sourceBranch
    displayName: source branch for synchronization
    type: string
    default: master

  trigger: none

  stages:
  - stage: SyncGitSources
    jobs:  
      - template: git-synchronization-template.yml@partner-git-sync
        # you have to conigure all necessary parameters
        # agentPool:          "agent pool name, optional"
        externalRepoUser:     "repo user name for access to external repo"
        externalRepoPassword: "password for user"
        externalRepo:         "Git repository without protocol, eg. bitbucket.org/organization/repository.git"
        targetBranchName:     ${{ parameters.targetBranch }}
        sourceBranchName:     ${{ parameters.sourceBranch }}

It is possible to store the variables in a Azure DevOPS library.
