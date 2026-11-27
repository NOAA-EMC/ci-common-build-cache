#!/usr/bin/env bash

# Use a pinned Grype release; vulnerability data is downloaded separately.
grype_archive="$RUNNER_TEMP/grype.tar.gz"
curl -fsSL "https://github.com/anchore/grype/releases/download/v0.122.1/grype_0.122.1_linux_amd64.tar.gz" -o "$grype_archive"
echo "f1ba7e2917ee1395618de20a98da0aa7c0fb1788927797651047c50502a37538  $grype_archive" | sha256sum --check --strict
tar -xzf "$grype_archive" -C "$RUNNER_TEMP" grype
grype="$RUNNER_TEMP/grype"
"$grype" db update
export GRYPE_DB_AUTO_UPDATE=false

# External packages have no Spack installation metadata.
spack find -p --format '{/hash}' | awk '{print $NF}' | sort -u > "$RUNNER_TEMP/spack-prefixes"
spack find -e -p --format '{/hash}' | awk '{print $NF}' | sort -u > "$RUNNER_TEMP/spack-external-prefixes"
comm -23 "$RUNNER_TEMP/spack-prefixes" "$RUNNER_TEMP/spack-external-prefixes" > "$RUNNER_TEMP/spack-managed-prefixes"
if [ ! -s "$RUNNER_TEMP/spack-managed-prefixes" ]; then
  echo "::error::No installed Spack-managed packages found to scan."
  exit 1
fi

findings="$RUNNER_TEMP/spack-vulnerabilities.tsv"
: > "$findings"
missing_sbom=0
while IFS= read -r prefix; do
  sbom="$prefix/.spack/sbom/spdx-2.3.json"
  if [ ! -f "$sbom" ]; then
    echo "::error::Missing Spack SBOM: $sbom"
    missing_sbom=1
    continue
  fi
  echo "Scanning $sbom."
  "$grype" "sbom:$sbom" --config .grype.yaml -o json > "$RUNNER_TEMP/grype-report.json"
  jq -e '(.matches | type) == "array"' "$RUNNER_TEMP/grype-report.json" > /dev/null
  jq -r '.matches[] | [.artifact.name, .artifact.version, .vulnerability.id, .vulnerability.severity, .vulnerability.dataSource] | @tsv' "$RUNNER_TEMP/grype-report.json" >> "$findings"
done < "$RUNNER_TEMP/spack-managed-prefixes"

sort -u "$findings" -o "$findings"
{
  echo "### Spack SBOM vulnerability scan"
  echo "Scan completed."
} >> "$GITHUB_STEP_SUMMARY"

if awk -F '\t' 'tolower($4) == "high" || tolower($4) == "critical" { found = 1 } END { exit !found }' "$findings"; then
  exit 1
fi
if [ "$missing_sbom" -ne 0 ]; then
  echo "::error::One or more installed packages lack an SBOM; publication is blocked."
  exit 1
fi
