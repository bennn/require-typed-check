#lang typed/racket/base/deep

(require require-typed-check/deep)
(require/typed/check/deep require-typed-check/test/basic/untyped
  (f (-> Natural Natural (Vectorof Boolean) Any)))

(require/typed/check/deep require-typed-check/test/basic/typed
  (g (-> Natural Natural (Vectorof Boolean) Any)))

(module+ test
  (require typed/rackunit)

  (check-true (f 0 0 (vector #t)))
  (check-true (g 0 0 (vector #t)))

  (require/typed/check/deep racket/contract
    (has-contract? (-> Any Boolean)))

  (check-true (has-contract? f))
  (check-false (has-contract? g))
)
