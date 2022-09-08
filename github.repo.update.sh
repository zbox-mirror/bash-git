#!/usr/bin/bash -e

(( EUID == 0 )) && { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

curl="$( command -v curl )"
sleep="2"

# Help.
read -r -d '' help <<- EOF
Options:
  -x 'TOKEN'                              GitHub user token.
  -o 'OWNER'                              Repository owner (organization).
  -r 'REPO_1;REPO_2;REPO_3'               Repository name array.
  -d 'DESCRIPTION'                        Repository description.
  -s 'https://example.org/'               Repository site URL.
  -p                                      Is private repository.
  -i                                      Has issues.
  -j                                      Has projects.
  -w                                      Has WIKI.
EOF

# -------------------------------------------------------------------------------------------------------------------- #
# OPTIONS.
# -------------------------------------------------------------------------------------------------------------------- #

OPTIND=1

while getopts "x:o:r:d:s:pijwh" opt; do
  case ${opt} in
    x)
      token="${OPTARG}"
      ;;
    o)
      owner="${OPTARG}"
      ;;
    r)
      repos="${OPTARG}"; IFS=';' read -ra repos <<< "${repos}"
      ;;
    d)
      description="${OPTARG}"
      ;;
    s)
      homepage="${OPTARG}"
      ;;
    p)
      private=1
      ;;
    i)
      has_issues=1
      ;;
    j)
      has_projects=1
      ;;
    w)
      has_wiki=1
      ;;
    h|*)
      echo "${help}"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#repos[@]} )) || [[ -z "${owner}" ]] && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

[[ -n "${private}" ]] && private="true" || private="false"
[[ -n "${has_issues}" ]] && has_issues="true" || has_issues="false"
[[ -n "${has_projects}" ]] && has_projects="true" || has_projects="false"
[[ -n "${has_wiki}" ]] && has_wiki="true" || has_wiki="false"

for repo in "${repos[@]}"; do
  echo "" && echo "--- OPEN: '${repo}'"

  ${curl} -X PATCH \
    -H "Authorization: Bearer ${token}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${owner}/${repo}" \
    -d @- << EOF
{
  "name": "${repo}",
  "description": "${description}",
  "homepage": "${homepage}",
  "private": ${private},
  "has_issues": ${has_issues},
  "has_projects": ${has_projects},
  "has_wiki": ${has_wiki}
}
EOF

  echo "" && echo "--- DONE: '${repo}'" && echo ""

  sleep ${sleep}
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0
