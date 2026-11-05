variable "repository_url" {
  type        = string
  default     = "https://github.com/j0g3sc/agent-test.git"
  description = "Git URL meshStack clones the building block from. While the repository is private, use the SSH form `git@github.com:j0g3sc/agent-test.git` together with `repository_ssh_private_key`."
}

variable "repository_ssh_private_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "Private half of a read-only GitHub deploy key, so meshStack can clone the repository while it is private. Leave null for a public repository."
}

variable "bbd_display_name" {
  type        = string
  default     = null
  description = "Overrides the name of the marketplace entry application teams see in the catalog."
}

variable "bbd_description" {
  type        = string
  default     = null
  description = "Overrides the one-line description shown next to the marketplace entry."
}

variable "bbd_readme" {
  type        = string
  default     = null
  description = "Overrides the markdown readme shown in the marketplace before ordering."
}

variable "meshstack" {
  type = object({
    owning_workspace_identifier = string
    tags                        = optional(map(list(string)), {})
  })
  description = "Shared meshStack context. Tags are optional and propagated to building block definition metadata."
}

variable "hub" {
  type = object({
    git_ref   = optional(string, "main")
    bbd_draft = optional(bool, true)
  })
  const = true
  default = {
    git_ref   = "main"
    bbd_draft = true
  }
  description = <<-EOT
  `git_ref`: Reference of the j0g3sc/agent-test repository to run. Set to a tag (e.g. 'v1.2.3'), branch or commit sha.
  `bbd_draft`: If true, the building block definition version is kept in draft mode.
  EOT
}

output "building_block_definition" {
  description = "BBD is consumed in building block compositions."
  value = {
    uuid        = meshstack_building_block_definition.this.metadata.uuid
    version_ref = var.hub.bbd_draft ? meshstack_building_block_definition.this.version_latest : meshstack_building_block_definition.this.version_latest_release
  }
}

resource "meshstack_building_block_definition" "this" {
  metadata = {
    owned_by_workspace = var.meshstack.owning_workspace_identifier
    tags               = var.meshstack.tags
  }

  spec = {
    display_name = coalesce(var.bbd_display_name, "Hello World")
    description  = coalesce(var.bbd_description, "Greets someone by name. A minimal OpenTofu building block that provisions no infrastructure.")
    # Embedded rather than linked, so the logo also shows while the repository is private.
    symbol           = provider::meshstack::load_image_file("${path.module}/buildingblock/logo.svg")
    target_type      = "WORKSPACE_LEVEL"
    run_transparency = true
    readme = coalesce(var.bbd_readme, chomp(<<-EOT
      Hello World greets someone by name and shows the greeting in meshPanel. It provisions no
      infrastructure, so it is safe to order, change and delete as often as you like.

      ## 🎯 When to use it

      Use this building block when you:
      - Want to see how ordering a building block works before you order a real one.
      - Want to check that building block runs work end to end in your workspace.

      ## 💡 Usage examples

      **Example 1: First steps in meshStack**
      A developer new to meshStack orders Hello World with their own name, watches the run, and
      finds the greeting in the building block's summary.

      **Example 2: Trying out inputs**
      A developer changes the greeting, the repeat count and the shout flag on an existing block and
      sees the next run pick up the new values.

      ## 📊 Shared Responsibility

      | Responsibility | Platform Team | Application Team |
      |---|:---:|:---:|
      | Maintain the building block definition | ✅ | ❌ |
      | Keep building block runs working | ✅ | ❌ |
      | Choose who to greet and how | ❌ | ✅ |
      | Delete the building block when done | ❌ | ✅ |
      EOT
    ))
  }

  version_spec = {
    draft         = var.hub.bbd_draft
    deletion_mode = "DELETE"

    implementation = {
      terraform = {
        terraform_version              = "1.12.5"
        repository_url                 = var.repository_url
        repository_path                = "modules/meshstack/hello-world/buildingblock"
        ref_name                       = var.hub.git_ref
        use_mesh_http_backend_fallback = true
        ssh_private_key                = var.repository_ssh_private_key == null ? null : provider::meshstack::non_ephemeral_secret(nonsensitive(var.repository_ssh_private_key))
        # GitHub's published host key, see https://api.github.com/meta
        ssh_known_host = var.repository_ssh_private_key == null ? null : {
          host      = "github.com"
          key_type  = "ssh-ed25519"
          key_value = "AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
        }
      }
    }

    inputs = {
      name = {
        assignment_type                = "USER_INPUT"
        display_name                   = "Name"
        description                    = "Who to greet."
        type                           = "STRING"
        value_validation_regex         = "^\\S.{0,63}$"
        validation_regex_error_message = "Enter up to 64 characters, starting with a non-blank one."
        updateable_by_consumer         = true
      }

      greeting = {
        assignment_type        = "USER_INPUT"
        display_name           = "Greeting"
        description            = "Word the greeting starts with. Defaults to Hello."
        type                   = "SINGLE_SELECT"
        selectable_values      = ["Hello", "Hi", "Howdy", "Moin", "Servus"]
        is_optional            = true
        updateable_by_consumer = true
      }

      repeat = {
        assignment_type        = "USER_INPUT"
        display_name           = "Repeat"
        description            = "How many times the greeting is repeated, from 1 to 10. Defaults to 1."
        type                   = "INTEGER"
        is_optional            = true
        updateable_by_consumer = true
      }

      shout = {
        assignment_type        = "USER_INPUT"
        display_name           = "Shout"
        description            = "Render the greeting in upper case."
        type                   = "BOOLEAN"
        default_value          = jsonencode(false)
        updateable_by_consumer = true
      }

      workspace_identifier = {
        assignment_type = "WORKSPACE_IDENTIFIER"
        display_name    = "Workspace Identifier"
        description     = "Identifier of the workspace that ordered this building block. Injected by meshStack."
        type            = "STRING"
      }
    }

    outputs = {
      message = {
        assignment_type = "NONE"
        display_name    = "Message"
        type            = "STRING"
      }

      summary = {
        assignment_type = "SUMMARY"
        display_name    = "Summary"
        type            = "STRING"
      }
    }
  }
}

terraform {
  required_version = ">= 1.12.0"

  required_providers {
    meshstack = {
      source  = "meshcloud/meshstack"
      version = ">= 0.27.2"
    }
  }
}
