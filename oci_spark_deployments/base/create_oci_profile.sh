#!/bin/bash -ex
#echo "oci_profile_user = $oci_profile_user"
#echo "oci_profile_fingerprint = $oci_profile_fingerprint"
#echo "oci_profile_key_file = $oci_profile_key_file"
#echo "oci_profile_tenancy = $oci_profile_tenancy"
#echo "oci_profile_region = $oci_profile_region"
#echo "oci_profile_key = $oci_profile_key"
#
> ociconfig
{
    echo "[DEFAULT]"
    echo "user=${oci_profile_user}"
    echo "fingerprint=${oci_profile_fingerprint}"
    echo "key_file=${oci_profile_key_file}"
    echo "tenancy=${oci_profile_tenancy}"
    echo "region=${oci_profile_region}"
} >>  ociconfig

echo $oci_profile_key | base64 --decode > ocikey

#cat ociconfig
#cat ocikey
#echo $oci_profile_key_file

sudo mkdir -p ~/.oci 
ls -altr ~/.oci 
sudo mv ociconfig ~/.oci/config
sudo mv ocikey ~/.oci/oci_api_key

