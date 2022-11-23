#lang scribble/manual
@require[
  scribble/example
  (for-label
    typed/racket/base
    (only-in racket/contract any/c has-contract?)
    require-typed-check
    require-typed-check/logging)]

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

  (require/typed/check racket/math
    ((sqr square) (-> Integer Integer)))

  (require/typed racket/contract
    (has-contract? (-> Any Boolean)))

  (define (check-contract id)
    (printf "~a does~a have a contract~n"
      (object-name id)
      (if (has-contract? id) "" " NOT")))

  (check-contract square)
  (check-contract has-contract?))
(require 't)
]

@defmodule[require-typed-check/deep]

@defform[(require/typed/check/deep m rt-clause ...)]{}

@defmodule[require-typed-check/shallow]

@defform[(require/typed/check/shallow m rt-clause ...)]{}

@defmodule[require-typed-check/optional]

@defform[(require/typed/check/optional m rt-clause ...)]{}

@defmodule[require-typed-check/unsafe]

@defform[(unsafe-require/typed/check m rt-clause ...)]{}

@section{Type-Boundary Instrumentation}

To disable @racket[require/typed/check], set the environment variable
 @as-index{@litchar{DISABLE_REQUIRE_TYPED_CHECK}} to any kind of value.
This causes all @racket[require/typed/check] forms to expand to
 @racket[require/typed] forms.

@defmodule[require-typed-check/logging]{
  Expanding a @racket[require/typed/check] form logs an event to the
   @indexed-racket['require-typed-check] topic at the @racket['info] level.
}

@defthing[require-typed-check-logger logger?]{
  A logger for @racketmodname[require-typed-check].
}

Log events report the importing module and the syntax of the @racket[require/typed/check] form.
This data is package in an instance of a prefab struct:

@defstruct*[require-typed-check-info ([src string?] [sexp any/c]) #:prefab]{
  Contains the source and value of a @racket[require/typed/check] syntax object.
  The source @racket[src] comes from @racket[syntax-source]
   and the value @racket[sexp] comes from @racket[syntax->datum].
}

