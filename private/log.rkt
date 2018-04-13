#lang racket/base

(provide
  require-typed-check-logger
  log-require-typed-check-debug
  log-require-typed-check-info
  log-require-typed-check-warning
  log-require-typed-check-error
  log-require-typed-check-fatal

  (struct-out require-typed-check-info))

(define-logger require-typed-check)

(struct require-typed-check-info [src sexp] #:prefab)
