#lang racket/base

;; Creates submodules for Deep, Shallow, Optional, and Unsafe clients

(require
  (for-syntax racket/base)
  syntax/parse/define)

;; ---

(define-simple-macro (module/rtc mod-id #:provide rtc-id -rtc-require)
  #:with rtc-require (syntax-local-introduce (syntax/loc this-syntax -rtc-require))
  (module mod-id racket/base
    (provide
      ;; Same syntax as require/typed, but does not install contracts
      ;;  if the current module and providing module are typed.
      rtc-id)
    (require
      rtc-require
      (for-syntax
        racket/base syntax/location syntax/parse
        require-typed-check/private/stxcls
        require-typed-check/private/typed-lib-cache
        require-typed-check/private/log)
      (rename-in typed/racket/no-check [require/typed require/typed/no-check]))
    ;; ---
    (define-for-syntax disable-require-typed-check?
      (and (getenv "DISABLE_REQUIRE_TYPED_CHECK") #true))
    (define-for-syntax typed-lib?
      (make-typed-lib?))
    (define-syntax (rtc-id stx)
      (syntax-parse stx
       [(_ lib clause* (... ...))
        (begin
          (log-require-typed-check stx)
          (if (or disable-require-typed-check? (not (typed-lib? #'lib)))
            ;; then : do a normal require/typed
            (syntax/loc stx (require/typed lib clause* (... ...)))
            ;; else : do a no-check require/typed, but do check the type annotations
            (syntax-parse #'(clause* (... ...))
             [((~var c* (clause #'lib)) (... ...))
              #:with (req* (... ...))
                     (for/list ([req (in-list (syntax-e #'(c*.req (... ...))))]
                                #:when (syntax-e req))
                       req)
              #:with (ann* (... ...))
                     (for/list ([ann (in-list (syntax-e #'(c*.ann (... ...))))]
                                #:when (syntax-e ann))
                       ann)
              (syntax/loc stx
                (begin
                  (require/typed/no-check lib clause* (... ...))
                  req* (... ...)        ;; Import opaque types
                  (void ann* (... ...)) ;; Check user-defined type annotations
                  ))])))]
       ;; Default to `require/typed` on bad syntax
       [(_ lib)
        (syntax/loc stx (require/typed lib))]
       [_:id
        (syntax/loc stx require/typed)]))))

;; ---

(module/rtc deep
  #:provide require/typed/check/deep
  (only-in typed/racket/deep require/typed))

(module/rtc unsafe
  #:provide unsafe-require/typed/check
  (rename-in typed/racket/unsafe [unsafe-require/typed require/typed]))

(module/rtc shallow
  #:provide require/typed/check/shallow
  (only-in typed/racket/shallow require/typed))

(module/rtc optional
  #:provide require/typed/check/optional
  (only-in typed/racket/optional require/typed))

