#lang racket
(require "private/vm-utils.rkt"
         "private/libvirt-domxml.rkt")

(define iso "FreeBSD/FreeBSD-13.1-RELEASE-amd64-bootonly.iso")

(vm "FreeBSD-13.1-RELEASE")
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
    ,(cdrom (installer iso) "hdc")
    ,(virtio-bridge "bridge0")
    ,@(nmdm-console (auto-nmdm)))))
