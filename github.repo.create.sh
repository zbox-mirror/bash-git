#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

curl=$( which curl )
sleep="2"

OPTIND=1

while getopts "t:n:d:x:o:ipwh" opt; do
  case ${opt} in
    t)
      token="${OPTARG}"
      ;;
    n)
      name="${OPTARG}"; IFS=';' read -ra name <<< "${name}"
      ;;
    d)
      description="${OPTARG}"
      ;;
    x)
      homepage="${OPTARG}"
      ;;
    o)
      org="${OPTARG}"
      ;;
    i)
      set_issues=1
      ;;
    p)
      set_projects=1
      ;;
    w)
      set_wiki=1
      ;;
    h|*)
      echo "-t [token] -n [name] -d [description] -x [homepage] -o [org] -i -p -w"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#name[@]} )) || [[ -z "${org}" ]] && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

[[ -n "${set_issues}" ]] && has_issues="true" || has_issues="false"
[[ -n "${set_projects}" ]] && has_projects="true" || has_projects="false"
[[ -n "${set_wiki}" ]] && has_wiki="true" || has_wiki="false"

for i in "${name[@]}"; do
  echo "" && echo "--- Open: ${i}"

  ${curl}                                     \
  -X POST                                     \
  -H "Authorization: token ${token}"          \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/orgs/${org}/repos"  \
  -d @- << EOF
{
  "name": "${i}",
  "description": "${description}",
  "homepage": "${homepage}",
  "has_issues": ${has_issues},
  "has_projects": ${has_projects},
  "has_wiki": ${has_wiki}
}
EOF

  echo "" && echo "--- Done: ${i}" && echo ""

  sleep ${sleep}
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0
