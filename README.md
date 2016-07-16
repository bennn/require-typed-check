require-typed-check
===

If you want to require a module `m` but are not sure whether `m` is a Racket or
 Typed Racket module, try:

```
(require require-typed-check)
(require/typed/check m
  (id type)
  ....)
```

The syntax is the same as [`require/typed`](https://docs.racket-lang.org/ts-reference/special-forms.html#%28form._%28%28lib._typed-racket%2Fbase-env%2Fprims..rkt%29._require%2Ftyped%29%29).
If `m` happens to be typed, the statement expands to `(require (only-in m id ....))`.
Otherwise, identifiers from `m` are protected with contracts.


Install
---

Through [pkgs.racket-lang.org](http://pkgs.racket-lang.org/):

```
> raco pkg install require-typed-check
```

From source:

```
> git clone https://github.com/nuprl/require-typed-check
> raco pkg install ./require-typed-check
```


Usage
---

Replace your `require/typed` with `require/typed/check`. That's it.
This is useful because `require/typed` always guards imports with a contract.

Used heavily by our [performance evaluation of gradual typing](https://github.com/nuprl/gradual-typing-performance)
 to programmatically generate all ways of typing a fixed group of modules.
This package exists to make benchmarks from the "GTP" project more portable.

