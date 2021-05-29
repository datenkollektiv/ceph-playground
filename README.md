# Ceph Playground

The main idea of this playground is to provide an easy to use Ceph environment to simply play around with the technology.

Please check the companion [blog post - Kick-start Development with Ceph](https://devops.datenkollektiv.de/kick-start-development-with-ceph.html) for more details.

TL;DR

Spin up the container with `docker compose -p ceph -d up ceph`.

Use [Ceph Nano](http://localhost:5000/objects.html?bucket=sandbox) to access the bucket `sandbox`

## Examples

Use the embedded `s3cmd` inside the ceph container `docker exec -it ceph-playground_ceph_1 /bin/bash`

```bash
s3cmd --access_key=sandbox --secret_key=s3cr3t ls s3://sandbox
```

Create test data

```bash
docker exec -it ceph-playground_ceph_1 /tools/prepare-test-environment.sh
```

add grab the prepared `s3cmd` configurations like follows from `docker/ceph/tools/`:

```bash
s3cmd --config sandbox.s3cfg ls s3://sandbox 
s3cmd --config docker/ceph/tools/admin.s3cfg ls s3://delivery-sample-data 
```
