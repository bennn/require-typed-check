#lang typed/racket/base
(define-namespace-anchor nsa)

(require require-typed-check)

(require/typed/check require-typed-check/test/opaque/typed
  (#:opaque Typed typed?))
(require/typed/check require-typed-check/test/opaque/untyped
  (#:opaque Untyped untyped?))

(module+ test
  (require typed/rackunit)

  ;; Can use both predicates
  (check-true (typed? 'x))
  (check-true (untyped? 'x))

  ;; Can use type from untyped module
  (define-type Foo Untyped)

  ;; Cannot use type from typed module
  (check-exn #rx"type name `Typed' is unbound"
    (lambda ()
      (compile-syntax
        #'(module t typed/racket/base
            (require require-typed-check)
            (require/typed/check require-typed-check/test/opaque/typed
              (#:opaque Typed typed?))
            (define-type Bar Typed)))))

)
