#lang racket/base
(require racket/format
         racket/match
         racket/string
         xml
         xml/xexpr)
(provide bhyveload
         grub-bhyve
         memory
         nmdm-console
         pci-addr
         virtio-bridge
         cdrom
         disk
         scsi-ctl
         ppt-dev
         wired
         cpus
         loader
         uefi
         uefi-csm
         uefi-devel)

(define (~x v)
  (format "0x~x" v))

(define (bhyveload args)
  `((bootloader "bhyveload")
    (bootloader_args ,args)))

(define (grub-bhyve [args #f])
  `((bootloader "grub-bhyve")
    ,@(if args
          `((bootloader_args ,args))
          '())))

(define (memory size unit)
  `(memory ([unit ,(~s unit)]) ,(~r size)))

(define (nmdm-console nmdm)
  (let ([source `(source ([master ,(format "/dev/nmdm~aA" nmdm)]
                          [slave ,(format "/dev/nmdm~aB" nmdm)]))])
    `((serial ([type "nmdm"])
              ,source
              (target ([port "0"])))
      (console ([type "nmdm"])
               ,source
               (target ([type "serial"] [port "0"]))))))

(define (pci-addr domain bus slot function)
  `(address ([type "pci"] [domain ,(~x domain)]
             [bus ,(~x bus)] [slot ,(~x slot)] [function ,(~x function)])))

(define (virtio-bridge bridge)
  `(interface ([type "bridge"])
     (source ([bridge ,bridge]))
     (model ([type "virtio"]))))

(define (cdrom file dev)
  `(disk ([type "file"] [device "cdrom"])
         (driver ([name "file"] [type "raw"]))
         (source ([file ,file]))
         (target ([dev ,dev] [bus "sata"]))
         (readonly)))

(define (disk file dev)
  `(disk ([type "file"] [device "disk"])
         (driver ([name "file"] [type "raw"]))
         (source ([file ,file]))
         (target ([dev ,dev] [bus "sata"]))))

(define (scsi-ctl ctldev addr)
  (match-let ([`(,proto ,pp ,vp) (string-split ctldev "/")])
    `(hostdev ([mode "subsystem"] [type "scsi_ctl"] [model "virtio"])
              (source ([protocol ,proto]
                       [pp ,(~r (string->number pp))]
                       [vp ,(~r (string->number vp))]))
              ,addr)))

(define (ppt-dev pptdev addr)
  (match-let ([`(,bus ,slot ,func) (string-split pptdev "/")])
    `(hostdev ([mode "subsystem"] [type "pci"])
              (driver ([name "vmm"]))
              (source (address ([domain "0x0000"]
                                [bus ,(~x (string->number bus))]
                                [slot ,(~x (string->number slot))]
                                [function ,(~x (string->number func))])))
              ,addr)))

(define wired
  '(memoryBacking (locked)))

(define (cpus ncpu)
  `(vcpu ,(~a ncpu)))

(define (loader path)
  `(loader ([readonly "yes"] [type "pflash"]) ,path))

(define (uefi-firmware-path name)
  (format "/usr/local/share/uefi-firmware/~a.fd" name))

(define uefi (uefi-firmware-path "BHYVE_UEFI"))
(define uefi-csm (uefi-firmware-path "BHYVE_UEFI_CSM"))
(define uefi-devel (uefi-firmware-path "BHYVE_UEFI_CODE-devel"))
