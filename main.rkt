#lang typed/racket/base

(require
  (rename-in require-typed-check/deep
    (require/typed/check/deep require/typed/check)))

(provide
  require/typed/check)
