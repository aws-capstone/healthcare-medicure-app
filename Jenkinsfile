pipeline{
    
    agent any
    
    tools{
        maven 'mymaven'
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        DOCKER_USERNAME = credentials('docker-username')  // Jenkins stored credential for Docker username
        DOCKER_PASSWORD = credentials('docker')  // Jenkins stored credential for Docker password        

    }    
    
    //parameters {
    //    booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    //    choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    //    booleanParam(name: 'autoApproveProd', defaultValue: false, description: 'Automatically run apply after generating plan for PROD?')
    //    choice(name: 'actionProd', choices: ['apply', 'destroy'], description: 'Select the action to perform')        
    //}
    
    stages{
        stage('Clone Repository')
        {
            steps{
                git credentialsId: 'github_token-nikitaks97', url: 'https://github.com/aws-capstone/healthcare-medicure-app.git'
            }
        }
        stage('Test Code')
        {
            steps{
                sh 'mvn test'
            }
        }
        stage('Build Code')
        {
            steps{
                sh 'mvn package'
            }
        }
        stage('Build Image')
        {
            steps{
                sh 'docker build -t capstone_project2:$BUILD_NUMBER .'
            }
        }

        stage('Push the Image to dockerhub')
        {
            steps{
                
        withCredentials([string(credentialsId: 'docker', variable: 'docker')]) 
                {
               sh 'docker login -u  nikitaks997797 -p ${docker} '
               }
                sh 'docker tag capstone_project2:$BUILD_NUMBER nikitaks997797/capstone_project2:$BUILD_NUMBER'
                sh 'docker push nikitaks997797/capstone_project2:$BUILD_NUMBER'
            }
        } 
        stage('Setup Google Cloud SDK') {
            steps {
                script {
                    // Use the secret file credential
                    withCredentials([file(credentialsId: 'glcoud_svc-tf-svc', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        // Install Google Cloud SDK if not already installed
                        def gcloudInstalled = sh(script: 'gcloud version', returnStatus: true)
                        if (gcloudInstalled != 0) {
                            sh 'curl https://sdk.cloud.google.com | bash'
                            sh 'exec -l $SHELL'
                            sh 'gcloud init'
                        }
                        
                        // Authenticate with Google Cloud
                        sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                        // Set the project (replace 'your-project-id' with your actual project ID)
                        sh 'gcloud config set project skilled-drake-444315-g3'
                    }
                }
            }
        }
        stage('Terraform Init') {
            steps {
                dir('terraform'){
                sh 'terraform init'
            }}
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform'){
                sh 'terraform validate'
            }}
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform'){
                  sh 'terraform plan -out=terraform.plan'
               }
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('terraform'){
                  input message: 'Approve Terraform Apply?', ok: 'Apply'
                  sh 'terraform apply terraform.plan'
                  sh 'echo gcloud container clusters get-credentials $(terraform output -raw cluster_name) --location=$(terraform output -raw location)'
                  sh 'gcloud container clusters get-credentials $(terraform output -raw cluster_name) --location=$(terraform output -raw location)'
               }
            }
        }
        //stage('Get Cluster Credential'){
        //    steps{
        //        sh 'gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)'
        //    }
        //}
        stage('Deploy Application to Cluster'){
            steps{
                dir('kubernetes'){
                  sh 'kubectl create secret docker-registry docker_private --from-file=.dockerconfigjson=/var/lib/jenkins/.docker/config.json --type=kubernetes.io/dockerconfigjson'
                  sh 'kubectl apply -f .'
                }
            }
        }
    }
}
