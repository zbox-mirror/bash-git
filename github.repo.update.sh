#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

curl=$( which curl )
sleep="2"

OPTIND=1

while getopts "t:o:n:d:x:l:ripwh" opt; do
  case ${opt} in
    t)
      token="${OPTARG}"
      ;;
    o)
      owner="${OPTARG}"
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
    r)
      private=1
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
      echo "-t '[token]'  -o '[owner]' -n '[name_1;name_2;name_3]' -d '[description]' -x '[homepage]'-r (private) -i (issues) -p (projects) -w (wiki)"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#name[@]} )) || [[ -z "${owner}" ]] && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

[[ -n "${private}" ]] && private="true" || private="false"
[[ -n "${set_issues}" ]] && has_issues="true" || has_issues="false"
[[ -n "${set_projects}" ]] && has_projects="true" || has_projects="false"
[[ -n "${set_wiki}" ]] && has_wiki="true" || has_wiki="false"

for i in "${name[@]}"; do
  echo "" && echo "--- Open: ${i}"

  ${curl}                                       \
  -X PATCH                                      \
  -H "Authorization: token ${token}"            \
  -H "Accept: application/vnd.github.v3+json"   \
  "https://api.github.com/repos/${owner}/repo"  \
  -d @- << EOF
{
  "name": "${i}",
  "description": "${description}",
  "homepage": "${homepage}",
  "private": ${private},
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
