#lang typed/racket/base

;; https://github.com/bennn/require-typed-check/issues/3

(module+ test
  (require require-typed-check typed/rackunit)

  (require/typed/check racket/math
    ((sqr square) (-> Integer Integer)))

  (require/typed racket/contract
    (has-contract? (-> Any Boolean)))

  (check-false (has-contract? square))

)

