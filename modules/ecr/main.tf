resource "aws_ecr_repository" "repo" {
    name = "${lower(var.project_name)}-repo"
}