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
