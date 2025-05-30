// pipeline {
//   agent any
//   stages {
//       stage('FASE 1 LOAD '){
//         steps{
//           load "C:/Users/mvelazquez/JenkinsFiles/Jenkinsfile"
//         }
//       }

//   }
// }

// stage('SCM') {
//     git 'https://github.com/foo/bar.git'
//   }
pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }

    triggers {
        // Poll every 5 minutes instead of using GitHub webhooks
        pollSCM('*/1 * * * *')
    }

    environment {
        KUBECONFIG = "/tmp/in-cluster-kubeconfig"
        CLUSTER_SERVER = "https://kubernetes.default.svc"
        SERVICE_ACCOUNT_CA = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        SERVICE_ACCOUNT_TOKEN = "/var/run/secrets/kubernetes.io/serviceaccount/token"
    }

    stages {
       
        stage('Step 1: LOAD SCM'){
            steps {
                // Get some code from a GitHub repository
                git branch: 'main', url: 'https://github.com/Isavb03/mysql-service.git'

            }
        }

        stage('STEP 2: SETUP KUBECONFIG') {
            steps {
                sh '''
                echo "Setting up kubeconfig..."
                
                kubectl config set-cluster in-cluster \
                    --server=${CLUSTER_SERVER} \
                    --certificate-authority=${SERVICE_ACCOUNT_CA} \
                    --embed-certs=true \
                    --kubeconfig=${KUBECONFIG}

                kubectl config set-credentials jenkins \
                    --token=$(cat ${SERVICE_ACCOUNT_TOKEN}) \
                    --kubeconfig=${KUBECONFIG}

                kubectl config set-context default \
                    --cluster=in-cluster \
                    --user=jenkins \
                    --kubeconfig=${KUBECONFIG}

                kubectl config use-context default --kubeconfig=${KUBECONFIG}

                echo "Current context:"
                kubectl config current-context --kubeconfig=${KUBECONFIG}
                '''
            }
        }


 

        stage('STEP 3: VALIDATE MANIFESTS'){
            steps{    

                sh '''

                echo "Validating manifests with discovery-based resolution..."
                kubectl apply --dry-run=client --validate=false -f manifests/mysql-deployment.yaml --kubeconfig=$KUBECONFIG
                kubectl apply --dry-run=client --validate=false -f manifests/mysql-service.yaml --kubeconfig=$KUBECONFIG
                kubectl apply --dry-run=client --validate=false -f manifests/mysql-pvc.yaml --kubeconfig=$KUBECONFIG
                '''
            }             
                             
        }

        stage('STEP 4: CLEANUP CONFIG MAPS'){
            steps{    

                sh """
                    # Delete ConfigMaps to ensure clean state
                    kubectl delete configmap mysql-custom-config --ignore-not-found=true
                    kubectl delete configmap mysql-initdb-config --ignore-not-found=true
                    sleep 10
                    
                """
            }             
                             
        }          
       

        stage('STEP 5: CREATE CONFIGMAPS'){
            steps{    

                sh """

                    echo "Creating ConfigMaps..."
                    
                    # Create MySQL Init ConfigMap
                    kubectl create configmap mysql-initdb-config \
                        --from-file=init.sql=./manifests/init.sql
                    
                    
                    # Create MySQL Custom Config ConfigMap
                    kubectl create configmap mysql-custom-config \
                        --from-file=z-custom.cnf=./manifests/z-custom.cnf

                """
            }             
                             
        }

        stage('STEP 6: DEPLOYMENT'){
            steps{     
                sh '''
                    echo "Deploying MySQL to Minikube..."
                    
                    # Create PVC first
                    kubectl apply -f manifests/mysql-pvc.yaml

                    kubectl apply -f manifests/mysql-secrets.yaml
                    
                    # Deploy MySQL
                    kubectl apply -f manifests/mysql-deployment.yaml
                    
                    # Create Service
                    kubectl apply -f manifests/mysql-service.yaml
                '''         
            }                      
        }    


        
        stage('STEP 7: VERIFY DEPLOYMENT'){
            steps{     
                sh '''
                    echo "Verifying MySQL deployment..."
                    
                    # Wait for MySQL pod to be ready (with timeout)
                    echo "Waiting for MySQL pod to be ready..."
                    kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s
                    
                    # Check if PVC is bound
                    echo "Checking PVC status..."
                    kubectl get pvc mysql-pvc
                    
                    # Check service exists
                    echo "Checking service..."
                    kubectl get service mysql-service
                    
                    # Show deployment status
                    echo "Deployment status:"
                    kubectl get all -l app=mysql
                    
                    # Show pod logs (last 20 lines) for debugging
                    echo "MySQL pod logs (last 20 lines):"
                    kubectl logs -l app=mysql --tail=20
                '''         
            }                      
        }      

    }

    post {

        success{
        echo "Build ${currentBuild.fullDisplayName} completed successfully!! :D"
        }
        failure {
            echo 'MySQL deployment failed!'
        }      
    }
}   