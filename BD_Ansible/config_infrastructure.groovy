parameters {
    choice(
        name: 'PROVIDER',
        choices: ['AWS', 'Azure'],
        description: 'Select the target provider'
    )
}

currentBuild.displayName = "$PROVIDER"
pipeline {
    agent any
    environment {
      ANSIBLE_PRIVATE_KEY=credentials('ansible-private-key') 
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }
        stage('Run Ansible') {
            steps {
                sh 'ansible-playbook -i inventory.hosts --private-key=$ANSIBLE_PRIVATE_KEY BD.yml'
            }
        }
    }
}