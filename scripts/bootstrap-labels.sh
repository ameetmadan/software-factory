#!/usr/bin/env bash
set -euo pipefail

# Creates the label set this repo's issue templates and skills rely on.
# Safe to re-run: --force updates existing labels instead of failing.

labels=(
  "epic|5319e7|Top-level software-factory sub-project"
  "task|1d76db|Concrete unit of work under an epic"
  "ai-pipeline|0e8a16|AI pipeline & guardrails sub-project"
  "discovery|fbca04|Discovery/planning kit sub-project"
  "scaffolding|f9d0c4|Project scaffolding/generator sub-project"
  "ci|c5def5|CI pipeline templates sub-project"
  "iac|bfd4f2|IaC modules sub-project"
  "deploy|d4c5f9|Deployment automation sub-project"
  "feature|0e8a16|New feature candidate scored via RICE"
)

for entry in "${labels[@]}"; do
  IFS='|' read -r name color description <<< "$entry"
  gh label create "$name" --color "$color" --description "$description" --force
done

echo "Bootstrapped ${#labels[@]} labels."
