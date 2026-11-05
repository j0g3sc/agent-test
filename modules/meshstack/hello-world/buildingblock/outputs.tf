output "message" {
  value       = terraform_data.greeting.output
  description = "The rendered greeting."
}

output "summary" {
  description = "Markdown summary shown in meshPanel after the run."
  value       = <<-EOT
    # 👋 ${terraform_data.greeting.output}

    This building block greeted **${var.name}** on behalf of workspace `${var.workspace_identifier}`.
    It provisions no infrastructure.
  EOT
}
