#lang typed/racket

(provide f)

(: f (-> Integer Integer Integer))
(define (f n1 n2)
  (+ n1 n2))
