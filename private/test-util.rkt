#lang typed/racket/base

(provide
  test-type-error
)

(require
  typed/rackunit
  (only-in racket/port open-output-nowhere))

;; =============================================================================

(define-syntax-rule (test-type-error stx ...)
  (parameterize ([current-error-port (open-output-nowhere)])
    (check-exn #rx"Type Checker"
      (lambda ()
        (compile-syntax stx)))
    ...))
