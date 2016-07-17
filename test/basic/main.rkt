#lang typed/racket/base

(require require-typed-check)
(require/typed/check require-typed-check/test/basic/untyped
  (f (-> Natural Natural (Vectorof Any) Any)))

(require/typed/check require-typed-check/test/basic/typed
  (g (-> Natural Natural (Vectorof Any) Any)))

(module+ test
  (require typed/rackunit)

  (check-true (f 0 0 (vector #t)))
  (check-true (g 0 0 (vector #t)))

  (require/typed/check racket/contract
    (has-contract? (-> Any Boolean)))

  (check-true (has-contract? f))
  (check-false (has-contract? g))
)
