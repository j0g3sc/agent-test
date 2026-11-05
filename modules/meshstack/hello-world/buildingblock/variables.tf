variable "name" {
  type        = string
  description = "Who to greet."
}

variable "greeting" {
  type        = string
  default     = "Hello"
  description = "Word the greeting starts with."
}

variable "repeat" {
  type        = number
  default     = 1
  description = "How many times the greeting is repeated."

  validation {
    condition     = var.repeat >= 1 && var.repeat <= 10
    error_message = "repeat must be between 1 and 10."
  }
}

variable "shout" {
  type        = bool
  default     = false
  description = "Whether the greeting is rendered in upper case."
}

variable "workspace_identifier" {
  type        = string
  description = "Identifier of the workspace that ordered this building block, injected by meshStack."
}
