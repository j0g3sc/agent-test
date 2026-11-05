# agent-test

A hello-world OpenTofu building block definition for meshStack. It follows the module layout of
[meshstack-hub](https://github.com/meshcloud/meshstack-hub):

```
modules/meshstack/hello-world/
├── buildingblock/            # the OpenTofu module meshStack runs for every building block
└── meshstack_integration.tf  # the building block definition, as a meshcloud/meshstack resource
```

The building block renders a greeting from its inputs and provisions no infrastructure.

| Input | meshStack type | Assignment |
|---|---|---|
| `name` | `STRING` | user input, regex-validated |
| `greeting` | `SINGLE_SELECT` (Hello, Hi, Howdy, Moin, Servus) | user input, optional |
| `repeat` | `INTEGER` (1–10) | user input, optional |
| `shout` | `BOOLEAN` | user input, default `false` |
| `workspace_identifier` | `STRING` | `WORKSPACE_IDENTIFIER`, injected by meshStack |

It returns `message` and a markdown `summary` that meshPanel shows after each run.

## Try the module locally

```sh
cd modules/meshstack/hello-world/buildingblock
tofu init
tofu apply -var name=World -var workspace_identifier=local
```

## Register the definition in meshStack

`meshstack_integration.tf` creates the definition through the
[meshcloud/meshstack](https://search.opentofu.org/provider/meshcloud/meshstack/latest) provider.
Authenticate the provider against your meshStack (`meshstack login`, or `MESHSTACK_ENDPOINT`,
`MESHSTACK_API_KEY` and `MESHSTACK_API_SECRET`), then:

```sh
cd modules/meshstack/hello-world
tofu init
tofu apply -var 'meshstack={owning_workspace_identifier="<your platform workspace>"}'
```

The version stays a draft until you apply with `-var 'hub={bbd_draft=false}'`.

### Private repository

meshStack clones the module from this repository on every run. While the repository is private,
give meshStack a read-only deploy key:

1. Generate a key pair: `ssh-keygen -t ed25519 -N '' -f hello-world-deploy-key`
2. Add `hello-world-deploy-key.pub` as a read-only deploy key of this repository on GitHub.
3. Apply with the SSH URL and the private key:

   ```sh
   tofu apply \
     -var 'meshstack={owning_workspace_identifier="<your platform workspace>"}' \
     -var 'repository_url=git@github.com:j0g3sc/agent-test.git' \
     -var "repository_ssh_private_key=$(cat hello-world-deploy-key)"
   ```
