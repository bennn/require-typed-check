#lang typed/racket/base

(require require-typed-check/unsafe)
(unsafe-require/typed/check require-typed-check/test/basic/untyped
  (f (-> Natural Natural (Vectorof Boolean) Any)))

(unsafe-require/typed/check require-typed-check/test/basic/typed
  (g (-> Natural Natural (Vectorof Boolean) Any)))

(module+ test
  (require typed/rackunit)

  (check-true (f 0 0 (vector #t)))
  (check-true (g 0 0 (vector #t)))

  (unsafe-require/typed/check racket/contract
    (has-contract? (-> Any Boolean)))

  (check-false (has-contract? f))
  (check-false (has-contract? g))
)
