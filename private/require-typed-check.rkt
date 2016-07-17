#lang racket/base

(provide
  require/typed/check
  ;; Same syntax as require/typed, but does not install contracts
  ;;  if the current module and providing module are typed.
)

(require
  (for-syntax racket/base syntax/location)
  (only-in typed/racket require/typed)
  (rename-in typed/racket/no-check [require/typed require/typed/no-check]))

;; =============================================================================

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
(define-for-syntax typed-lib?
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
            (parameterize ([current-namespace (make-base-namespace)])
              (with-handlers ([exn:fail:contract? (lambda (exn) #f)])
                (and dyn-path
                     (dynamic-require dyn-path #f)
                     #t)))))))))

;; : Require-Spec -> Boolean
(define-for-syntax (submod? x)
  (and (list? x) (not (null? x)) (eq? 'submod (car x))))

;; : Require-Spec -> Boolean
(define-for-syntax (relative-submod? x)
  (and (submod? x)
       (not (null? (cdr x)))
       (or (string=? "." (cadr x))
           (string=? ".." (cadr x)))))

;; : Submod-Path -> Module-Path
(define-for-syntax (resolve-submod src l)
  (case (cadr l)
   [(".." ".")
    ;; Circular dependency issue ... cannot compile the module without
    ;;  compiling the module's submodules.
    (raise-argument-error 'require/typed/check "Non-relative submodule" l)]
   [else
    l]))

(define-syntax (require/typed/check stx)
  (syntax-case stx ()
   [(_ lib clause* ...)
    (begin
      (if (typed-lib? #'lib)
        (syntax/loc stx (require/typed/no-check lib clause* ...))
        (syntax/loc stx (require/typed lib clause* ...))))]
   ;; Default to `require/typed` on bad syntax
   [(_ lib)
    (syntax/loc stx (require/typed lib))]
   [_:id
    (syntax/loc stx require/typed)]))

