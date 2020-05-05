#lang racket
(require threading
         "private/zfs.rkt")

(define next-nmdm
  (match (zfs:get-value "-rt" "filesystem" "com.freqlabs:libvirt-nmdm" "storage/bhyve")
    [`(ok . ,nmdms)
     (letrec ([used (~>> nmdms
                         (string-trim)
                         (string-split)
                         (map string->number)
                         (filter identity)
                         (sort _ <))]
              [next-avail (lambda (nats used)
                            (let ([n (stream-first nats)])
                              (match used
                                ['() n]
                                [`(,u . ,_) #:when (< n u) n]
                                [`(_ . ,rest-used)
                                 (next-avail (stream-rest nats) rest-used)])))])
       (next-avail (in-naturals) used))]
    ['err (error 'next-nmdm "could not find nmdm")]))
