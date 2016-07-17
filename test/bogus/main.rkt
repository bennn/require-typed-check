#lang typed/racket/base

(require require-typed-check)

(require/typed/check require-typed-check/test/bogus/typed
  (f Void))

(f 1 2)
