pipeline {
    agent any
    
    options {
        timestamps()
         ansiColor("xterm")
    }
     stages {

      stage('Trivy Test'){
         steps {
              sh 'trivy fs -f json -o resultsfile.json .'
              sh 'trivy repo -f json -o resultsrepo.json  https://github.com/CMG1911/hello-springrest-1.git'
         }
         post {
             always {
                recordIssues(tools: [trivy(pattern: 'resultsrepo.json')])
                recordIssues(tools: [trivy(pattern: 'resultsfile.json')])
             }
         }
       }
       stage('Tests'){
         steps {
              sh './gradlew test'
            }
            
         post {
             always {
                junit(testResults: 'build/test-results/test/*xml', allowEmptyResults: true)
                jacoco(
                    classPattern: 'build/classes/java/main',
                    execPattern: 'build/jacoco/*.exec',
                    sourcePattern: 'src/main/java/com/example/restservice')
             }
         }
       } 
        stage('Check-PMD'){
         steps {
              sh './gradlew check'
            }
            
         post {
             always {
                recordIssues(tools: [pmdParser(pattern: 'build/reports/pmd/*.xml')])

             }
         }
       }
        stage('Image builder') {
          steps {
            sh 'docker-compose build'
            sh "git tag 1.0.${BUILD_NUMBER}"
            sh "docker tag ghcr.io/cmg1911/hello-sprintrest ghcr.io/cmg1911/hello-sprintrest:1.0.${BUILD_NUMBER}"
            sshagent(['github-ssh']) {
                sh "git push --tags"}
          }
       }  
        stage('Package') {
          steps {
             withCredentials([string(credentialsId: 'token-git', variable: 'CR_PAT')]) {
                sh "echo $CR_PAT | docker login ghcr.io -u CMG1911 --password-stdin"
                sh 'docker-compose push'
                sh "docker push ghcr.io/cmg1911/hello-springrest:1.0.${BUILD_NUMBER}"
                sh 'trivy image -f json -o image1.json ghcr.io/cmg1911/hello-2048:latest'
                }
           }
          post {
             always {
                recordIssues(tools: [trivy(pattern: 'image.json')])
             }
          }
        }   
           
        stage('Deploy') {
            steps {
                withAWS(credentials: 'aws-amazon', region: 'eu-west-1') {
                    dir("eb") {
                        sh 'eb create spring-elastic'
                     }
                }
            }
        }
    }
}
