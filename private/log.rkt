#lang racket/base

(provide
  require-typed-check-logger
  log-require-typed-check-debug
  log-require-typed-check-info
  log-require-typed-check-warning
  log-require-typed-check-error
  log-require-typed-check-fatal
  (struct-out require-typed-check-info)
  log-require-typed-check)

(define-logger require-typed-check)

(struct require-typed-check-info [src sexp] #:prefab)

(define (log-require-typed-check stx)
  ;; log information about a whole require/typed/check clause
  (define src (syntax->serializable-source stx))
  (define rtc-info (require-typed-check-info src (syntax->datum stx)))
  (log-require-typed-check-info "~s" rtc-info))

(define (syntax->serializable-source stx)
  (define src (syntax-source stx))
  (if (path? src)
    (path->string src)
    src))

