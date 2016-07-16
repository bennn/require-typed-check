#lang typed/racket/base

;; Very small test: just require something & use it.
;; Also provide an export for the `test/cache-stress.rkt`

(require require-typed-check)
(require/typed/check racket/base
  (random (-> Integer Integer)))

(void (random 3))

(define v : (Vectorof Void) (vector))
(provide v)
