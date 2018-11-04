

 // Mimic environment variables that are set Travis
  // TRAVIS_PULL_REQUEST: The pull request number if the current job is a pull request, “false” if it’s not a pull request.
  // TRAVIS_EVENT_TYPE: Indicates how the build was triggered. One of push, pull_request, api, cron.
  // TRAVIS_PULL_REQUEST_BRANCH:
  //   if the current job is a pull request, the name of the branch from which the PR originated.
  //   if the current job is a push build, this variable is empty ("").
  // TRAVIS_REPO_SLUG: The slug (in form: owner_name/repo_name) of the repository currently being built.
  // TRAVIS_BRANCH:
  //   for push builds, or builds not triggered by a pull request, this is the name of the branch.
  //   for builds triggered by a pull request this is the name of the branch targeted by the pull request.
  //   for builds triggered by a tag, this is the same as the name of the tag (TRAVIS_TAG).
  //

   
  // Jenkins Environment variables that are available

  // BRANCH_NAME  Name of the branch for which this Pipeline is executing,
  // CHANGE_ID An identifier corresponding to some kind of change request,
  // CHANGE_TARGET
  //   For a multibranch project corresponding to some kind of change request, this will be set to the target or base branch to which the change could be merged, if supported; else unset.
  if (env.BRANCH_NAME.startsWith("PR-")) {
    env.TRAVIS_PULL_REQUEST="true"        // true or false
    env.TRAVIS_EVENT_TYPE="pull_request"  // push or pull_request

   if (env.CHANGE_TARGET !=null) {
     env.TRAVIS_BRANCH = env.CHANGE_TARGET  
   }
 
   env.TRAVIS_PULL_REQUEST_BRANCH = env.CHANGE_BRANCH

  } else {
    env.TRAVIS_PULL_REQUEST="false"
    env.TRAVIS_BRANCH= env.BRANCH_NAME
  }

  // TODO: Make into a input variable
  env.TEST_CLOUD="sl"
  env.DOCKER_REGISTRY="orpheus-local-docker.artifactory.swg-devops.com"
    CREDENTIALS_ID = 'OpenContentoctravisGITSSHKey'
  // Load common Groovy Code
  fileLoader.withGit('git@github.ibm.com:OpenContent/infra-devops-pipeline.git', 'master', CREDENTIALS_ID, 'master') {
  mail = fileLoader.load('src/com/ibm/cam/Mail')
  }

node("opencontent") {
  try {
 
   CWDABSPATH = sh (
   script: "echo `pwd`", 
           returnStdout: true
    ).trim()
    println "Current Working Directory: " + CWDABSPATH
    env.BASEPATH = CWDABSPATH


   // TODO Remove
   //echo sh(script: 'env|sort', returnStdout: true)

   // Credential IDs that we will need. 
    credentials_artifactory_id="octravisArtifactoryAPI"
    credentials_gpg_password="ARCHIVE_PASSWORD"
    credentials_cambuilds_token="camcbuildsslackToken"
 
  // Get the various OpenContent Credentials that will be needed for our pattern-build scripts. 
  // TODO:  Determine better way that we can load Groovey code from the pipeline build for these 
  //        routines
  //  
  //  Will retrieve the credentials and set them as environment variables.   Any echo of the variables within the withCredentials
  //  will be ***** and outside of withCredentials routine they will be in plain text.   
  //
  //

   // Get the Artifactory credentials......

   withCredentials([usernamePassword(credentialsId: credentials_artifactory_id, usernameVariable: 'ARTIFACTORY_USERNAME', passwordVariable: 'ARTIFACTORY_REGISTRY_PASS')]) {
        env.DOCKER_REGISTRY_PASS = ARTIFACTORY_REGISTRY_PASS
        //echo sh(script: 'env|sort', returnStdout: true)

    } 

   // Get the gpg archive password.....
   withCredentials([string(credentialsId: credentials_gpg_password, variable: 'gpgArchive')]) {
        env.ARCHIVE_PASSWORD = gpgArchive
        //echo sh(script: 'env|sort', returnStdout: true)

    } 
 
    // TODO:  Remove 
    //echo sh(script: 'env|sort', returnStdout: true)
   
  stage("Checkout Code") {
       // checkout the git repository that triggered this build.  We will always checkout the 
       // code along with appropriate pattern-build code. 
       checkout scm

         if (env.CHANGE_TARGET == "development"  || env.BRANCH_NAME == "development") {
            echo "Either doing a PR or Merge request against the development branch"
            sh "set +x && git clone --depth=1 -b development git@github.ibm.com:OpenContent/pattern-build.git" 
         } else if (env.CHANGE_TARGET == "master" || env.BRANCH_NAME == "master" ) {
            echo "Either a PR request or Merge request against the against master branch"
            sh "set +x && git clone --depth=1 -b master git@github.ibm.com:OpenContent/pattern-build.git"
          }
          else {
            echo "Unknown branch"
            currentBuild.result = "ABORTED"
            error('Stopping early…') 
          }

         sh "cp -r pattern-build/* ."
         sh "cp -r pattern-build/.rubocop.yml ."

   }   // Checkout Code stage

   // We will always run the Rake Trace command for all Pull Requests and Merge Requests. 
   stage("Rake Trace") {
     echo "Running Rake --trace" 
     sh '''#!/bin/bash -l
     echo "Im here"
     eval "$(/opt/chefdk/bin/chef shell-init bash)"
     rake --trace  
     '''
  }

   stage("Run Integration Build") {
     // Only run the Integration Tests when we are a PULL request against the Development Branch 
    
     // Temp workaround for now so I can test the publish side of things
     if (env.BRANCH_NAME.startsWith("PR-") && env.CHANGE_TARGET  == "development") {
         echo "Run ./tasks/integration_jenkins_test.sh"
         sh '''#!/bin/bash -l
         eval "$(/opt/chefdk/bin/chef shell-init bash)"
         chmod +x ./tasks/integration_jenkins_test.sh
         ./tasks/integration_jenkins_test.sh
         ''' 
      }  // Pull Request
      else {
        echo "Integration Tests not being executed because because we are not the development branch. "
      }
    
   }   // End of Integration Build stage
 

  
   stage("Publish Build") {
     // Will only publish the build when we are performing a merge against the development branch
     // for now. 
     echo "Publish Build Stage......"

     if (env.BRANCH_NAME == "development"  && env.CHANGE_TARGET == null) {
       echo "Publish the build as we are in a merge request. "
       //sh '''#!/bin/bash -l
       //  eval "$(/opt/chefdk/bin/chef shell-init bash)"
       //  chmod +x ./tasks/camhub_jenkins_publish.sh
       //  ./tasks/camhub_jenkins_publish.sh
       //''' 
     } else 
     {
       echo "Do not publish the build"
     }

   }  // End of Publish Build stage

    slackSend(color: '#00FF00', channel: "camc_builds", tokenCredentialID: "camcbuildsslackToken", message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) by ${env.CHANGE_AUTHOR}" )

  }  catch (e) {
     currentBuild.result = "FAILED"
     slackSend(color: '#FF0000', channel: "camc_builds", tokenCredentialID: "camcbuildsslackToken", message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) by ${env.CHANGE_AUTHOR}" )
     mail.sendFailNotifyMail()
     throw e
  }
}  // End of Node OpenContent


