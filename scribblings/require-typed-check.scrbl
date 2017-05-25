#lang scribble/manual
@require[
  scribble/example
  (for-label
    typed/racket/base
    (only-in racket/contract has-contract?)
    math
    require-typed-check)]

@title[#:tag "top"]{@tt{require-typed-check}}
@author[@hyperlink["https://github.com/bennn"]{Ben Greenman}]

@defmodule[require-typed-check]

@defform[(require/typed/check m rt-clause ...)]{
  Like @racket[require/typed], but expands to a @racket[(require (only-in m ...))]
   when @racket[m] is a Typed Racket module.

  If you cannot know ahead of time whether @racket[m] is typed or untyped
   but want to avoid Typed-Racket-generated contracts if @racket[m] happens to
   be typed, this macro is worth using.
  Otherwise, just use @racket[require] or @racket[require/typed].

  Known limitations:
  @itemlist[
    @item{
      All submodules of the current module are assumed untyped.
      The current implementation would need to compile the module's submodules
       to be sure; it breaks the circular dependency by assuming the worst.
    }
    @item{
      Any @racket[#:opaque] imports are required via @racket[require/typed].
      (Previously, they weren't imported at all --- now they're imported under contract.)
    }
  ]
}

@examples[#:eval (make-base-eval)
(module t typed/racket
  (require require-typed-check)
  (require/typed/check math
    (divides? (-> Integer Integer Boolean)))
  (require/typed/check racket/contract
    (has-contract? (-> Any Boolean)))

  (define (check-contract id)
    (printf "~a does~a have a contract~n"
      (object-name id)
      (if (has-contract? id) "" " not")))

  (check-contract divides?)
  (check-contract has-contract?))
(require 't)
]
