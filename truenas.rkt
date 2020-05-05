#lang racket
(require "private/vm-utils.rkt"
         "private/libvirt-domxml.rkt")

(define iso "FreeNAS/TrueNAS-12.0-NOT-DNODES-ULOOKN4.iso")

(vm "TrueNAS-12.0-NOT-DNODES-ULOOKN4")
(generate-domxml
 `(domain
    ([type "bhyve"])
    (name ,(vm))
    ,(memory 4 'GiB)
    ,(cpus 2)
    (os
     (type ([arch "x86_64"]) "hvm")
     ,(loader uefi)
     (boot ([dev "cdrom"])))
    (features (acpi) (apic))
    (devices
     ,(disk (zvol "disk0" 20 'GB) "hda")
     ,(disk (zvol "disk1" 20 'GB) "hdb")
     ,(cdrom (installer iso) "hdc")
     ,(virtio-bridge "bridge0")
     ,@(nmdm-console (auto-nmdm)))))
