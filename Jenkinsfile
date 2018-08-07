#!/usr/bin/env groovy

/**
 * Jenkinsfile
 */
pipeline {
    agent any 
    //agent { docker { image 'python:2.7' } }
    // agent {
    //     dockerfile {
    //         filename 'Dockerfile'
    //         dir 'build'
    //         label 'lambda-builder'
    //     }
    // }

    environment {
        projectName = 'LambdaTestProject'
        VIRTUAL_ENV = "${env.WORKSPACE}/src/test/resources/fide-data-lake-virtualenv"
    }

    stages {

        stage ("Cleanup") {
            steps {
                deleteDir()
                sh 'ls -lah'
            }
        }


        stage ('Clone_Resource') {
            steps {
                //git url: 'https://github.com/BEEVA-JuanJaraices/helloworld_python_test.git'
                checkout(
                    [
                        $class: "GitSCM", branches: [[name: "refs/heads/develop"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        submoduleCfg: [],
                        userRemoteConfigs: [
                            [url: 'https://github.com/BEEVA-JuanJaraices/helloworld_python_test.git']
                        ]
                    ]
                )
            }
        }

        // stage ('Setup_Environment') {
        //     steps {
                
        //     }
            //docker.build('lambda-builder')
            // steps {
            //     sh """
            //         apt-get update -y -q 
            //         apt-get install -y libxslt-devel
            //         apt-get install -y curl python27 python27-devel python27-pip python27-libs build-essential libxml2-devel libffi-dev gcc \
            //             openssl libssl-dev git zip gzip wget

            //         wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && ln -s /usr/local/bin/pip /usr/bin/pip
            //         pip install --upgrade pip && pip install -q virtualenv
            //     """
            // }
        // }

        stage ('Unit Test') {
        	steps {
                sh """
                    #!/usr/bin/env sh
                    make clean
                    make test LAMBDA_FUNCTION=HelloWorld
                """
        	}
        }

        // stage ('Integration Test') {

        // }

        // stage ('Sonarqube') {

        // }

        // stage ('Upload S3') {

        // }

        // stage ('Refresh Lambda') {

        // }
    }
}