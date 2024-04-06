#lang racket
(require racket/generator
         racket/sequence
         "private/vm-utils.rkt"
         "private/libvirt-domxml.rkt")

(define iso "TrueNAS/TrueNAS-12.0-INTERNAL-64.iso")

(vm "TrueNAS-12.0-INTERNAL-64")
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
    ,(disk (zvol "disk0" 1 'GB) "hda")
    ,@(sequence->list
       (in-generator
        (let* ([base (char->integer #\a)]
               [limit 26]
               [ident (lambda (i)
                        (let ([n (add1 (quotient i limit))]
                              [c (integer->char (+ base (modulo i limit)))])
                          (make-string n c)))])
          (let loop ([i 0])
            (when (< i 100)
              (let ([diskname (string-append "sd" (ident i))])
                (yield (disk (zvol diskname 256 'MB) diskname)))
              (loop (add1 i)))))))
    ,(cdrom (installer iso) "hdc")
    ,(virtio-bridge "bridge0")
    ,@(nmdm-console (auto-nmdm)))))
