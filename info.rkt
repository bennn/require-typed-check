#lang info
(define collection "require-typed-check")
(define deps '("base" "typed-racket-lib"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define pkg-desc "require/typed without contracts")
(define version "0.1")
(define pkg-authors '(ben))
(define scribblings '(("scribblings/require-typed-check.scrbl" () ("scripting"))))
