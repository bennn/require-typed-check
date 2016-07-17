#lang typed/racket/base

(: g (-> Integer Integer (Vectorof Boolean) Boolean))
(define (g x y z)
  (vector-ref z 0))

(provide g)
