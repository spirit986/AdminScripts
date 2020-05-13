#/bin/bash

# ReScan all SCSI/SATA Hosts
for SHOST in /sys/class/scsi_host/host*; do
    echo -n "Scanning ${SHOST##*/}..."
    echo "- - -" > ${SHOST}/scan
    echo Done
done
