#lang typed/racket/base

;; https://github.com/bennn/require-typed-check/issues/3

(module+ test
  (require require-typed-check typed/rackunit)

  (require/typed/check math
    ((divides? div) (-> Integer Integer Boolean)))

  (require/typed racket/contract
    (has-contract? (-> Any Boolean)))

  (check-false (has-contract? div))

)

