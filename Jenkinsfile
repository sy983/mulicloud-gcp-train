pipeline {
    agent any
    environment {
        KEY_PATH = "C:/Users/admin/.ssh/jnk-demo.pem"
        EC2_PUBLIC_IP = ''
      }
    stages {

        stage('Clone Repo') {
           steps {
               git branch: 'main', url: 'https://github.com/sy983/mulicloud-gcp-train.git'
               }
          }
        stage('chk aws cli') {
          steps {
             bat 'aws --version'
                }
           }

  
           stage('AWS Identity Check') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'd163a75c-19e6-4c5c-afa0-7d15ec1cdf73']]) {
                    bat 'aws sts get-caller-identity --region us-east-1'
                }
            }
        }
        stage('Set AWS Region') {
           steps {
               bat 'aws configure set region us-east-1'
               }
         }

        stage('Provision EC2') {
           steps {
               withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'd163a75c-19e6-4c5c-afa0-7d15ec1cdf73']]) {
               bat 'aws cloudformation create-stack --region us-east-1 --stack-name MyWebStack --template-body file://ec2.yml --capabilities CAPABILITY_IAM --parameters ParameterKey=KeyName,ParameterValue=jnk-demo'
               bat 'aws cloudformation wait stack-create-complete --region us-east-1 --stack-name MyWebStack'    
                       }
                    }
                }
      stage('Get EC2 IP') {
           steps {
              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'd163a75c-19e6-4c5c-afa0-7d15ec1cdf73']]) {
               script {
                // Write the AWS CLI output to a temp file
                bat """
                aws cloudformation describe-stacks --region us-east-1 --stack-name MyWebStack --query "Stacks[0].Outputs[?OutputKey=='PublicIP'].OutputValue" --output text > ip.txt
                """

                // Read the file back into Groovy
                def ec2Ip = readFile('ip.txt').trim()
                env.EC2_PUBLIC_IP = ec2Ip
                echo "Captured EC2 Public IP: ${env.EC2_PUBLIC_IP}"
            }
        }
    }
}


        stage('Deploy index.html') {
            steps {
                bat """
                scp -i %KEY_PATH% index.html ec2-user@${env.EC2_PUBLIC_IP}:/tmp/index.html
                ssh -i %KEY_PATH% ec2-user@${env.EC2_PUBLIC_IP} "sudo mv /tmp/index.html /var/www/html/index.html && sudo systemctl restart httpd"
                """
            }
        }
    }
}

        
 
