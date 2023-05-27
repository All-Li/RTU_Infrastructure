parameters {
    choice(
        name: 'PROVIDER',
        choices: ['AWS', 'Azure'],
        description: 'Select the target provider'
    )
    booleanParam(
        name: 'BUILD',
        defaultValue: true,
        description: 'Build the infrastructure (otherwise, DESTROY it)'
    )
}

currentBuild.displayName = "${params.PROVIDER}_${params.BUILD ? 'build' : 'destroy'}"

pipeline {
    agent any

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Provider initialization") {
            steps {
                script {
                    def providerDir
                    if (params.PROVIDER == 'AWS') {
                        providerDir = 'AWS'
                    } else {
                        providerDir = 'Azure'
                    }

                    dir("${providerDir}") {
                        sh "terraform init -backend-config=backend.config -reconfigure"

                    }
                }
            }
        }

        stage("Build/Destroy infrastructure") {
            steps {
                script {
                    def providerDir
                    if (params.PROVIDER == 'AWS') {
                        providerDir = 'AWS'
                    } else {
                        providerDir = 'Azure'
                    }

                    dir("${providerDir}") {
                        if (params.BUILD) {
                            sh "terraform apply -auto-approve"
                        }
                         else {
                            sh "terraform destroy -auto-approve"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'rm -f terraform/**/*.tfstate*'
        }
    }
}