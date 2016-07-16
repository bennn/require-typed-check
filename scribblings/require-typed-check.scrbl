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
      All submodules of a Typed Racket module are assumed typed.
      Do not use @racket[require/typed/check] to import a submodule
       (you will get type checker errors about "missing type for identifier").
    }
    @item{
      Does not generate type definitions from @racket[#:opaque] imports
       (but does require the predicate).
      Use @racket[require/typed] instead.

      For example, after @racket[(require/typed/check .... [#:opaque Foo foo?])],
       the predicate @racket[foo?] will be usable but the type @racket[Foo] will
       not be.
    }
    @item{
      @racket[(require/typed/check 'foo ....)] does not work at all and generates
       a confusing error message.
    }
  ]
}

