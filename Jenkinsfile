#!/usr/bin/env groovy
pipeline {
  agent {
    label 'vagrant && libvirt'
  }
  environment {
      VMNAME = 'dev-r-vrt-122-022'
      VAGRANT_DEFAULT_PROVIDER = 'libvirt'
      // MLNX_OFED_URL = '...'
  }
  stages {
    stage('CreateVM') {
      steps {
        sh 'echo "Create VM: $VMNAME ..."'
        // vagrant-libvirt 
        sh 'cd centos7_mofed_vm ; sudo VM_NAME=$VMNAME vagrant up'
      }  
    }
    stage('Test') {
      steps {
        echo 'Testing ...'
        sh 'cd centos7_mofed_vm ; sudo vagrant VM_NAME=$VMNAME ssh -- "ping -c3 11.212.122.1"'
      }
    }
  }
}
