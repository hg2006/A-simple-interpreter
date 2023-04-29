# An intepreter for Faux Racket, W23 ,CS 146

## The interpreter and Faux Racket
This interpreter was done as assignment questions of CS 146, W23 offering, instructed by Brad Lushman, at the University of Waterloo. Relevant assignments are [Q5: Recursion](https://github.com/hg2006/An-intepreter-for-Faux-Racket-W23-CS-146/issues/1#issue-1687567584), [Q6: Mutation](https://github.com/hg2006/An-intepreter-for-Faux-Racket-W23-CS-146/issues/2#issue-1687569446), [Q7: Boxes](https://github.com/hg2006/An-intepreter-for-Faux-Racket-W23-CS-146/issues/3#issue-1687569608).
<br>
<br>
For simplicity, the interpreter was implemented in Racket, and aiming at interpreting a tiny subset of the programming language Racket, we will refer to this language as "Faux Racket".
<br>
<br>
This interpreter __is not reponsible for error handling, user must ensure the Faux Racket progoram being interpreted is syntatically valid.__

---

## Abstract Syntax Tree of Faux Racket
The Abstract Syntax Tree (presented in Haskell grammar) for Faux Racket below is provided by CS 146 instructor team on assignment page.               <br> <br>
_expr_ =  num                                                                                                                                              <br><br>
&emsp; &emsp; |  var                                                                                                                                       <br><br>
&emsp; &emsp; |  (+ _expr_ _expr_)                                                                                                                         <br><br>
&emsp; &emsp; |  (* _expr_ _expr_)                                                                                                                         <br><br>
&emsp; &emsp; |  (- _expr_ _expr_)                                                                                                                         <br><br>
&emsp; &emsp; |  (/ _expr_ _expr_)                                                                                                                         <br><br>
&emsp; &emsp; |  (_expr_ _expr_)                <br>
Note there could happen to be (2 1), we will let it become a runtime error   
<br>
&emsp; &emsp; |  (fun (var) _expr_)             <br>
```fun``` resembles [```lambda```](https://docs.racket-lang.org/guide/lambda.html) in Racket to avoid the use of keyword "lambda" <br>            
&emsp; &emsp; |  (ifzero _expr_ _expr_ _expr_) <br>
```ifzero``` is a simplified version of [```if```](https://docs.racket-lang.org/reference/if.html) in Racket. __If the first expr is evaluated to 0, the second expr will be evaluated, or else the third will be evaluated__     <br>                               
&emsp; &emsp; |  (with ((var _expr_)) _expr_)  <br>
```with``` resembles [```let```](https://docs.racket-lang.org/reference/let.html) in Racket                      <br>                              
&emsp; &emsp; |  (rec ((var _expr_)) _expr_)   <br>
```rec``` resembles [```letrec```](https://docs.racket-lang.org/reference/let.html) in Racket                      <br>                    
&emsp; &emsp; |  (seq _expr_ _expr_)           <br>
```seq``` is a simplified version of [```begin```](https://docs.racket-lang.org/reference/begin.html) in Racket. __Note unlike begin, seq only allows sequencing of two expressions__ <br> <br>
&emsp; &emsp; |  (set var _expr_)             <br>
```set```is a simplified version of [```set!```](https://docs.racket-lang.org/reference/set_.html) in Racket <br> <br>
&emsp; &emsp; |  (box _expr_)                  <br>
[```box```](https://docs.racket-lang.org/reference/boxes.html) is the same as in Racket <br> <br>
&emsp; &emsp; |  (unbox _expr_)               <br>
[ ```unbox```](https://docs.racket-lang.org/reference/boxes.html) is the same as in Racket <br> <br>
&emsp; &emsp; |  (setbox _expr_ _expr_)        <br>
```setbox``` resembles [```set-box!```](https://docs.racket-lang.org/reference/boxes.html) in Racket <br> <br> <br>
