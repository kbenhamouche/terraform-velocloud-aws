#!/bin/bash
if [ -z "$1" ] ; then
    echo "Please pass the vendor name"
    exit 1
fi

IMAGE_FILTER="${1}"

declare -a REGIONS=($(aws ec2 describe-regions --query "Regions[].{Name:RegionName}" --output text))

for r in ${REGIONS[@]} ; do
    ami=$(aws ec2 describe-images --region ${r} --owners aws-marketplace --filters "Name=name,Values=*${IMAGE_FILTER}*" 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')
    printf "${r} = \"${ami}\"\n"
done
