# An-intepreter-for-Faux-Racket-W23-CS-146

## The interpreter and Faux Racket
The interpreter was done as assignment questions of CS 146, W23 offering, instructed by Brad Lushman, at the University of Waterloo. Relevant assignments are [Q5: Recursion], [Q6: Mutation], [Q7: Boxes].
<br>
<br>
For simplicity, the interpreter was implemented in Racket, and aiming at interpreting a tiny subset of the programming language Racket, we will refer to this language as "Faux Racket".

---

## Abstract Syntax Tree of Faux Racket
The Abstract Syntax Tree (presented in Haskell grammar) for Faux Racket below is provided by CS 146 instructor team on assignment page.               <br> <br>
_expr_ =  num                                                                                                                                              <br>
&emsp; &emsp; |  var                                                                                                                                       <br>
&emsp; &emsp; |  (+ _expr_ _expr_)                                                                                                                         <br>
&emsp; &emsp; |  (* _expr_ _expr_)                                                                                                                         <br>
&emsp; &emsp; |  (- _expr_ _expr_)                                                                                                                         <br>
&emsp; &emsp; |  (/ _expr_ _expr_)                                                                                                                         <br>
&emsp; &emsp; |  (fun (var) _expr_)            &emsp; &emsp; &emsp; &emsp; ```fun``` resembles ```lambda``` in Racket to avoid the use of keyword "lambda" <br>
&emsp; &emsp; |  (_expr_ _expr_)                                                                                                                           <br>
&emsp; &emsp; |  (ifzero _expr_ _expr_ _expr_) &emsp; &ensp; ```ifzero``` is a simplified version of ```if``` in Racket                                    <br> 
&emsp; &emsp; |  (with ((var _expr_)) _expr_)  &emsp; &nbsp;  ```with``` resembles ```let``` in Racket                                                     <br>  
&emsp; &emsp; |  (rec ((var _expr_)) _expr_)   &emsp; &ensp; &nbsp; ```rec``` resembles ```letrec``` in Racket                                             <br>
&emsp; &emsp; |  (seq _expr_ _expr_)           &emsp; &emsp; &emsp; &emsp; ```seq``` is a simplified version of [```begin```](https://docs.racket-lang.org/reference/begin.html) in Racket <br>
&emsp; &emsp; |  (set var _expr_)              &emsp; &emsp; &emsp; &emsp; &ensp; ```set```is a simplified version of [```set!```](https://docs.racket-lang.org/reference/set_.html) in Racket <br>
&emsp; &emsp; |  (box _expr_)                  &emsp; &emsp; &emsp; &emsp; &emsp; &ensp; [```box```](https://docs.racket-lang.org/reference/boxes.html) is the same as in Racket <br>
&emsp; &emsp; |  (unbox _expr_)                &emsp; &emsp; &emsp; &emsp; &ensp;[ ```unbox```](https://docs.racket-lang.org/reference/boxes.html) is the same as in Racket <br>
&emsp; &emsp; |  (setbox _expr_ _expr_)        &emsp; &emsp; &ensp; ```setbox``` resembles [```set-box!```](https://docs.racket-lang.org/reference/boxes.html) in Racket <br>
