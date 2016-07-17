#lang typed/racket/base

(module foo typed/racket
  (provide foo)
  (define foo : (Vectorof Symbol) (vector 'foo 'bar 'baz)))

(module bar typed/racket
  (require require-typed-check)
  (require/typed/check (submod ".." foo)
    (foo (Vectorof Symbol)))
  (require/typed racket/contract
    (has-contract? (-> Any Boolean)))
  (define bar (has-contract? foo))
  (provide bar))

(require require-typed-check)
(require/typed/check 'bar
  (bar Boolean))

(module+ test
  (require typed/rackunit)
  (check-true bar))
