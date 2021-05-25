#!/bin/bash

create_user () {
    radosgw-admin user create --uid=$1 --display-name=$1 --email=$1@127.0.0.1 | jq .user_id
    export RGW_ACCESS_KEY_ID=$(radosgw-admin user info --uid $1 | jq .keys[0].access_key | tr -d '"')
    export RGW_SECRET_ACCESS_KEY=$(radosgw-admin user info --uid $1 | jq .keys[0].secret_key | tr -d '"')
    echo "access_key ${RGW_ACCESS_KEY_ID}"
    echo "secret_key ${RGW_SECRET_ACCESS_KEY}"
    echo "radosgw-roken for uid $1 is:"
    radosgw-token --encode --ttype=ldap

    cat <<EOF >/tools/$1.s3cfg
[default]
access_key = ${RGW_ACCESS_KEY_ID}
secret_key = ${RGW_SECRET_ACCESS_KEY}

host_base = 127.0.0.1:8000
host_bucket = 127.0.0.1:8000

use_https = False
EOF

}

# create some local Ceph users
create_user deliver
create_user consume
create_user monitor
create_user admin

# create a bucket from delivery of random data
s3cmd --access_key=sandbox --secret_key=s3cr3t mb s3://delivery-random-data
radosgw-admin bucket chown --bucket=/delivery-random-data --uid=deliver

# generate and put random data
head -c 1k </dev/urandom > random.data
s3cmd --config=/tools/deliver.s3cfg put random.data s3://delivery-random-data
s3cmd --config=/tools/deliver.s3cfg put random.data s3://delivery-random-data/1/random.data
s3cmd --config=/tools/deliver.s3cfg put random.data s3://delivery-random-data/1/2/random.data

# also put some random data into the public-data bucket
s3cmd --access_key=sandbox --secret_key=s3cr3t mb s3://public-data
s3cmd --access_key=sandbox --secret_key=s3cr3t setpolicy /tools/public-policy.json s3://public-data
s3cmd --access_key=sandbox --secret_key=s3cr3t put random.data s3://public-data
