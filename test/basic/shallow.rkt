#lang typed/racket/base/shallow

(require require-typed-check/shallow)
(require/typed/check/shallow require-typed-check/test/basic/untyped
  (f (-> Natural Natural (Vectorof Boolean) Any)))

(require/typed/check/shallow require-typed-check/test/basic/typed
  (g (-> Natural Natural (Vectorof Boolean) Any)))

(require/typed/check/shallow require-typed-check/test/basic/shallow-lib
  (s (-> Natural Natural (Vectorof Boolean) Any)))

(require/typed/check/shallow require-typed-check/test/basic/optional-lib
  (o (-> Natural Natural (Vectorof Boolean) Any)))

(module+ test
  (require typed/rackunit)

  (check-true (f 0 0 (vector #t)))
  (check-true (g 0 0 (vector #t)))
  (check-true (s 0 0 (vector #t)))
  (check-true (o 0 0 (vector #t)))

  (require/typed/check/shallow racket/contract
    (has-contract? (-> Any Boolean)))

  (check-false (has-contract? f))
  (check-true (has-contract? g)) ;; ctc from deep
  (check-false (has-contract? s))
  (check-false (has-contract? o))
)
