#lang typed/racket/base/optional

(: o (-> Integer Integer (Vectorof Boolean) Boolean))
(define (o x y z)
  (vector-ref z 0))

(provide o)
