# An-intepreter-for-Faux-Racket-W23-CS-146

## The interpreter and Faux Racket
The interpreter was done as assignment questions of CS 146, W23 offering, instructed by Brad Lushman, at the University of Waterloo. Relevant assignments are [Q5: Recursion], [Q6: Mutation], [Q7: Boxes].
<br>
<br>
For simplicity, the interpreter was implemented in Racket, and aiming at interpreting a tiny subset of the programming language Racket, we will refer to this language as "Faux Racket".

---

## Abstract Syntax Tree of Faux Racket
The Abstract Syntax Tree (presented in Haskell grammar) for Faux Racket below is provided by CS 146 instructor team on assignment page <br>
_expr_ =  num  <br>
&emsp; &emsp; |  var  <br>
&emsp; &emsp; |  (+ _expr_ _expr_) <br>
&emsp; &emsp; |  (* _expr_ _expr_) <br>
&emsp; &emsp; |  (- _expr_ _expr_) <br>
&emsp; &emsp; |  (/ _expr_ _expr_) <br>
&emsp; &emsp; |  (fun (var) _expr_) <br>
&emsp; &emsp; |  (_expr_ _expr_) <br>
&emsp; &emsp; |  (ifzero _expr_ _expr_ _expr_) <br>
&emsp; &emsp; |  (with ((var _expr_)) _expr_) <br>
&emsp; &emsp; |  (rec ((var _expr_)) _expr_) <br>
&emsp; &emsp; |  (seq _expr_ _expr_) <br>
&emsp; &emsp; |  (set var _expr_) <br>
&emsp; &emsp; |  (box _expr_) <br>
&emsp; &emsp; |  (unbox _expr_) <br>
&emsp; &emsp; |  (setbox _expr_ _expr_) <br>
