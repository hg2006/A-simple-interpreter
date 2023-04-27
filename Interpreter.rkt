#lang racket

(require test-engine/racket-tests)


;; ------------------------- A bit more to notice ---------------------------------------------------


;; To directly obtain the actual result of interpretation an expr, one should use the
;; following template (since interpret returns a result that is a struct):
;; (result-val (interp (parse expr) empty empty)).
;; The expr should be in the form as a list, i.e. '(...)

;; Also note interp requires two extra parameters aside from the expr, to assure the
;; program functions correctly, please put empty or '() for both.

;; Several examples of interpreting are provided at the end in the form of check-expect


;; -------------------- Useful AST structures for parsing -------------------------------------------


;; A closure is a (closure v bdy env), where
;; v is a symbol, bdy is an AST, and env is a environment.
;; A value is a (union number closure).

(struct bin (op fst snd) #:transparent) ; op is a symbol; fst, snd are ASTs.

(struct fun (param body) #:transparent) ; param is a symbol; body is an AST.

(struct app (fn arg) #:transparent) ; fn and arg are ASTs.

;; An AST is a (union bin fun app).

(struct sub (name val) #:transparent)

;; A substitution is a (sub n v), where n is a symbol and v is a value.
;; An environment (env) is a list of substitutions.

(struct closure (var body envt) #:transparent)
(struct ifzero (t tb fb) #:transparent)
(struct rec (nm nmd body) #:transparent)
(struct seq (fst snd) #:transparent)
(struct set (var newval) #:transparent)
(struct newbox (exp) #:transparent)
(struct openbox (exp) #:transparent)
(struct setbox (bexp vexp) #:transparent)
(struct result (val newstore) #:transparent)


;; -------------------------------- Parsing ---------------------------------------------------------


;; parse: sexp -> AST

(define (parse sx)
  (match sx
    [`(with ((,nm ,nmd)) ,bdy) (app (fun nm (parse bdy)) (parse nmd))]
    [`(+ ,x ,y) (bin '+ (parse x) (parse y))]
    [`(* ,x ,y) (bin '* (parse x) (parse y))]
    [`(- ,x ,y) (bin '- (parse x) (parse y))]
    [`(/ ,x ,y) (bin '/ (parse x) (parse y))]
    [`(rec ((,nm ,nmd)) ,bdy) (rec nm (parse nmd) (parse bdy))]
    [`(ifzero ,t ,tb ,fb)
     (ifzero (parse t) (parse tb) (parse fb))]
    [`(fun (,x) ,bdy) (fun x (parse bdy))]
    [`(seq ,expr1 ,expr2) (seq (parse expr1) (parse expr2))]
    [`(set ,var ,expr) (set (parse var) (parse expr))]
    [`(box ,expr) (newbox (parse expr))]
    [`(unbox ,expr) (openbox (parse expr))]
    [`(setbox ,var ,newval) (setbox var (parse newval))]
    [`(,f ,x) (app (parse f) (parse x))]
    [x x]))


;; ------------------------ Other useful helper functions -------------------------------------------


; op-trans: symbol -> (number number -> number)
; converts symbolic representation of arithmetic function to actual Racket function
(define (op-trans op)
  (match op
    ['+ +]
    ['* *]
    ['- -]
    ['/ /]))



;; lookup: symbol env -> value
;; looks up a substitution in an environment (topmost one)

(define (lookup-env var env)
  (cond
    [(empty? env) (error 'interp "unbound variable ~a" var)]
    [(symbol=? var (sub-name (first env))) (sub-val (first env))]
    [else (lookup-env var (rest env))]))

;; change-store: Nat(representing addr) Num store -> store
;; changes the value stored at the position representing by address in the store
;; to newval
(define (change-store address newval store)
  (cond [(empty? store) (cons newval empty)]
        [(zero? address) (cons newval (rest store))]
        [else (cons (first store)
                    (change-store (sub1 address) newval (rest store)))]))


;; ---------------------------------- Interp --------------------------------------------------------


;; interp: AST env store -> result

(define (interp ast env store)
  (match ast
    [(fun v bdy) (result (closure v bdy env) store)]
    [(app fun-exp arg-exp)
     ;; apply the argument arg-exp to the function body fun-exp
       (match (interp fun-exp env store)
         [(result (closure v bdy cl-env) cl-store)
          (define result_arg (interp arg-exp cl-env cl-store))
          (define nl (length (result-newstore result_arg)))
          ;; Note here a rather easy implementation of adding new elements into the store is adopted,
          ;; that we simply insert it to the end of the current store. This could make the store
          ;; grow to be unnecessarily long over time, and thus not space efficient.
          (define ne (cons (sub v nl) cl-env))                     
          (interp bdy ne (cons (result-val result_arg) (result-newstore result_arg)))])]
    [(bin op x y) 
     (define result_x (interp x env store))
     (define result_y (interp y env (result-newstore result_x)))
     (result ((op-trans op) (result-val result_x)
                            (result-val result_y))
             (result-newstore result_y))]
    [(rec nm nmd bdy) (interp bdy (cons (sub nm (length store)) env) (cons nmd store))]
    [(ifzero x y z)
     (match (interp x env store)
       [(result val nstore)
        (if (zero? val) (interp y env nstore) (interp z env nstore))])]
    [(seq expr1 expr2)
     (define result_1 (interp expr1 env store))
     (interp expr2 env (result-newstore result_1))]
    [(set var newval)
     (define result_newval (interp newval env store))
     (result (void) (change-store (sub1 (- (length store) (lookup-env var env)))
                                  (result-val result_newval)
                                  (result-newstore result_newval)))]                
    [(newbox expr)
     (define nval (interp expr env store))
     (result (length (result-newstore nval))
             (cons (result-val nval) (result-newstore nval)))]
    [(openbox expr)
     (define nval (interp expr env store))
     (result (list-ref (result-newstore nval)
                       (sub1 (- (length (result-newstore nval)) (result-val nval))))
             (result-newstore nval))]
    [(setbox var newval)
     (define first-val (interp var env store))
     (define address (result-val first-val))
     (define new-str (result-newstore first-val))
     (define second-val (interp newval env new-str))
     (result (void) (change-store (sub1 (- (length (result-newstore second-val)) address))
                                  (result-val second-val)
                                  (result-newstore second-val)))]
    [x (cond [(number? x)
              (result x store)]
             [else (define res (list-ref store  (sub1 (- (length store) (lookup-env x env)))))
                   (if (closure? res)
                       (result res store)
                       (interp res env store))])]))


;; ---------------------------------- Example -------------------------------------------------------

;; 1. Interpreting a simple arithmetic expression
(check-expect (result-val (interp
                           (parse '(+ (/ 6 3) (* 2 (- 2 1))))
                           '()
                           '()))
              4)

;; 2. Interpreting a lambda without argument provided will result in a closure. Since a value is 
;; a (union number closure)
(check-expect (result-val (interp (parse
                                   '(fun (x) (+ x 2)))
                                  '()
                                  '()))
              (closure 'x (bin '+ 'x 2) '()))

;; 3. Desmonstrating the use of with
(check-expect (result-val (interp
                           (parse '(with ((n 2))      
                                         (with ((f (fun (x) (+ x n))))                    
                                               (f 1))))
                           '()
                           '()))
              3)

;; 4. Demonstrating the use of set, note there's no aliasing between x & y
(check-expect (result-val (interp
                          (parse '(with ((x 0))
                                        (with ((y x))
                                              (seq (set y x)
                                                   (+ (seq (set x 5) y)
                                                      (seq (set x 6) x))))))
                                 '()
                          '()))
             6)

;; 5. Demonstrating the use of box, unbox & setbox, note the aliasing between x & y as boxes
(check-expect (result-val (interp
                          (parse '(with ((x (box 0)))
                                        (with ((y x))
                                              (+ (seq (setbox x 5) (unbox y))
                                                 (seq (setbox x 6) (unbox x))))))
                          '()
                          '()))
              11)

;; 6. Note with does not support a recursive definition, this function takes in a natural number
;; and calculates its factorial recursively.
(check-error (result-val (interp
                          (parse '(with ((fact
                                          (fun (x) (ifzero x
                                                           1
                                                           (fact (- x 1))))))                    
                                        (fact 5)))
                          '()
                          '())))

;; 7. Demonstrating how to define a recursive function using rec, this function takes in a natural number
;; and calculates its factorial recursively.
(check-expect (result-val (interp
                           (parse '(rec ((fact
                                          (fun (x) (ifzero x
                                                           1
                                                           (* x (fact (- x 1)))))))                    
                                     (fact 5)))
                          '()
                          '()))
              120)


(test)

             