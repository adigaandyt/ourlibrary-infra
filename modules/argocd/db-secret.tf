# TODO: Add vars and an if check if to add a mongodb database secret
data "aws_secretsmanager_secret_version" "aws_mongodb_secret" {
  secret_id = var.database_secret_arn
}

# we have to create the namespace to host the secret on boot
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "letsreview"
  }
}

# Create a kubernetes secret for the SSH key so our ArgoCD can grab it
resource "kubernetes_secret" "mongodb_cluster_secret" {
  metadata {
    name      = "external-db-secrets"
    namespace = "letsreview"
  }


  data = {
    username                = jsondecode(data.aws_secretsmanager_secret_version.aws_mongodb_secret.secret_string)["username"]
    password                = jsondecode(data.aws_secretsmanager_secret_version.aws_mongodb_secret.secret_string)["password"]
    database                = jsondecode(data.aws_secretsmanager_secret_version.aws_mongodb_secret.secret_string)["database"]
    mongodb-passwords       = jsondecode(data.aws_secretsmanager_secret_version.aws_mongodb_secret.secret_string)["mongodb-passwords"]
    mongodb-root-password   = jsondecode(data.aws_secretsmanager_secret_version.aws_mongodb_secret.secret_string)["mongodb-root-password"]
    mongodb-replica-set-key = jsondecode(data.aws_secretsmanager_secret_version.aws_mongodb_secret.secret_string)["mongodb-replica-set-key"]
    MONGO_URL               = jsondecode(data.aws_secretsmanager_secret_version.aws_mongodb_secret.secret_string)["MONGO_URL"]
    DATABASE_NAME           = jsondecode(data.aws_secretsmanager_secret_version.aws_mongodb_secret.secret_string)["DATABASE_NAME"]
  }

  type = "Opaque"
}

