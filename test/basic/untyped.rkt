#lang racket/base

;; Module for `test/typed.rkt` to require

(provide f)

(define (f x y z)
  (vector-ref z (+ x y)))
