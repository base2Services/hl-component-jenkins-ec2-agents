pipeline {

  environment {
    AWS_REGION = 'us-east-1'
    PROJECT_NAME = 'jenkins-ec2-agents'
    VERSION = '0.1.0'
  }

  agent {
    docker {
      image 'theonestack/cfhighlander'
    }
  }

  stages {

    stage('cftest') {
      steps {
        sh 'cfndsl -u'
        sh "cfhighlander cftest -r xml"
      }
      post {
        always {
          junit 'reports/report.xml'
        }
      }
    }

    stage('cfn nag') {
      agent {
        docker {
          image 'base2/cfn-nag'
          reuseNode true
        }
      }
      steps {
        sh 'cfn_nag_scan -i out/tests'
      }
    }

  }
}
