# flux-cloud-infrastructures

This repository is used to manage our cloud infrastructure with Terraform. It provisions and maintains cloud resources across multiple environments.
The infrastructure is structured by region and environment to maintain clarity, consistency, and proper separation of resources.

```
.
├── .github
│   └── workflows
│       └── terraform-ci.yml
├── eu-central-1
│   ├── staging
│   └── production
├── .gitignore
└── README.md

```

- .github/workflows – Contains the GitHub Actions workflows used for continuous integration by formatting and validating every terraform scripts.
- eu-central-1 – Holds Terraform configurations organized by environment (staging, and production). Each folder represents a separate deployment environment.

## Contribution Workflow

> Important: All Terraform changes must be submitted through a Pull Request (PR). Direct pushes to the repository are strictly prohibited.

Terraform planning and application are automated using Atlantis, which is integrated with this repository. Atlantis only operates on Pull Requests. Any Terraform changes not submitted via a PR will be blocked and will not be planned or applied.

## How Infrastructure Changes Are Applied

- Create a new branch from the appropriate base branch.
- Make your Terraform changes (only .tf files).
- Open a Pull Request.

Once the PR is opened:

- GitHub Actions runs validation checks.
- Atlantis automatically executes terraform plan.
- A team member reviews the code.
- After approval, Atlantis applies the changes by running atlantis apply directly from the PR comments.

This workflow ensures that all infrastructure changes are reviewed, validated, and applied in a secure, controlled, and auditable manner across all environments.
