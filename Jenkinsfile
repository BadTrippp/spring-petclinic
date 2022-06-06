pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        //def mvnHome = tool 'M3'
        maven 'Maven'
        jdk 'JDK'
        gradle "gradle"
        dockerTool 'docker'
    }
    
    environment{
        CHECK_URL = "http://192.168.56.22:8080/"
        CMD = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL}"
             }
    

    stages{
        stage("Clean ip"){
            steps{
                deleteDir()
            }
        }
        
        stage("Clone Repo"){
            steps{
                sh "git clone https://github.com/BadTrippp/spring-petclinic.git"
            }
        }
        
        stage("Build JAVA App"){
            steps{
                dir("spring-petclinic"){
                sh "mvn clean install -DskipTests -DskipITs"
                }
            }
        }
        
        stage("Code Quality Check"){
            steps{
                dir("spring-petclinic"){
                withSonarQubeEnv(installationName: 'sonarqube'){
                    //println "${env.SONAR_HOST_URL}"
                    //sh "pwd"
                    sh "mvn sonar:sonar -Dsonar.projectKey=test"
                }
                }
            }
        }
        
        stage("Unit Test"){
                    steps{
                         dir("spring-petclinic"){
                        sh "mvn test"
                        }
                    }
                }
        
        stage("Build Docker Image"){
            steps{
                dir("spring-petclinic"){
                    sh "docker build -t 192.168.56.44:8086/web-image-host ."
                }
            }
        }
        
        stage("Login to Nexus Repos"){
            steps{
                dir("spring-petclinic"){
                    sh "docker login -u admin -p admin 192.168.56.44:8086"
                }
            }
        }
        
        stage("Publish Image to Nexus From Jenkins"){
            steps{
                dir("spring-petclinic"){
                   sh "docker push 192.168.56.44:8086/web-image-host"
                }
            }
        }
        
        stage("Jenkins Log out Nexus"){
            steps{
                dir("spring-petclinic"){
                   sh "docker logout 192.168.56.44:8086"
                }
            }
        }
        
        stage("Release VM : CLEAN"){
            steps{
                sshagent(['release-remote']) {
                 sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 /home/admin/pipeline-script/cleanDocker.sh'
                }
            }
        }
        
        stage("Release VM : Login Nexus"){
            steps{
                sshagent(['release-remote']) {
                 sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 docker login -u admin -p admin 192.168.56.44:8086/web-image-host'
                }
            }
        }
        
        stage("Release VM : Pull Image From Nexus"){
            steps{
                sshagent(['release-remote']) {
                 sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 docker pull 192.168.56.44:8086/web-image-host'
                 sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 docker tag 192.168.56.44:8086/web-image-host:latest website'
                 sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 docker rmi 192.168.56.44:8086/web-image-host'
                }
            }
        }
        
        stage("Release VM : Deploy WEBSITE image"){
            steps{
                sshagent(['release-remote']) {
                 sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 docker run -d -p 8080:8080 --name spring-web website'
                }
            }
        }
        
        stage("Release VM : Logout Nexus"){
            steps{
                sshagent(['release-remote']) {
                 sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 docker logout 192.168.56.44:8086'
                }
            }
        }
      
        stage("HEALTH CHECK WEBSITE"){
                steps{
                script {
                 sshagent(['release-remote']) {
                code_return= """${sh( returnStatus: true, script: 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 /home/admin/pipeline-script/healthCheck.sh')}"""
                 //sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 /home/admin/pipeline-script/healthCheck.sh'
                 if (code_return == "1"){
                                WEB_STATUS=false
                              
                            }
                if (code_return == "0"){
                                WEB_STATUS=true
                            
                            }
                 }
                 
                }
                
            }
        }
        
         stage("WEB STATUS : OK --- BACKUP"){
                steps{
                    script {
                 sshagent(['release-remote']) {
                     if (WEB_STATUS == true){
                sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 /home/admin/pipeline-script/backUpImage.sh'
                            }
             }
         }
                }
        }
        
        stage("WEB STATUS : FAIL --- ROLLBACK"){
                steps{
                    script {
                 sshagent(['release-remote']) {
                     if (WEB_STATUS == false){
                sh 'ssh -o StrictHostKeyChecking=no -l admin 192.168.56.22 /home/admin/pipeline-script/rollBackImage.sh'
                            }
             }
         }
                }
        }
        
    }
    
    post {
        success {
            script{
                sh "curl -s -X POST https://api.telegram.org/bot5560533701:AAGDe2JJYq8Bn6W7uo4VuXYtej_2PVmVLZU/sendMessage -d chat_id=-545811179 -d 'text=${currentBuild.fullDisplayName} is ${currentBuild.result}' "
            }
        }   
        
        failure {
            script{
                sh "curl -s -X POST https://api.telegram.org/bot5560533701:AAGDe2JJYq8Bn6W7uo4VuXYtej_2PVmVLZU/sendMessage -d chat_id=-545811179 -d 'text=${currentBuild.fullDisplayName} is ${currentBuild.result}' "
            }
        }
        
    }
    
}
