#lang racket
(require xml
         xml/xexpr
         "private/libvirt-domxml.rkt")

(define config
  `(domain
    ([type "bhyve"])
    (name "FreeBSD-11.3")
    ,(memory 4 'GiB)
    ,(cpus 2)
    (os
     (type ([arch "x86_64"]) "hvm")
     (boot ([dev "cdrom"])))
    (features (acpi) (apic))
    (devices
     ,(cdrom "/storage/osisos/FreeBSD/FreeBSD-11.3-STABLE-amd64-20200227-r358321-disc1.iso" "hdc")
     ,(virtio-bridge "bridge0" (pci-addr #x0000 #x00 #x02 #x0))
     ,(scsi-ctl "ioctl/5/5"    (pci-addr #x0000 #x00 #x03 #x0))
     ,@(nmdm-console 10))))

(empty-tag-shorthand 'always)
((if (terminal-port? (current-output-port))
     display-xml/content
     write-xml/content)
 (xexpr->xml config))
