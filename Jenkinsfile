def getEnvVar(String deployEnv, String paramName){
    return sh (script: "grep '${paramName}' env_vars/${deployEnv}.properties|cut -d'=' -f2", returnStdout: true).trim();
}

pipeline{

agent any

options {
      timeout(time: 1, unit: 'HOURS') 
}

parameters {
    password(name:'AWS_KEY', defaultValue: '', description:'Enter AWS_KEY')
    choice(name: 'DEPLOY_ENV', choices: ['dev','sit','uat','prod'], description: 'Select the deploy environment')
    choice(name: 'ACTION_TYPE', choices: ['deploy','create','destroy'], description: 'Create or destroy')
    string(name: 'INSTANCE_TYPE', defaultValue: 't2.large', description: 'Type of instance')
    string(name: 'SPOT_PRICE', defaultValue: '0.037', description: 'Spot price')
    string(name: 'PLAYBOOK_TAGS', defaultValue: 'all', description: 'playbook tags to run')
}

stages{
    stage('Init'){
        steps{
            checkout scm 
        script{
        env.DEPLOY_ENV = "$params.DEPLOY_ENV"
        env.ACTION_TYPE = "$params.ACTION_TYPE"
        env.INSTANCE_TYPE = "$params.INSTANCE_TYPE"
        env.SPOT_PRICE = "$params.SPOT_PRICE"
        env.PLAYBOOK_TAGS = "$params.PLAYBOOK_TAGS"
        env.APP_ID = getEnvVar("${env.DEPLOY_ENV}",'APP_ID')
        env.repo_bucket_credentials_id = "s3repoadmin";
        env.aws_s3_bucket_name = 'jvcdp-repo';
        env.aws_s3_bucket_region = 'ap-southeast-1';
        env.APP_BASE_DIR = pwd()
        env.GIT_HASH = sh (script: "git rev-parse --short HEAD", returnStdout: true)
        env.TIMESTAMP = sh (script: "date +'%Y%m%d%H%M%S%N' | sed 's/[0-9][0-9][0-9][0-9][0-9][0-9]\$//g'", returnStdout: true)
        }
        echo "do some init here";

        }
    }

    stage('Create Stack'){
        when {
        expression {
            return env.ACTION_TYPE == 'create';
            }
        }
        steps{
            withCredentials([file(credentialsId: 'aws_terraform_tfvars', variable: 'aws_terraform_tfvars')]){
            sh '''#!/bin/bash -xe
            cd $APP_BASE_DIR/terraform
            cp $aws_terraform_tfvars $APP_BASE_DIR/terraform/terraform.tfvars
            /usr/local/bin/terraform init -input=false
            /usr/local/bin/terraform plan -var instance_type=$INSTANCE_TYPE -var spot_price=$SPOT_PRICE -out=tfplan -input=false
            /usr/local/bin/terraform apply -input=false tfplan
            '''
            sh '''
            cd $APP_BASE_DIR/terraform
            rm -f $APP_BASE_DIR/ansible/hosts | true
            pwd && ls -lart .
            chmod 755 $APP_BASE_DIR/terraform/make_inventory.py
            python $APP_BASE_DIR/terraform/make_inventory.py $APP_BASE_DIR/terraform/terraform.tfstate
            '''
            }
            script{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                credentialsId: "${repo_bucket_credentials_id}", 
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]){
                    for(distFileName in ["ansible/hosts","terraform/terraform.tfstate"]) {
                            awsIdentity() //show us what aws identity is being used
                            def srcLocation = "${APP_BASE_DIR}"+"/"+"${distFileName}";
                            def distLocation = 'terraform/' + "${env.TIMESTAMP}"+"/"+ distFileName;
                            echo "Uploading ${srcLocation} to ${distLocation}"
                            withAWS(region: "${env.aws_s3_bucket_region}"){
                            s3Upload(file: srcLocation, bucket: "${env.aws_s3_bucket_name}", path: distLocation)
                            }
                        }
                }
            }
        }
    }
    stage('Deploy'){
        when {
        expression {
            return env.ACTION_TYPE == 'deploy';
            }
        }
        steps{
        withCredentials([sshUserPrivateKey(credentialsId: "cdhstack_key_cred", keyFileVariable: 'cdhstack_key')]) {

        sh '''#!/bin/bash -xe
        cd $APP_BASE_DIR/ansible
        ansible-playbook -i hosts --tags $PLAYBOOK_TAGS --private-key=${cdhstack_key} main.yml
        '''
        }
        }
    }
    stage('Destroy Stack'){
        when {
        expression {
            return env.ACTION_TYPE == 'destroy';
            }
        }
        steps{
            withCredentials([file(credentialsId: 'aws_terraform_tfvars', variable: 'aws_terraform_tfvars')]){
            sh '''
            cd $APP_BASE_DIR/terraform
            cp $aws_terraform_tfvars $APP_BASE_DIR/terraform/terraform.tfvars
            /usr/local/bin/terraform destroy -force
            '''
            }
        }
    }
}

post {
    always {
        sh '''
        rm -f $APP_BASE_DIR/terraform/terraform.tfvars | true
        '''
    }
}
}
