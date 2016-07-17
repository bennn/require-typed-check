#lang scribble/manual

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
      Type annotations are @bold{completely ignored} when importing from a typed
       module.
      The annotations can be wrong; they just get erased.
    }
    @item{
      All submodules of the current module are assumed untyped.
      The current implementation would need to compile the module's submodules
       to be sure; it breaks the circular dependency by assuming the worst.
    }
    @item{
      Does not generate type definitions from @racket[#:opaque] imports
       (but does require the predicate).
      For example, after @racket[(require/typed/check .... [#:opaque Foo foo?])],
       the predicate @racket[foo?] will be usable but the type @racket[Foo] will
       not be.
      Use @racket[require/typed] instead.
    }
  ]
}

