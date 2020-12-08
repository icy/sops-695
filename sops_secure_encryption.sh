#!/usr/bin/env bash

# Purpose : Securely encrypt file with sops 3.6.0,
#           due to a bug https://github.com/mozilla/sops/issues/695
#           we encrypt, decrypt if that's fine, and replace the original file.
# Warning : This method will replace the original file.
# Author  : Ky-Anh Huynh
# License : MIT

set -u

# FIXME: This should not be the top root directory
# FIXME: where the .sops.yaml is there :D
: "${D_ROOT}"
: "${SOPS:=sops}"

logs() {
  1>&2 echo ":: $*"
}

encrypt_all() {
  # FIXME: This may not work on MacOs, need some testing
  while read -r file; do
    logs "Encrypting $file"
    _tmp_file="$file.__tmp_.${file##*.}"
    rm -f "$_tmp_file" || return 1
    2>&1 "${SOPS}" -e --output "$_tmp_file" "$file" \
    | awk 'BEGIN{ret=1}
      {
        if ($0 ~ /The file you have provided contains a top-level entry called/) {
          ret=0
        }
        else {
          if (ret) print
        }
      }
      END {exit(ret)}
      '
    rets=( "${PIPESTATUS[@]}" )

    # Found any sops error during encryptiong
    if [[ "${rets[0]}" -ge 1 && "${rets[1]}" -ge 1 ]]; then
      rm -f "$_tmp_file"
      return 1
    fi

    # File already encrypted, it's asked to be encrypted another time
    if [[ ! -f "$_tmp_file" ]]; then
      continue
    fi

    # File encrypted for the first type
    if "${SOPS}" -d "$_tmp_file" >/dev/null; then
      mv -f "$_tmp_file" "$file"
      continue
    fi

    # This, should never happen
    logs "Errors: ${rets[*]}. You may have caught a sops bug. See also https://github.com/mozilla/sops/issues/695."
    return 1
  done < <(find "$D_ROOT/" -type f -iname "*.yaml")
}

"${@:-:}"
