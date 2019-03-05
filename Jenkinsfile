#!/usr/bin/env groovy
@Library('cht-jenkins-pipeline') _

properties([
    [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '15']]
]);

if (env.BRANCH_NAME == 'master') {
   properties([pipelineTriggers([cron('H H(8-10) * * 5')]),
       [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '15']]
   ]);
}

// NODE FOR RUBY2.3.3-RAILS3.2
node('testing') {
    try {
        timestamps {
            stage('Setup_2.3.3-3.0') {
                checkout scm
                sh "docker build -f docker/Dockerfile -t ar_ondemand_image ."
                sh "docker run -dit --name=ar_ondemand-app-${JOB_BASE_NAME}_${BUILD_NUMBER} -e RAILS_ENV=test -v ${WORKSPACE}/:/home/cloudhealth/ar-ondemand/ ar_ondemand_image /bin/bash"
           }
        }
        timestamps {
            stage('Run Bundle Install') {
                sh "docker exec ar_ondemand-app-${JOB_BASE_NAME}_${BUILD_NUMBER} /bin/bash -c  -l 'bundle install --no-deployment --binstubs=bin'"
            }
        }
        try {
            timestamps {
                stage('Test_2.3.3-3.0') {
                    try {
                        sh 'docker exec ar_ondemand-app-${JOB_BASE_NAME}_${BUILD_NUMBER} /bin/bash -c -l "bundle exec rspec --format RspecJunitFormatter --out ar_ondemand_rspec_2-3_${JOB_BASE_NAME}_${BUILD_NUMBER}.xml"'
                    } finally {
                        junit(testResults: 'ar_ondemand_rspec_2-3_${JOB_BASE_NAME}_${BUILD_NUMBER}.xml')
                    }
                }
            }
            sh "exit 0"
            currentBuild.result = 'SUCCESS'
        } catch (Exception e) {
        // Exit 0 so that we can keep running other nodes (if we are to add more) if this one fails
            sh "exit 0"
            currentBuild.result = 'FAILURE'
        }
    } finally {
        sh "docker stop ar_ondemand-app-${JOB_BASE_NAME}_${BUILD_NUMBER} && docker rm -f ar_ondemand-app-${JOB_BASE_NAME}_${BUILD_NUMBER}"
    }
}