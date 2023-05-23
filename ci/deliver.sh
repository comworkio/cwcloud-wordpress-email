#!/usr/bin/env bash

declare -a APIS

APIS=("cloud-api.comwork.io" "api.cwcloud.tn")

for api in "${APIS[@]}"; do
    ext="$(echo $api|awk -F '.' '{print $NF}')"
    dir="cwcloud-email-plugin-${ext}"
    rm -rf "${dir}.zip"
    mkdir -p "${dir}"
    sed "s/CWCLOUD_ENDPOINT_URL/${api}/g" "cwcloud-email-plugin.php.tpl" > "${dir}/cwcloud-email-plugin.php"
    zip "${dir}.zip" "${dir}/cwcloud-email-plugin.php"
    rm -rf "${dir}"
done
