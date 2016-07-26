#lang typed/racket/base

;; Cannot give bogus type annotations
;; https://github.com/bennn/require-typed-check/issues/1

(module+ test
  (require
    require-typed-check/private/test-util)

  (test-type-error
    #'(module t typed/racket/base
        (require require-typed-check)
        (require/typed/check require-typed-check/test/bogus/typed
          (f Void))
        (f 1 2)))
)
