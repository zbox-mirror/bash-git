#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

curl=$( which curl )
sleep="2"

OPTIND=1

while getopts "t:o:n:h" opt; do
  case ${opt} in
    t)
      token="${OPTARG}"
      ;;
    o)
      org="${OPTARG}"
      ;;
    n)
      name="${OPTARG}"; IFS=';' read -ra name <<< "${name}"
      ;;
    h|*)
      echo "-t '[token]' -o '[org]' -n '[name_1;name_2;name_3]'"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#name[@]} )) && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

for i in "${name[@]}"; do
  echo "" && echo "--- Open: ${i}"

  ${curl}                                       \
  -X DELETE                                     \
  -H "Authorization: token ${token}"            \
  -H "Accept: application/vnd.github.v3+json"   \
  "https://api.github.com/repos/${org}/${i}"

  echo "" && echo "--- Done: ${i}" && echo ""

  sleep ${sleep}
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0
