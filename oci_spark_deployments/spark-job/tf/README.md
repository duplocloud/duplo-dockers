# README #

This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### How do I get set up? ###


On a UNIX-like (or Mac OS) environment:

- Install basic tools:  `jq`, `curl`
- Install `terraform` 0.14 or later
- Optional: install `direnv` to manage your environment variables

#### Set up environment variables

If you are using `direnv`, populate the following in your `.envrc` (in the project root), then run `direnv allow`.

If you are not using `direnv`, you can just run the following in your shell.

```shell
# .envrc

# Needed to authenticate to Duplo
export duplo_token="!! REPLACE WITH YOUR DUPLO TOKEN (generated from the Duplo UI) !!"
export duplo_host="https://gritfinancial.duplocloud.net"
export AWS_RUNNER=duplo-admin
```

### Configuring the application

config subdirectory:  config/@TENANT_NAME@/@TF_PROJECT_NAME@.tfvars.json

### Deploying the application

Come up with a name for your tenant, such as `apps-dev05`.

Replace the `dev` below with whatever your tenant name is.

#### Planning changes with Terraform

A plan is non-destructive, it is just like a "dry run".

```shell
name="dev"  # <== CHANGE "dev" HERE

# Plans the tenant
scripts/plan.sh "$name" tenant

# Plans the apps
scripts/plan.sh "$name" apps

```

#### Applying changes with Terraform

Applying changes can be **DESTRUCTIVE**.  Always check what your changes might be, first, by running `plan.sh` (see above).

```shell
name="dev"  # <== CHANGE "dev" HERE

# Applies the base infrastructure
scripts/apply.sh "$name" tenant

# Applies the tenant and any services used by the application.
scripts/apply.sh "$name" acdc

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact