#lang typed/racket/base

;; https://github.com/bennn/require-typed-check/issues/1

(module+ test
  (require require-typed-check/private/test-util)

  (test-type-error
    #'(module test racket/base
        (module a typed/racket
          (provide f)
          (: f : (-> Positive-Fixnum Nonnegative-Fixnum))
          (define (f x) (- x 1)))
        (module b typed/racket
          (require require-typed-check)
          (require/typed/check (submod ".." a)
            [f (-> String String)])
          (f 5050))
        (require 'b)))

)
