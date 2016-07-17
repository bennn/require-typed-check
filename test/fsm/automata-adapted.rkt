#lang typed/racket

(define-type Automaton automaton)
(define-type Probability Nonnegative-Real)
(define-type Population (cons Automaton* Automaton*))
(define-type Automaton* [Vectorof Automaton])
(define-type Payoff Nonnegative-Real)

(define-type State Natural)
(define-type Transition* [Vectorof Transition])
(define-type Transition [Vectorof State])

(require require-typed-check)
(require/typed/check require-typed-check/test/fsm/automata
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
