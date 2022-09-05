#!/usr/bin/bash -e

(( EUID == 0 )) && { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# EXT scripts.
# -------------------------------------------------------------------------------------------------------------------- #

git="$( command -v git )"
date="$( command -v date )"
tr="$( command -v tr )"

_timestamp() {
  ${date} -u '+%Y-%m-%d %T'
}

_build_version() {
  ${date} -u '+%Y%m%d%H%M%S'
}

pushd() {
  builtin pushd "$@" > /dev/null 2>&1 || exit 1
}

popd() {
  builtin popd > /dev/null 2>&1 || exit 1
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push() {
  name=$( basename "${PWD}" )
  ts="$( _timestamp )"
  commit="$*"

  echo ""
  echo "--- OPEN: '${name}'"
  ${git} add . \
    && ${git} commit -a -m "${ts}" -m "${commit}" \
    && ${git} push
  echo "--- DONE: '${name}'"
  echo ""
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push all.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push.all() {
  for i in *; do
    if [[ -d "${i}/.git" ]]; then
      pushd "${i}" \
        && run.git.push "$@" \
        && popd || exit 1
    fi
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push tag.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push.tag() {
  tags="$( ${git} tag --list )"
  changes="$( ${git} status --porcelain )"

  [[ -z "${changes}" ]] && count="0" || count="1"

  if [[ -z "${1}" ]]; then
    if [[ -z "${tags}" ]]; then
      version="1.0.0"
    else
      tag=( "$( ${git} describe --abbrev=0 --tags | ${tr} '.' ' ' )" )
      major=${tag[1]}
      minor=${tag[2]}
      patch=${tag[3]}
      version="${major}.${minor}.(( ${patch} + ${count} ))"
    fi
  else
    version="${1}"
  fi

  run.git.push "$@"                                       \
    && ${git} tag -a "${version}" -m "Version ${version}" \
    && ${git} push origin "${version}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push page.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push.page() {
  [[ -z "${1}" ]] && branch="page-stable" || branch="${1}"
  run.git.push "$@" \
    && ${git} checkout main \
    && ${git} merge "${branch}" \
    && ${git} push \
    && ${git} checkout "${branch}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push CDN.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push.cdn() {
  [[ -z "${1}" ]] && branch="cdn-stable" || branch="${1}"
  run.git.push "$@" \
    && ${git} checkout main \
    && ${git} merge "${branch}" \
    && ${git} push \
    && ${git} checkout "${branch}"
}
