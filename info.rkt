#lang info
(define collection "require-typed-check")
(define deps '("base" "typed-racket-lib" "typed-racket-more"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib" "typed-racket-doc"))
(define pkg-desc "require/typed without contracts")
(define version "0.3")
(define pkg-authors '(ben))
(define scribblings '(("scribblings/require-typed-check.scrbl" () ("Performance"))))
