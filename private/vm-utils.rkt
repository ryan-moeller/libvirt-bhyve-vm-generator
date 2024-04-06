#lang racket
(require threading
         xml
         xml/xexpr
         "zfs.rkt")
(provide generate-domxml installer zvol auto-nmdm
         vm bhyve-dataset installer-dataset)

(define vm (make-parameter #f))

(define bhyve-dataset (make-parameter "storage/bhyve"))
(define installer-dataset (make-parameter "storage/osisos"))
(define (vm-dataset) (format "~a/~a" (bhyve-dataset) (vm)))

(define (installer relative-path)
  (define dataset (installer-dataset))
  (format "~a/~a"
          (match (zfs:get-value "mountpoint" dataset)
            [`(ok . ,mountpoint) (string-trim mountpoint)]
            ['err (error 'iso "failed to get mountpoint for ~a" dataset)])
          relative-path))

(define nmdm-userprop "com.freqlabs:libvirt-nmdm")

(define next-nmdm
  (match (zfs:get-value "-rt" "filesystem" nmdm-userprop (bhyve-dataset))
    [`(ok . ,nmdms)
     (letrec ([used (~>> nmdms
                         (string-trim)
                         (string-split)
                         (map string->number)
                         (filter identity)
                         (sort _ <))]
              [next-avail (λ (nats used)
                            (let ([n (stream-first nats)])
                              (match used
                                ['() n]
                                [`(,u . ,_) #:when (< n u) n]
                                [`(,_ . ,rest-used)
                                 (next-avail (stream-rest nats) rest-used)])))])
       (next-avail (in-naturals) used))]
    ['err (error 'next-nmdm "could not find nmdm")]))

(define (auto-nmdm)
  (define vm-ds (vm-dataset))
  (match (zfs:get-value nmdm-userprop vm-ds)
    [`(ok . ,nmdm) (string->number (string-trim nmdm))]
    ['err (error 'auto-nmdm "failed to get ~a for ~a" nmdm-userprop vm-ds)]))

(define (zvol name size units)
  (define vm-ds (vm-dataset))
  (define zvol-ds (format "~a/~a" vm-ds name))
  (define zvol-dev (format "/dev/zvol/~a" zvol-ds))
  (define zvol-size (format "~a~a" size (string-ref (symbol->string units) 0)))
  (define nmdm-prop (format "~a=~a" nmdm-userprop next-nmdm))
  (if (or (and (eq? 'err (zfs:list vm-ds))
               (displayln "creating dataset" (current-error-port))
               (eq? 'err (zfs:create "-o" nmdm-prop vm-ds)))
          (and (eq? 'err (zfs:get-value nmdm-userprop vm-ds))
               (eq? 'err (zfs:set nmdm-prop vm-ds)))
          (and (eq? 'err (zfs:list zvol-ds))
               (displayln "creating zvol" (current-error-port))
               (eq? 'err (zfs:create "-V" zvol-size zvol-ds))))
      (error 'zvol "failed to create zvol ~a with size ~a" zvol-ds zvol-size)
      zvol-dev))

(define (generate-domxml config)
  (if (false? (vm))
      (error 'generate-domxml "must set vm parameter")
      (begin
        (empty-tag-shorthand 'always)
        ((if (terminal-port? (current-output-port))
             display-xml/content
             write-xml/content)
         (xexpr->xml config)))))
