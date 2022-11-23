#lang racket/base

(provide
  clause)

(require
  (for-template (only-in typed/racket ann :))
  syntax/parse)

;; ---

;; Copied from:
;;    https://github.com/racket/typed-racket/blob/master/typed-racket-lib/typed/private/no-check-helper.rkt#L17
;; We use it to parse clauses for no-check.
;; Except, I added the `ann` properties

(define-syntax-class opt-parent
  #:attributes (nm parent)
  (pattern nm:id #:with parent #'#f)
  (pattern (nm:id parent:id)))

(define-syntax-class opt-rename
  #:attributes (nm orig-nm spec)
  (pattern nm:id
    #:with orig-nm #'nm
    #:with spec #'nm)
  (pattern (orig-nm:id nm:id)
    #:with spec #'(orig-nm internal-nm)))

(define-syntax-class simple-clause
  #:attributes (nm ty)
  (pattern [spec:opt-rename ty]
   #:attr nm #'spec.nm))

(define-splicing-syntax-class (struct-opts struct-name)
  #:attributes (ctor-value type)
  (pattern (~seq (~optional (~seq (~and key (~or #:extra-constructor-name #:constructor-name))
                            name:id))
                 (~optional (~seq #:type-name type:id) #:defaults ([type struct-name])))
    #:attr ctor-value (if (attribute key) #'(key name) #'())))

(define-syntax-class struct-clause
  #:attributes (nm type (body 1) (constructor-parts 1) (tvar 1))
  (pattern [(~or (~datum struct) #:struct)
            (~optional (~seq (tvar ...)) #:defaults ([(tvar 1) '()]))
            nm:opt-parent (body ...)
            (~var opts (struct-opts #'nm.nm))]
    #:with (constructor-parts ...) #'opts.ctor-value
    #:attr type #'opts.type))

(define-syntax-class signature-clause
  #:literals (:)
  #:attributes (sig-name [var 1] [type 1])
  (pattern [#:signature sig-name:id ([var:id : type] ...)]))

(define-syntax-class opaque-clause
  #:attributes (ty pred opt)
  (pattern [(~or (~datum opaque) #:opaque) ty:id pred:id]
    #:with opt #'())
  (pattern [(~or (~datum opaque) #:opaque) opaque ty:id pred:id #:name-exists]
    #:with opt #'(#:name-exists)))

(define-syntax-class (clause lib)
  #:attributes (ann req)
    (pattern oc:opaque-clause
      #:attr ann #'#f
      #:attr req #`(require/typed #,lib (#:opaque oc.ty oc.pred . oc.opt)))
    (pattern (~var strc struct-clause)
      #:attr ann #'#f
      #:attr req #'#f)
      ; TODO check struct annotations
      ;#:attr spec
      ;#`(require-typed-struct strc.nm (strc.tvar ...)
      ;    (strc.body ...) strc.constructor-parts ...
      ;    #:type-name strc.type
      ;    #,@(if unsafe? #'(unsafe-kw) #'())
      ;    #,lib)
    (pattern sig:signature-clause
      #:attr ann #'#f
      #:attr req #'#f)
      ; TODO check signature annotations
    (pattern sc:simple-clause
      #:attr ann #'(ann sc.nm sc.ty)
      #:attr req #'#f))

