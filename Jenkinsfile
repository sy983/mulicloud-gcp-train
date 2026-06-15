pipeline {
    agent any
    environment {
        KEY_PATH = "C:/Users/admin/.ssh/jnk-demo.pem"
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
              bat '''
              set INSTANCE_ID=aws cloudformation describe-stack-resources --region us-east-1 --stack-name MyWebStack --query "StackResources[?ResourceType=='AWS::EC2::Instance'].PhysicalResourceId" --output text
              aws ec2 describe-instances --region us-east-1 --instance-ids %INSTANCE_ID% --query "Reservations[0].Instances[0].PublicIpAddress" --output text
             '''
        }
    }
}
      
        
        stage('Deploy index.html') {
            steps {
                sh '''
                scp -i ${KEY_PATH} index.html ec2-user@${EC2_PUBLIC_IP}:/tmp/index.html
                ssh -i ${KEY_PATH} ec2-user@${EC2_PUBLIC_IP} "sudo mv /tmp/index.html /var/www/html/index.html && sudo systemctl restart httpd"
                '''
            }
        }
    }
}
