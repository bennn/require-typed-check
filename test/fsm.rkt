#lang typed/racket/base

;; Larger test, taken from gradual typing benchmark.
;; Uses #:struct

(module automata typed/racket

    ;; An N-states, N-inputs Automaton

    (define-type Automaton automaton)
    (define-type Payoff Nonnegative-Real)

    (provide
     defects
     cooperates
     tit-for-tat
     grim-trigger
     make-random-automaton
     match-pair
     automaton-reset
     clone
     automaton-payoff
     ;; --
     (struct-out automaton)
     ;automaton?
     ;Automaton
     ;Payoff
    )
     (: defects (-> Payoff Automaton))
     (: cooperates (-> Payoff Automaton))
     (: tit-for-tat (-> Payoff Automaton))
     (: grim-trigger (-> Payoff Automaton))
     (: make-random-automaton
      ;; (make-random-automaton n) builds an n states x n inputs automaton
      ;; with a random transition table 
      (-> Natural Automaton))
     
     (: match-pair
       ;; give each automaton the reaction of the other in the current state
       ;; determine payoff for each and transition the automaton
       (-> Automaton Automaton Natural (values Automaton Automaton)))

     (: automaton-reset
      ;; wipe out the historic payoff, set back to original state
      (-> Automaton Automaton))
     (: clone
      ;; create new automaton from given one (same original state)
      (-> Automaton Automaton))

    ;; -----------------------------------------------------------------------------
    (: COOPERATE State)
    (define COOPERATE 0)
    (: DEFECT State)
    (define DEFECT    1)

    (define-type State Natural)
    (define-type Transition* [Vectorof Transition])
    (define-type Transition [Vectorof State])

    (struct automaton ({current : State}
                       {original : State}
                       {payoff : Payoff}
                       {table : Transition*}) #:transparent)

    (define (make-random-automaton n)
      (: transitions [-> Any Transition])
      (define (transitions _i) (build-vector n (lambda (_) (random n))))
      (define original-current (random n))
      (automaton original-current original-current 0 (build-vector n transitions)))

    (: make-automaton (-> State Transition* Automaton))
    (define (make-automaton current table)
      (automaton current current 0 table))

    (: transitions (-> #:i-cooperate/it-cooperates State
                       #:i-cooperate/it-defects    State
                       #:i-defect/it-cooperates    State
                       #:i-defect/it-defects  State
                       Transition*))
    (define (transitions #:i-cooperate/it-cooperates cc
                         #:i-cooperate/it-defects    cd
                         #:i-defect/it-cooperates    dc
                         #:i-defect/it-defects       dd)
      (vector (vector cc cd)
              (vector dc dd)))

    ;; CLASSIC AUTOMATA
    ;; the all defector has 2 states of cooperate and defect
    ;; but it always defects, no matter what
    ;; the opponent may play cooperate or defect
    ;; it doesnt care, it always stay in the state defect

    (define defect-transitions
      (transitions #:i-cooperate/it-cooperates DEFECT 
                   #:i-cooperate/it-defects    DEFECT
                   #:i-defect/it-cooperates    DEFECT
                   #:i-defect/it-defects       DEFECT))

    (define (defects p0)
      (automaton DEFECT DEFECT p0 defect-transitions))

    (define cooperates-transitions
      (transitions #:i-cooperate/it-cooperates COOPERATE 
                   #:i-cooperate/it-defects    COOPERATE
                   #:i-defect/it-cooperates    COOPERATE
                   #:i-defect/it-defects       COOPERATE))

    (define (cooperates p0)
      (automaton COOPERATE COOPERATE p0 cooperates-transitions))

    ;; the tit for tat starts out optimistic, it cooperates initially
    ;; however, if the opponent defects, it punishes by switching to defecting
    ;; if the opponent cooperates, it returns to play cooperate again

    (define tit-for-tat-transitions
      (transitions #:i-cooperate/it-cooperates COOPERATE 
                   #:i-cooperate/it-defects    DEFECT
                   #:i-defect/it-cooperates    COOPERATE
                   #:i-defect/it-defects       DEFECT))


    (define (tit-for-tat p0)
      (automaton COOPERATE COOPERATE p0 tit-for-tat-transitions))

    ;; the grim trigger also starts out optimistic,
    ;; but the opponent defects for just once then
    ;; it jumps to defect forever
    ;; it doesnt forgive, and doesnt forget

    (define grim-transitions
      (transitions #:i-cooperate/it-cooperates COOPERATE 
                   #:i-cooperate/it-defects    DEFECT
                   #:i-defect/it-cooperates    DEFECT
                   #:i-defect/it-defects       DEFECT))

    (: grim-trigger (-> Payoff Automaton))
    (define (grim-trigger p0)
      (automaton COOPERATE COOPERATE p0 grim-transitions))

    (define (automaton-reset a)
      (match-define (automaton current c0 payoff table) a)
      (automaton c0 c0 0 table))

    (define (clone a)
      (match-define (automaton current c0 payoff table) a)
      (automaton c0 c0 0 table))

    ;; -----------------------------------------------------------------------------
    ;; the sum of pay-offs for the two respective automata over all rounds

    (define (match-pair auto1 auto2 rounds-per-match)
      (match-define (automaton current1 c1 payoff1 table1) auto1)
      (match-define (automaton current2 c2 payoff2 table2) auto2)
      (define-values (new1 p1 new2 p2)
        (for/fold ([current1 : State current1]
                   [payoff1 : Payoff payoff1]
                   [current2 : State current2]
                   [payoff2 : Payoff payoff2])
                  ([_ (in-range rounds-per-match)])
          (match-define (cons p1 p2) (payoff current1 current2))
          (define n1 (vector-ref (vector-ref table1 current1) current2))
          (define n2 (vector-ref (vector-ref table2 current2) current1))
          (values n1 (+ payoff1 p1) n2 (+ payoff2 p2))))
      (values (automaton new1 c1 p1 table1) (automaton new2 c2 p2 table2)))

    ;; -----------------------------------------------------------------------------
    ;; PayoffTable = [Vectorof k [Vectorof k (cons Payoff Payoff)]]
    (: PAYOFF-TABLE [Vectorof [Vectorof (cons Payoff Payoff)]])
    (define PAYOFF-TABLE
      (vector (vector (cons 3 3) (cons 0 4))
              (vector (cons 4 0) (cons 1 1))))

    (: payoff (-> State State [cons Payoff Payoff]))
    (define (payoff current1 current2)
      (vector-ref (vector-ref PAYOFF-TABLE current1) current2))
)

(module automata-adapted typed/racket

    (define-type Automaton automaton)
    (define-type Probability Nonnegative-Real)
    (define-type Population (cons Automaton* Automaton*))
    (define-type Automaton* [Vectorof Automaton])
    (define-type Payoff Nonnegative-Real)

    (define-type State Natural)
    (define-type Transition* [Vectorof Transition])
    (define-type Transition [Vectorof State])

    (require require-typed-check)
    (require/typed/check (submod ".." automata)
     ;[#:opaque Automaton automaton?]
    (#:struct automaton ({current : State}
                       {original : State}
                       {payoff : Payoff}
                       {table : Transition*}))
     (defects (-> Payoff Automaton))
     (cooperates (-> Payoff Automaton))
     (tit-for-tat (-> Payoff Automaton))
     (grim-trigger (-> Payoff Automaton))
     (make-random-automaton
      (-> Natural Automaton))
     (match-pair
       (-> Automaton Automaton Natural (values Automaton Automaton)))
     (automaton-reset
      (-> Automaton Automaton))
     (clone
      (-> Automaton Automaton))
    )

    (provide
    defects cooperates tit-for-tat grim-trigger match-pair automaton-reset clone
    make-random-automaton
    automaton-payoff
    Automaton
    Probability Population Automaton* Payoff)
)

(module utilities typed/racket
;; Utility Functions

(define-type Probability Nonnegative-Real)
;; constraint [0,1]

(provide
 ;Probability
 ;; ---
 sum
 relative-average
 choose-randomly)

 (: sum (-> [Listof Real] Real))
 (: relative-average (-> [Listof Real] Real Real))
 (: choose-randomly
  (-> [Listof Probability] Natural [#:random (U False Real)] [Listof Natural]))

;; =============================================================================

(define (sum l)
  (apply + l))


(define (relative-average l w)
  (exact->inexact
   (/ (sum l)
      w (length l))))

;; -----------------------------------------------------------------------------

(define (choose-randomly probabilities speed #:random (q #false))
  (define %s (accumulated-%s probabilities))
  (for/list ([n (in-range speed)])
    [define r (or q (random))]
    ;; population is non-empty so there will be some i such that ...
    (let loop : Natural ([%s : [Listof Real] %s])
      (cond
        [(< r (first %s)) 0]
        [else (add1 (loop (rest %s)))]))
    #;
    (for/last ([p (in-naturals)] [% (in-list %s)] #:final (< r %)) p)))

(: accumulated-%s (-> [Listof Probability] [Listof Real]))
;; [Listof Probability] -> [Listof Probability]
;; calculate the accumulated probabilities 

(define (accumulated-%s probabilities)
  (define total (sum probabilities))
  (let relative->absolute : [Listof Real]
    ([payoffs : [Listof Real] probabilities][so-far : Real #i0.0])
    (cond
      [(empty? payoffs) '()]
      [else (define nxt (+ so-far (first payoffs)))
            ({inst cons Real Real}
             (/ nxt total) (relative->absolute (rest payoffs) nxt))])))
)

(module population typed/racket
    ;; Populations of Automata

    (provide
      build-random-population
      population-payoffs
      match-up*
      death-birth
      ;; == 
      ;Payoff
      ;Population
    )
     (: build-random-population
      ;; (build-population n c) for even n, build a population of size n 
      ;; with c constraint: (even? n)
      (-> Natural Population))
     (: population-payoffs (-> Population [Listof Payoff]))
     (: match-up*
      ;; (match-ups p r) matches up neighboring pairs of
      ;; automata in population p for r rounds 
      (-> Population Natural Population))
     (: death-birth
      ;; (death-birth p r) replaces r elements of p with r "children" of 
      ;; randomly chosen fittest elements of p, also shuffle 
      ;; constraint (< r (length p))
      (-> Population Natural [#:random (U False Real)] Population))

    ;; =============================================================================
    (require (submod ".." automata-adapted))
    (require require-typed-check)
    (require/typed/check (submod ".." utilities)
     (choose-randomly
      (-> [Listof Probability] Natural [#:random (U False Real)] [Listof Natural]))
    )

    ;; Population = (Cons Automaton* Automaton*)
    ;; Automaton* = [Vectorof Automaton]

    (define DEF-COO 2)

    ;; -----------------------------------------------------------------------------
    (define (build-random-population n)
      (define v (build-vector n (lambda (_) (make-random-automaton DEF-COO))))
      (cons v v))

    ;; -----------------------------------------------------------------------------
    (define (population-payoffs population0)
      (define population (car population0))
      (for/list ([a population]) (automaton-payoff a)))

    ;; -----------------------------------------------------------------------------

    (define (match-up* population0 rounds-per-match)
      (define a* (car population0))
      ;; comment out this line if you want cummulative payoff histories:
      ;; see below in birth-death
      (population-reset a*)
      ;; -- IN --
      (for ([i (in-range 0 (- (vector-length a*) 1) 2)])
        (define p1 (vector-ref a* i))
        (define p2 (vector-ref a* (+ i 1)))
        (define-values (a1 a2) (match-pair p1 p2 rounds-per-match))
        (vector-set! a* i a1)
        (vector-set! a* (+ i 1) a2))
      population0)

    (: population-reset (-> Automaton* Void))
    ;; effec: reset all automata in a*
    (define (population-reset a*)
      (for ([x (in-vector a*)][i (in-naturals)])
        (vector-set! a* i (automaton-reset x))))

    ;; -----------------------------------------------------------------------------

    (define (death-birth population0 rate #:random (q #false))
      (match-define (cons a* b*) population0)
      (define payoffs
        (for/list : [Listof Payoff] ([x : Automaton (in-vector a*)])
          (automaton-payoff x)))
      [define substitutes (choose-randomly payoffs rate #:random q)]
      (for ([i (in-range rate)][p (in-list substitutes)])
        (vector-set! a* i (clone (vector-ref b* p))))
      (shuffle-vector a* b*))

    (: shuffle-vector
       (All (X) (-> (Vectorof X) (Vectorof X) (cons (Vectorof X) (Vectorof X)))))
    ;; effect: shuffle vector b into vector a
    ;; constraint: (= (vector-length a) (vector-length b))
    ;; Fisher-Yates Shuffle

    (define (shuffle-vector b a)
      ;; copy b into a
      (for ([x (in-vector b)][i (in-naturals)])
        (vector-set! a i x))
      ;; now shuffle a 
      (for ([x (in-vector b)] [i (in-naturals)])
        (define j (random (add1 i)))
        (unless (= j i) (vector-set! a i (vector-ref a j)))
        (vector-set! a j x))
      (cons a b))
)

(module main typed/racket

    ;; Run a Simulation of Interacting Automata
    (random-seed 7480)

    ;; =============================================================================
    (require (submod ".." automata-adapted))
    (require require-typed-check)
    (require/typed/check (submod ".." population)
     (build-random-population
      (-> Natural Population))
     (population-payoffs (-> Population [Listof Payoff]))
     (death-birth
      (-> Population Natural [#:random (U False Real)] Population))
     (match-up*
      (-> Population Natural Population))
    )
    (require/typed/check (submod ".." utilities)
     (relative-average (-> [Listof Real] Real Real))
    )
    (require/typed/check (submod ".." utilities)
     (choose-randomly
      (-> [Listof Probability] Natural [#:random (U False Real)] [Listof Natural]))
    )

    ;; effect: run timed simulation, create and display plot of average payoffs
    ;; effect: measure time needed for the simulation
    (define (main)
       (simulation->lines
        (evolve (build-random-population 100) 500 10 20))
       (void))

    (: simulation->lines (-> [Listof Payoff] [Listof [List Integer Real]]))
    ;; turn average payoffs into a list of Cartesian points 
    (define (simulation->lines data)
      (for/list : [Listof [List Integer Real]]
        ([d : Payoff (in-list data)][n : Integer (in-naturals)])
        (list n d)))

    (: evolve (-> Population Natural Natural Natural [Listof Payoff]))
    ;; computes the list of average payoffs over the evolution of population p for
    ;; c cycles of of match-ups with r rounds per match and at birth/death rate of s
    (define (evolve p c s r)
      (cond
        [(zero? c) '()]
        [else (define p2 (match-up* p r))
              ;; Note: r is typed as State even though State is not exported 
              (define pp (population-payoffs p2))
              (define p3 (death-birth p2 s))
              ;; Note: s same as r
              ({inst cons Payoff [Listof Payoff]}
               (cast (relative-average pp r) Payoff)
               ;; Note: evolve is assigned (-> ... [Listof Probability])
               ;; even though it is explicitly typed ... [Listof Payoff]
               (evolve p3 (- c 1) s r))]))

    ;; -----------------------------------------------------------------------------
    (provide main)
)

(module+ test
    (require (submod ".." main) require-typed-check)
    (require typed/racket/sandbox)
    (#{call-with-limits @ Void} 20 #f ;; TONS of time
      (lambda () (begin (time (main)) (values (void))))))
