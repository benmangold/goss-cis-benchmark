#!/bin/bash
#
# 6.1.13 Audit SUID executables (Manual)
#
# Description:
# The owner of a file can set the file's permissions to run with the owner's or
# group's permissions, even if the user running the program is not the owner or
# a member of the group.
# The most common reason for a SUID program is to enable users to perform
# functions (such as changing their password) that require root privileges.
#
# Rationale:
# There are valid reasons for SUID programs, but it is important to identify
# and review such programs to ensure they are legitimate.

set -o errexit
set -o nounset

declare gcp_binaries="29"
declare azure_binaries="13"
declare url_google="http://metadata/computeMetadata/v1/instance/hostname"
status=0

count_SUID=$(df --local -P | awk "{'if (NR!=1) print $6'}" | xargs -I '{}' find '{}' -xdev -type f -perm -4000 | wc -l)

curl -v -H Metadata-Flavor:Google $url_google -f > /dev/null 2>&1 || status=1

if [[ "${status}x" == "0x" ]]; then
  if [[ $count_SUID == "$gcp_binaries" ]]; then
    exit 1
  else
    exit 0
  fi
fi

if [[ $count_SUID == "$azure_binaries" ]]; then
  exit 1
else
  exit 0
fi
