#!/usr/bin/env groovy
pipeline {
  agent {
    label 'vagrant && libvirt'
  }
  environment {
      VM_NAME = 'dev-r-vrt-122-022'
      VAGRANT_DEFAULT_PROVIDER = 'libvirt'
      // MLNX_OFED_URL = '...'
  }
  stages {
    stage('CreateVM') {
      steps {
        sh 'echo "Create VM: $VM_NAME ..."'
        // vagrant-libvirt 
        withEnv(['VM_NAME=dev-r-vrt-122-022']) {
          sh 'cd centos7_mofed_vm ; sudo vagrant up'
        }
      }  
    }
    stage('Test') {
      steps {
        echo 'Testing ...'
        withEnv(['VM_NAME=dev-r-vrt-122-022']) {
          sh 'cd centos7_mofed_vm ; sudo vagrant ssh "ping -c3 11.212.122.1"'
        }
      }
    }
  }
}
