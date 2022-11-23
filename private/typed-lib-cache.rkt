#lang racket/base

(provide
  make-typed-lib?)

;; ---

(define (make-typed-lib?)
  ;; Q. Is the typed-lib cache worth using?
  ;;
  ;; Here are some timings from `test/` files, collected by running
  ;;  `rm -r test/compiled; time raco make -v test/TEST.rkt`
  ;; and eyeballing an average. (Times are in seconds.)
  ;;
  ;;   ___mod_|_stress_|_fsm_
  ;;   nohash |  3.00  | 6.46
  ;;     hash |  2.75  | 6.49
  ;;
  ;; So let's just keep the cache
  ;; typed-lib? : (Syntaxof Module-Path) -> Boolean
  (let ([cache (make-hash)])
    (λ (lib-stx)
      (let* ([lib (syntax->datum lib-stx)]
             [dyn-path (and (not (relative-submod? lib))
                            (append
                              (if (submod? lib)
                                (resolve-submod #f #;(syntax-source-file-name lib-stx) lib)
                                (list 'submod lib))
                              '(#%type-decl)))])
        (hash-ref! cache lib
          (λ () ;; Typed Racket always installs a `#%type-decl` submodule
            (and dyn-path
                 (module-declared? dyn-path #true)
                 #true)))))))

;; : Require-Spec -> Boolean
(define (submod? x)
  (and (list? x) (not (null? x)) (eq? 'submod (car x))))

;; : Require-Spec -> Boolean
(define (relative-submod? x)
  (and (submod? x)
       (not (null? (cdr x)))
       (or (string=? "." (cadr x))
           (string=? ".." (cadr x)))))

;; : Submod-Path -> Module-Path
(define (resolve-submod src l)
  (case (cadr l)
   [(".." ".")
    ;; Circular dependency issue, cannot compile the module without
    ;;  compiling the module's submodules.
    (raise-argument-error 'require/typed/check "Non-relative submodule" l)]
   [else
    l]))

