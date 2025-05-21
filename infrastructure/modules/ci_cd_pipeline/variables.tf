variable "prefix" {
  description = "This is the environment your webapp will be prefixed with. dev, qa, or prod"
  type        = string
}

variable "autoscaling_group_name" {
  type = string
}

variable "github_repo_owner" {
    type = string
}

variable "github_repo_name" {
    type = string
}

variable "github_repo_branch" {
    type = string
    default = "main"
}

variable "github_token" {
  type = string
}
