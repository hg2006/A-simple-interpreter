# An-intepreter-for-Faux-Racket-W23-CS-146

## The interpreter and Faux Racket
The interpreter was done as assignment questions of CS 146, W23 offering, instructed by Brad Lushman, at the University of Waterloo.   
(for access to assignment page see the links)
For simplicity, the interpreter was implemented in Racket, and aiming at interpreting a tiny subset of the programming language Racket, we will refer to this language as "Faux Racket".

## Abstract Syntax Tree of Faux Racket
The Abstract Syntax Tree for Faux Racket below is provided by CS 146 instructor team on assignment page 
expr =	num
     |	var
     |	(+ expr expr)
     |	(* expr expr)
     |	(- expr expr)
     |	(/ expr expr)
     |	(fun (var) expr)
     |	(expr expr)
     |	(ifzero expr expr expr)
     |	(with ((var expr)) expr)
     |	(rec ((var expr)) expr)
     |  (seq expr expr)
     |  (set var expr)
     |  (box expr)
     |  (unbox expr)
     |  (setbox expr expr)
