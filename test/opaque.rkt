#lang typed/racket/base

(require require-typed-check)

(module foo typed/racket/base
  (define (foo? (x : Any)) : Boolean
    #t)
  (provide foo?))

(module+ test
  (require/typed/check (submod ".." foo)
    (#:opaque Foo foo?))

  (void (foo? 'x)))
