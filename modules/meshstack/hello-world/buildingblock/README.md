---
name: Hello World
supportedPlatforms:
  - meshstack
description: Greets someone by name — a minimal OpenTofu building block with a few user inputs that provisions no infrastructure.
# No cloud-side setup to perform: the module only renders a message from its inputs.
requiresBackplane: false
---

# Hello World Building Block

A minimal OpenTofu building block for meshStack. It renders a greeting from a handful of inputs and
returns it as an output and as the markdown summary meshPanel shows after the run. It provisions
no infrastructure, which makes it a safe template for new building blocks and a quick end-to-end
check of building block runs.

| Input | meshStack type | Assignment | Notes |
|---|---|---|---|
| `name` | `STRING` | user input | Validated by regex in meshPanel |
| `greeting` | `SINGLE_SELECT` | user input, optional | Falls back to the variable default `Hello` |
| `repeat` | `INTEGER` | user input, optional | 1–10, falls back to `1` |
| `shout` | `BOOLEAN` | user input | Defaults to `false` |
| `workspace_identifier` | `STRING` | `WORKSPACE_IDENTIFIER` | Injected by meshStack |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [terraform_data.greeting](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_greeting"></a> [greeting](#input\_greeting) | Word the greeting starts with. | `string` | `"Hello"` | no |
| <a name="input_name"></a> [name](#input\_name) | Who to greet. | `string` | n/a | yes |
| <a name="input_repeat"></a> [repeat](#input\_repeat) | How many times the greeting is repeated. | `number` | `1` | no |
| <a name="input_shout"></a> [shout](#input\_shout) | Whether the greeting is rendered in upper case. | `bool` | `false` | no |
| <a name="input_workspace_identifier"></a> [workspace\_identifier](#input\_workspace\_identifier) | Identifier of the workspace that ordered this building block, injected by meshStack. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_message"></a> [message](#output\_message) | The rendered greeting. |
| <a name="output_summary"></a> [summary](#output\_summary) | Markdown summary shown in meshPanel after the run. |
<!-- END_TF_DOCS -->
