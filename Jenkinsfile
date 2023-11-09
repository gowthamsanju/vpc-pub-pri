pipeline {
   agent  any
    stages {
        stage('checkout') {
            steps {
                 script{
                        dir("terraform")
                        {
                            checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/gowthamsanju/vpc-pub-pri.git']])
                        }
                    }
                }
            }
       stage('Destroy') {
            steps {
                input message: 'Want to skip the Destroy stage?', ok: 'Yes',
                  parameters: [booleanParam(name: 'skip_test', defaultValue: false)]
                script {
                    if(params.skip_test) {
                        sh 'echo "Exiting Destroy stage"'
                        return
                    }
                }
                withAWS(credentials: 'fbeffe18-eed5-431c-ae50-4adbc1a79163') {
                    sh 'pwd;cd terraform/ ; terraform destroy'
                }
            }
        }

        stage('Plan') {
            steps {
                withAWS(credentials: 'fbeffe18-eed5-431c-ae50-4adbc1a79163') {
                    sh 'pwd;cd terraform/ ; terraform init'
                    sh "pwd;cd terraform/ ; terraform fmt"
                    sh "pwd;cd terraform/ ; terraform validate"
                    sh "pwd;cd terraform/ ; terraform plan"
                }
            }
        }

        stage('Apply') {
            steps {
                withAWS(credentials: 'fbeffe18-eed5-431c-ae50-4adbc1a79163') {
                    sh "pwd;cd terraform/ ; terraform apply --auto-approve"
                }
            }
        }
    }

  }
