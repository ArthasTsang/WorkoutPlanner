output "docdb" {
  description = "DocumentDB cluster"
  value       = aws_docdb_cluster.docdb
}

output "docdb_cluster_identifier" {
  description = "DocumentDB cluster id"
  value       = aws_docdb_cluster.docdb.cluster_identifier
}

output "docdb_secret" {
  description = "Secret name"
  value       = aws_secretsmanager_secret.docdb_secret.name
}

output "docdb_secret_arn" {
  description = "Secret arn"
  value       = aws_secretsmanager_secret.docdb_secret.arn
}

output "secret_rotation_function_arn" {
  description = "Secret rotation function arn"
  value       = aws_lambda_function.db_rotator.arn
}