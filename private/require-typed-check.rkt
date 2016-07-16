#lang racket/base

(provide
  require/typed/check
  ;; Same syntax as require/typed, but does not install contracts
  ;;  if the current module and providing module are typed.
)

(require
  (for-syntax racket/base)
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
      (let ([lib (syntax->datum lib-stx)])
        (hash-ref! cache lib
          (λ () ;; Typed Racket always installs a `#%type-decl` submodule
            (parameterize ([current-namespace (make-base-namespace)])
              (with-handlers ([exn:fail:contract? (lambda (exn) #f)])
                (dynamic-require lib #f '(#%type-decl))
                #t))))))))

(define-syntax (require/typed/check stx)
  (syntax-case stx ()
   [(_ lib clause* ...)
    (if (typed-lib? #'lib)
      (syntax/loc stx (require/typed lib clause* ...))
      (syntax/loc stx (require/typed/no-check lib clause* ...)))]
   ;; Default to `require/typed` on bad syntax
   [(_ lib)
    (syntax/loc stx (require/typed lib))]
   [_:id
    (syntax/loc stx require/typed)]))

