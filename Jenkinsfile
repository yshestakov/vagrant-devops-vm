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
        echo 'Create VM: $VM_NAME ...'
        sh 'cd centos_mofed_vm ; vagrant up'
      }
    }
    stage('Test') {
      steps {
        echo 'Testing ...'
        sh 'cd centos_mofed_vm ; vagrant ssh "ping -c3 11.212.122.1"'
      }
    }
  }
}
