require-typed-check
===
[![Build Status](https://travis-ci.org/bennn/require-typed-check.svg)](https://travis-ci.org/bennn/require-typed-check)
[![Scribble](https://img.shields.io/badge/Docs-Scribble-blue.svg)](http://docs.racket-lang.org/require-typed-check/index.html)

If you want to require a module `m` but are not sure whether `m` is a Racket or
 Typed Racket module, try:

```
(require require-typed-check)
(require/typed/check m
  (id type)
  ....)
```

The syntax is the same as [`require/typed`](https://docs.racket-lang.org/ts-reference/special-forms.html#%28form._%28%28lib._typed-racket%2Fbase-env%2Fprims..rkt%29._require%2Ftyped%29%29).
If `m` happens to be a Typed Racket module, the statement expands to `(require (only-in m id ....))`.
Otherwise, the statement expands to a `require/typed`.


Install
---

Through [pkgs.racket-lang.org](http://pkgs.racket-lang.org/):

```
> raco pkg install require-typed-check
```

From source:

```
> git clone https://github.com/bennn/require-typed-check
> raco pkg install ./require-typed-check
```


Usage
---

Replace your `require/typed` with `require/typed/check`. That's it.
This is useful because `require/typed` always guards imports with a contract.

Used heavily by our [performance evaluation of gradual typing](https://github.com/nuprl/gradual-typing-performance)
 to programmatically generate all ways of typing a fixed group of modules.
This package exists to make benchmarks from the "GTP" project more portable.


Example
---

The `math` library happens to be typed and the `racket/contract` library
 happens to be untyped.
A `typed/racket` program can use `require/typed` to import functions from either
 library, but the functions from `math` will be wrapped in an unnecessary contract.
Using `require/typed/check` avoids the unnecessary contract:

```
#lang typed/racket/base

(require require-typed-check)

(require/typed/check math
  (divides? (-> Integer Integer Boolean)))

(require/typed/check racket/contract
  (has-contract? (-> Any Boolean)))

(has-contract? divides?)
;; ==> #false
(has-contract? has-contract?)
;; ==> #true
```
