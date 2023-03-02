#lang typed/racket/base
(define-namespace-anchor nsa)

(require require-typed-check/unsafe)

(unsafe-require/typed/check require-typed-check/test/opaque/typed
  (#:opaque Typed typed?))
(unsafe-require/typed/check require-typed-check/test/opaque/untyped
  (#:opaque Untyped untyped?))

(module+ test
  (require typed/rackunit)

  ;; Can use both predicates
  (check-true (typed? 'x))
  (check-true (untyped? 'x))

  ;; Can use type from untyped module
  (define-type Foo Untyped)

  ;; Can use type from typed module, too
  ;;  though it goes through a contract
  (define-type Bar Typed)
)

