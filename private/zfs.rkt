#lang racket/base
(require racket/system
         racket/function)
(provide
 (prefix-out zfs:
             (combine-out
              (rename-out [zlist list])
              create
              clone
              destroy
              get
              get-value
              set
              inherit
              snapshot)))

(define (zfs . args)
  (define stdout (open-output-string))
  (if (parameterize ([current-output-port stdout])
        (apply system* "/sbin/zfs" args))
      `(ok . ,(get-output-string stdout))
      'err))

(define zlist (curry zfs "list"))
(define create (curry zfs "create"))
(define clone (curry zfs "clone"))
(define destroy (curry zfs "destroy"))
(define get (curry zfs "get"))
(define get-value (curry zfs "get" "-Hpo" "value"))
(define set (curry zfs "set"))
(define inherit (curry zfs "inherit"))
(define snapshot (curry zfs "snapshot"))
