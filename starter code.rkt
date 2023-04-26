;; Below is the starter code of the assignment provided by CS 146 instructor team, which is a bare-bones Faux Racket interpreter

#lang racket

(require test-engine/racket-tests)

(struct bin (op fst snd) #:transparent) ; op is a symbol; fst, snd are ASTs.

(struct fun (param body) #:transparent) ; param is a symbol; body is an AST.

(struct app (fn arg) #:transparent) ; fn and arg are ASTs.

;; An AST is a (union bin fun app).

(struct sub (name val) #:transparent)

;; A substitution is a (sub n v), where n is a symbol and v is a value.
;; An environment (env) is a list of substitutions.

(struct closure (var body envt) #:transparent)
(struct seq (fst snd) #:transparent)
(struct result (val newstore) #:transparent)
(struct newbox (exp) #:transparent)
(struct openbox (exp) #:transparent)
(struct setbox (bexp vexp) #:transparent)


;; A closure is a (closure v bdy env), where
;; v is a symbol, bdy is an AST, and env is a environment.
;; A value is a (union number closure).

;; parse: sexp -> AST

(define (parse sx)
  (match sx
    [`(with ((,nm ,nmd)) ,bdy) (app (fun nm (parse bdy)) (parse nmd))]
    [`(+ ,x ,y) (bin '+ (parse x) (parse y))]
    [`(* ,x ,y) (bin '* (parse x) (parse y))]
    [`(- ,x ,y) (bin '- (parse x) (parse y))]
    [`(/ ,x ,y) (bin '/ (parse x) (parse y))]
    [`(fun (,x) ,bdy) (fun x (parse bdy))]
    [`(seq ,expr1 ,expr2) (seq (parse expr1) (parse expr2))]
    [`(box ,expr) (newbox (parse expr))]
    [`(unbox ,expr) (openbox (parse expr))]
    [`(setbox ,var ,newval) (setbox var (parse newval))]
    [`(,f ,x) (app (parse f) (parse x))]
    [x x]))

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

(define (change-store address newval store)
  (cond [(empty? store) (cons newval empty)]
        [(zero? address) (cons newval (rest store))]
        [else (cons (first store)
                    (change-store (sub1 address) newval (rest store)))]))


;; interp: AST env store -> value

(define (interp ast env store)
  (match ast
    [(fun v bdy) (result (closure v bdy env) store)]
    [(app fun-exp arg-exp)
       (match (interp fun-exp env store)
         [(result (closure v bdy cl-env) cl-store)
          (define result_arg (interp arg-exp cl-env cl-store))
          (define nl (length (result-newstore result_arg)))
          (define ne (cons (sub v nl) cl-env))
          (interp bdy ne (cons (result-val result_arg) (result-newstore result_arg)))])]
    [(bin op x y)
     (define result_x (interp x env store))
     (define result_y (interp y env (result-newstore result_x)))
     (result ((op-trans op) (result-val result_x)
                             (result-val result_y))
             (result-newstore result_y))]
    [(seq expr1 expr2)
     (define result_1 (interp expr1 env store))
     (interp expr2 env (result-newstore result_1))]
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
    [x (if (number? x)
           (result x store)
           (result (list-ref store  (sub1 (- (length store) (lookup-env x env)))) store))]))
             
; completely inadequate tests


(test)