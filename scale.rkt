#lang racket
(require "private/vm-utils.rkt"
         "private/libvirt-domxml.rkt")

(define iso "TrueNAS/TrueNAS-SCALE-22.12-MASTER-20220712-132906.iso")

(vm "TrueNAS-SCALE-22.12-MASTER-20220712-132906")
(generate-domxml
 `(domain
   ([type "bhyve"])
   (name ,(vm))
   ,(memory 8 'GiB)
   ,(cpus 2)
   (os
    (type ([arch "x86_64"]) "hvm")
    ,(loader uefi)
    (boot ([dev "cdrom"])))
   (features (acpi) (apic))
   (devices
    ,(virtio-disk (zvol "disk0" 20 'GB) "hda")
    ,(virtio-disk (zvol "disk1" 40 'GB) "hdb")
    ,(cdrom (installer iso) "hdc")
    ,(virtio-bridge "bridge0")
    ,@(nmdm-console (auto-nmdm)))))
