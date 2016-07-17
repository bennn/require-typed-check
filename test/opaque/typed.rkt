#lang typed/racket/base

(define (typed? (x : Any)) : Boolean
  #t)

(provide typed?)
