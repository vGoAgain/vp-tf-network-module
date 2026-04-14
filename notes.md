# Terraform Network Module — Notes

This is a Terraform module that requires inputs, as it is intended to be reused by many people. Users can pass in their own values to provision AWS network resources.

> See examples at: https://github.com/terraform-aws-modules

## How Modules Work

```
input variables          output.tf
---------------->  MODULE  ----------->
```

**Note:** Do not hardcode the Terraform version in modules.

---

## `variables.tf`

Declares all variables used across the module. Most are straightforward, but the most complex one is `subnet_data`:

```hcl
variable "subnet_data" {
  type = map(list(object({
    public            = bool
    cidr              = string
    availability_zone = string
  })))
}
```

This is a **map of lists**, where each list contains objects with 3 properties.

### Reading the type inside-out

| Layer     | Type            | What it means                                       |
|-----------|-----------------|-----------------------------------------------------|
| Innermost | `object({...})` | A single subnet definition with 3 fields            |
| Middle    | `list(object)`  | A list of those subnet objects                      |
| Outer     | `map(list)`     | A map (key → value) where each key points to a list |

---

## `main.tf`

Contains the main code for creating the network infrastructure for deployment on AWS.



## `outputs.tf`

The module has to return some data in order for it to be correctly used. So the output.tf file contains what data the module gets for us and can be used by the calling party.

---

## `terraform.tfvars`

`terraform.tfvars` is a file where you **set the actual values** for variables declared in `variables.tf`.

When you run `terraform plan` or `terraform apply`, Terraform automatically picks up `terraform.tfvars` and uses the values inside it — no extra flags needed.

**Why separate variables from their values?**

- `variables.tf` defines *what* inputs the module accepts (types, descriptions)
- `terraform.tfvars` defines *what values* to use for a specific deployment

This means the same module can be deployed differently by swapping the `.tfvars` file:

```
terraform.tfvars        ← dev environment (small CIDRs, 1 subnet)
production.tfvars       ← prod environment (larger CIDRs, 3 subnets)
```

To use a non-default tfvars file:
```bash
terraform apply -var-file="production.tfvars"
```

**What goes in `.tfvars` vs `variables.tf`?**

| | `variables.tf` | `terraform.tfvars` |
|---|---|---|
| Type definition | yes | no |
| Description | yes | no |
| Default value | yes (optional) | no |
| Actual value | no | yes |

> **Note:** `terraform.tfvars` is auto-loaded and often committed to git — never put secrets (passwords, API keys) in it. Use environment variables or a secrets manager for those instead.