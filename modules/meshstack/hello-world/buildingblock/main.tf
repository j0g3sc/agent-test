# This building block provisions nothing outside its own state. terraform_data records the message,
# so a run that changes an input shows up as a change in the run log.
locals {
  greeting = "${var.greeting}, ${var.name}!"
  message  = join(" ", [for _ in range(var.repeat) : var.shout ? upper(local.greeting) : local.greeting])
}

resource "terraform_data" "greeting" {
  input = local.message
}
