#lang typed/racket/base/shallow

(: s (-> Integer Integer (Vectorof Boolean) Boolean))
(define (s x y z)
  (vector-ref z 0))

(provide s)

