pipeline {

  agent any

  options {
    withBuildUser()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  parameters {
    string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build and deploy')
    choice(
      name: 'SERVER',
      choices: ['', 'staging.atlaz.thrillo.dev'],
      description: 'Override deploy server (leave empty for default)'
    )
  }

  environment {
    // ── Update these two lines when moving to the org repo ──────────────────
    GIT_REPO   = 'git@github.com:Ronaq13/Atlaz.git'
    IMAGE_REPO = 'ghcr.io/ronaq13/atlaz'
    // ────────────────────────────────────────────────────────────────────────
    K8S_NAMESPACE    = 'staging-1'
    GHCR_CREDS        = credentials('ghcr-token')               // username + PAT
    KUBECONFIG_CREDS  = credentials('k8s-staging-kubeconfig')  // kubeconfig file
    RAILS_MASTER_KEY  = credentials('atlaz-staging-master-key') // Secret text
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: "${params.BRANCH}",
            url: "${env.GIT_REPO}"
      }
    }

    stage('Build Image') {
      steps {
        script {
          env.IMAGE_TAG  = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          env.IMAGE_FULL = "${env.IMAGE_REPO}:${env.IMAGE_TAG}"
        }
        sh """
          echo "Building ${env.IMAGE_FULL}"
          docker build -t ${env.IMAGE_FULL} -t ${env.IMAGE_REPO}:latest .
        """
      }
    }

    stage('Push to GHCR') {
      steps {
        sh """
          echo "${GHCR_CREDS_PSW}" | docker login ghcr.io -u "${GHCR_CREDS_USR}" --password-stdin
          docker push ${env.IMAGE_FULL}
          docker push ${env.IMAGE_REPO}:latest
        """
      }
    }

    stage('Deploy to K8s') {
      steps {
        script {
          def deployUser = env.BUILD_USER ?: env.BUILD_USER_ID ?: 'Jenkins'
          try {
            def causes = currentBuild.getBuildCauses()
            for (c in causes) {
              if (c.userId) { deployUser = (c.userName ?: c.userId) as String; break }
              if (c.shortDescription?.contains('Started by user')) {
                deployUser = (c.shortDescription - 'Started by user').trim(); break
              }
            }
          } catch (e) { /* use default */ }

          echo "Deploying ${env.IMAGE_TAG} (by ${deployUser})"
        }

        withEnv(["KUBECONFIG=${KUBECONFIG_CREDS}"]) {
          sh """
            # Update image on both deployments
            # Inject RAILS_MASTER_KEY (only needed once, but idempotent to re-set)
            kubectl set env deployment/atlaz         RAILS_MASTER_KEY=${RAILS_MASTER_KEY} -n ${env.K8S_NAMESPACE}
            kubectl set env deployment/atlaz-sidekiq RAILS_MASTER_KEY=${RAILS_MASTER_KEY} -n ${env.K8S_NAMESPACE}

            kubectl set image deployment/atlaz \
              atlaz=${env.IMAGE_FULL} \
              -n ${env.K8S_NAMESPACE}

            kubectl set image deployment/atlaz-sidekiq \
              atlaz-sidekiq=${env.IMAGE_FULL} \
              -n ${env.K8S_NAMESPACE}

            # Wait for rollout to complete
            kubectl rollout status deployment/atlaz         -n ${env.K8S_NAMESPACE} --timeout=5m
            kubectl rollout status deployment/atlaz-sidekiq -n ${env.K8S_NAMESPACE} --timeout=5m

            # Run migrations in a one-off pod using the new image
            kubectl run db-migrate-${env.IMAGE_TAG} \
              --image=${env.IMAGE_FULL} \
              --restart=Never \
              --namespace=${env.K8S_NAMESPACE} \
              --env="RAILS_ENV=staging1" \
              --overrides='{"spec":{"envFrom":[{"configMapRef":{"name":"atlaz-config"}},{"secretRef":{"name":"atlaz-secrets"}}]}}' \
              --command -- bundle exec rails db:migrate

            # Wait for migration pod to finish
            kubectl wait pod/db-migrate-${env.IMAGE_TAG} \
              --for=condition=Ready \
              --namespace=${env.K8S_NAMESPACE} \
              --timeout=3m || true

            kubectl logs pod/db-migrate-${env.IMAGE_TAG} -n ${env.K8S_NAMESPACE} || true
            kubectl delete pod/db-migrate-${env.IMAGE_TAG} -n ${env.K8S_NAMESPACE} --ignore-not-found
          """
        }
      }
    }

  }

  post {
    always {
      sh 'docker logout ghcr.io || true'
    }
    success {
      echo "Successfully deployed ${env.IMAGE_TAG} to ${K8S_NAMESPACE}"
    }
    failure {
      echo "Deployment failed for ${env.IMAGE_TAG}"
    }
  }
}
