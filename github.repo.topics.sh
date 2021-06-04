#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

curl=$( which curl )
sleep="2"

OPTIND=1

while getopts "t:o:n:p:h" opt; do
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
    p)
      topic="${OPTARG}"; IFS=';' read -ra topic <<< "${topic}"
      ;;
    h|*)
      echo "-t '[token]' -o '[owner]' -n '[name]' -d '[description]' -x '[homepage]' -r (private) -i (issues) -p (projects) -w (wiki)"
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

  ${curl}                                                 \
  -X PUT                                                  \
  -H "Authorization: token ${token}"                      \
  -H "Accept: application/vnd.github.mercy-preview+json"  \
  "https://api.github.com/repos/${owner}/${i}/topics"     \
  -d @- << EOF
{
  "names": ["${topic[@]@Q}"]
}
EOF

  echo "" && echo "--- Done: ${i}" && echo ""

  sleep ${sleep}
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0
