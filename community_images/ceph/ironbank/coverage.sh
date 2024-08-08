#!/bin/sh

set -x
set -e

# cephadm utility check
cephadm version
cephadm -h

cephadm list-networks || echo 0
cephadm install || echo 0

# ceph version
ceph -v

# authorization and key generation for mon
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
# importing keys
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring

chown ceph:ceph /tmp/ceph.mon.keyring
# testing monmaptool and new mon
monmaptool --create --add ceph-mon 127.0.0.1 --fsid a7f64266-0894-4f1e-a635-d0aeaca0e993 /tmp/monmap

chown ceph:ceph /tmp/monmap

mkdir /var/lib/ceph/mon/ceph-ceph-mon

ceph-mon --mkfs -i ceph-mon --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

ceph-mon -i ceph-mon --public-addr 127.0.0.1:6789
# initializing mon
ceph auth add mon. -i /tmp/ceph.mon.keyring

ceph status

# testing coverage sc
ceph-coverage /tmp/coverage.sh ceph status
# mgr version
ceph-mgr -v

ceph-osd -v
# podman version
podman -v
# testing all mgr commands
ceph mgr module ls

mkdir -p /var/lib/ceph/mgr/ceph-mgr-new

ceph auth get-or-create mgr.mgr-new mon 'allow profile mgr' osd 'allow *' mds 'allow *' -o /var/lib/ceph/mgr/ceph-mgr-new/keyring
# intializing
ceph-mgr -i mgr-new
# status check
ceph -s
# enabling module
ceph mgr module enable prometheus --force

ceph mgr services

ceph config ls

# testing mds
mkdir -p /var/lib/ceph/mds/mds-a

ceph-authtool --create-keyring /var/lib/ceph/mds/mds-a/keyring --gen-key -n mds.a

ceph auth add mds.a osd "allow rwx" mds "allow *" mon "allow profile mds" -i /var/lib/ceph/mds/mds-a/keyring
mkdir -p /var/lib/ceph/mds/ceph-admin

cp /etc/ceph/ceph.client.admin.keyring /var/lib/ceph/mds/ceph-admin/keyring
# ceph-mds --cluster mds -i a -m 127.0.0.1:6801

nohup ceph-mds --cluster mds -i a -m 127.0.0.1:6801 &

ceph -s
# osd stat check
ceph osd tree

# Enable tracing globally
ceph config set global jaeger_tracing_enable true

# api module
ceph mgr module enable cli_api --force


# ceph volume 
ceph-volume lvm create --data / || echo 0

# osd with all utilities
UUID=$(uuidgen)

OSD_SECRET=$(ceph-authtool --gen-print-key)

ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | \
   ceph osd new "$UUID" -i - \
   -n client.bootstrap-osd -k /var/lib/ceph/bootstrap-osd/ceph.keyring)

# mkfs.xfs /dev/sda1
mount /dev/sda1 /var/lib/ceph/osd/ceph-"$ID"s

ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-"$ID"/keyring \
     --name osd."$ID" --add-key "$OSD_SECRET"

cp /var/lib/ceph/osd/ceph-"$ID"/keyring /etc/ceph/ceph.client.bootstrap-osd.keyring || echo 0

ceph-osd -i "$ID" --mkfs --osd-uuid "$UUID"

ceph-osd -i "$ID" &
sleep 5

ceph -s
# testing orch
ceph mgr module enable test_orchestrator --force
ceph orch set backend test_orchestrator || echo 0
ceph orch status || echo 0
# Apply the spec for hardware monitoring
ceph orch apply -i host.yml || echo 0

# rbd
ceph osd pool create rbd 128 || echo 0
ceph osd pool ls

# ceph filesystem
ceph fs volume create cephfs || echo 0
ceph status
