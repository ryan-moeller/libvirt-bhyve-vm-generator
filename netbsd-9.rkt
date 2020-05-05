#lang racket
(require xml
         xml/xexpr
         "private/libvirt-domxml.rkt")

(define config
  `(domain
    ([type "bhyve"])
    (name "NetBSD-9")
    ,(memory 8 'GiB)
    ,wired
    ,(cpus 4)
    ,@(grub-bhyve
       (string-join
        `("--cons-dev=/dev/nmdm9A"
          "--device-map=/bhyve/NetBSD-9/device.map"
          "--directory=/bhyve/NetBSD-9"
          "--evga"
          "--memory=8192"
          "--root=host"
          "-S"
          "--verbose"
          "NetBSD-9")))
    (os
     (type ([arch "x86_64"]) "hvm")
     (boot ([dev "cdrom"])))
    (features (acpi) (apic))
    (devices
     ,(cdrom "/storage/osisos/NetBSD/NetBSD-9.0-amd64.iso" "hdc")
     ,(virtio-bridge "bridge0" (pci-addr #x0000 #x00 #x02 #x0))
     ,(scsi-ctl "ioctl/5/4"    (pci-addr #x0000 #x00 #x03 #x0))
     ,(ppt-dev "5/0/8"         (pci-addr #x0000 #x00 #x04 #x0))
     ,@(nmdm-console 9))))

(empty-tag-shorthand 'always)
((if (terminal-port? (current-output-port))
     display-xml/content
     write-xml/content)
 (xexpr->xml config))
