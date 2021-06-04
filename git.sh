#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Git scripts.
# -------------------------------------------------------------------------------------------------------------------- #

ext.git.timestamp() {
  timestamp=$( date -u '+%Y-%m-%d %T' )
  echo "${timestamp}"
}

ext.git.build.version() {
  version=$( date -u '+%Y%m%d%H%M%S' )
  echo "${version}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push() {
  name=$( basename "${PWD}" )
  timestamp=$( ext.git.timestamp )
  commit="$*"

  echo ""
  echo "--- Pushing ${name}"
  git add . && git commit -a -m "${timestamp}" -m "${commit}" && git push
  echo "--- Finished ${name}"
  echo ""
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push all.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push.all() {
  for i in *; do
    [[ -e "${i}" ]] || break
    if [[ -d "${i}/.git" ]]; then
      cd "${i}" && run.git.push "$@" && cd ..
    fi
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push version.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push.tag() {
  tags=$( git tag --list )
  changes=$( git status --porcelain )

  if [[ -z "${changes}" ]]; then
    count="0"
  else
    count="1"
  fi

  if [[ -z "${1}" ]]; then
    if [[ -z "${tags}" ]]; then
      version="1.0.0"
    else
      tag=( "$( git describe --abbrev=0 --tags | tr '.' ' ' )" )
      major=${tag[1]}
      minor=${tag[2]}
      patch=${tag[3]}
      version="${major}.${minor}.(( ${patch} + ${count} ))"
    fi
  else
    version="${1}"
  fi

  run.git.push "$@" && git tag -a "${version}" -m "Version ${version}" && git push origin "${version}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push page.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push.page() {
  if [[ -z "${1}" ]]; then
    branch="page-stable"
  else
    branch="${1}"
  fi

  run.git.push "$@" && git checkout master && git merge "${branch}" && git push && git checkout "${branch}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# Git push CDN.
# -------------------------------------------------------------------------------------------------------------------- #

run.git.push.cdn() {
  if [[ -z "${1}" ]]; then
    branch="cdn-stable"
  else
    branch="${1}"
  fi

  run.git.push "$@" && git checkout master && git merge "${branch}" && git push && git checkout "${branch}"
}
