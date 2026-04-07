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
