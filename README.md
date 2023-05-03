# An intepreter for Faux Racket, W23 ,CS 146

## The interpreter and Faux Racket
This interpreter was done as three consecutive assignment questions of CS 146, W23 offering, instructed by Brad Lushman, at the University of Waterloo. Relevant assignments are [Q5: Recursion](https://github.com/hg2006/An-intepreter-for-Faux-Racket-W23-CS-146/issues/1#issue-1687567584), [Q6: Mutation](https://github.com/hg2006/An-intepreter-for-Faux-Racket-W23-CS-146/issues/2#issue-1687569446), [Q7: Boxes](https://github.com/hg2006/An-intepreter-for-Faux-Racket-W23-CS-146/issues/3#issue-1687569608).
<br>
<br>
For simplicity, the interpreter was implemented in Racket, and aiming at interpreting a small subset of Racket itself, we will refer to this subset of Racket as __"Faux Racket"__.
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
Note there could happen to be (2 1), we will let it become a runtime error.
<br>
&emsp; &emsp; |  (fun (var) _expr_)             <br>
```fun``` resembles [```lambda```](https://docs.racket-lang.org/guide/lambda.html) in Racket to avoid the use of keyword "lambda". <br>            
&emsp; &emsp; |  (ifzero _expr_ _expr_ _expr_) <br>
```ifzero``` is a simplified version of [```if```](https://docs.racket-lang.org/reference/if.html) in Racket. __If the first expr is evaluated to 0, the second expr will be evaluated, or else the third will be evaluated__.     <br>                               
&emsp; &emsp; |  (with ((var _expr_)) _expr_)  <br>
```with``` resembles [```let```](https://docs.racket-lang.org/reference/let.html) in Racket. Note the syntax of __double brackets__.                     <br>                              
&emsp; &emsp; |  (rec ((var _expr_)) _expr_)   <br>
```rec``` resembles [```letrec```](https://docs.racket-lang.org/reference/let.html) in Racket.                      <br>                    
&emsp; &emsp; |  (seq _expr_ _expr_)           <br>
```seq``` is a simplified version of [```begin```](https://docs.racket-lang.org/reference/begin.html) in Racket. __Note unlike begin, seq only allows sequencing of two expressions__. <br> <br>
&emsp; &emsp; |  (set var _expr_)             <br>
```set```is a simplified version of [```set!```](https://docs.racket-lang.org/reference/set_.html) in Racket. <br> <br>
&emsp; &emsp; |  (box _expr_)                  <br>
[```box```](https://docs.racket-lang.org/reference/boxes.html) is the same as in Racket. <br> <br>
&emsp; &emsp; |  (unbox _expr_)               <br>
[ ```unbox```](https://docs.racket-lang.org/reference/boxes.html) is the same as in Racket. <br> <br>
&emsp; &emsp; |  (setbox _expr_ _expr_)        <br>
```setbox``` resembles [```set-box!```](https://docs.racket-lang.org/reference/boxes.html) in Racket. <br> <br> <br>

---

## Environment and Store
This interpreter uses two layers of mapping, with the environment mapping a variable name to its memory location in the store, and the store being the place where the values are stored (it can thus be viewed as mapping address to values). This model is a good reflection of how actual Racket is implemented by lower level languages. We will discuss below about the logistics of this model. <br>
### Env
If we have narrowed the range of the interpreter a bit more (although the subset of Racket chosen is already small enough), the store would've been unnecessary. Making the environment mapping a variable name directly to its value can perfectly handle everything except for possible aliasing brought by the boxes. Referencing a variable can be easily implemented by a lookup function. On another note, ```set``` can simply change the mapping between the variable name and the corresponding. Apparently, there's no need for another layer of mapping at this stage. <br>
### Store
Consider the following:
```racket 
(with ((x (box 0))
      (with ((y x))
            (seq (setbox x 5)
                 (unbox y)))))
```
The code above should produce 5 when we unbox y, note there's aliasing between x and y here. This is not achievable with one layer of mapping since with that there's no way to link change in x to change in y. We will thus modify environment to map variables to their locations, this environment is not modified, and does not need to be returned (we do not need to worry about local binding when returning). Furthermore, we will have a store mapping locations to values, values are updated meanwhile locations are not. Aliasing can thus be achieved by mapping two variables to the same location. 

