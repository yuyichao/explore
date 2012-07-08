;; elisp specific behavior?
'(a \, b)
(a \, b)

'(a , b)
(a (\, b))

'(1 , 3 4)
(1 (\, 3) 4)

`(a \, "aa")
(a . "aa")

;; same with clisp from here
`(a , "aa")
(a "aa")

(concat "a" "b" "cccd")
"abcccd"

(number-to-string (+ 2 3))
"5"

(car '(rose violet daisy buttercup))
rose

;; elisp's vector?
[1 3]
[1 3]

((lambda (n) (* n 2)) 10)
20

(cons 'a '(b c))
(a b c)
(length '(1 2 3))
3

(macroexpand '(quote (1 2 3)))
(quote (1 2 3))

((lambda (a b) (+ a b)) 1 2)
3
(setq add (lambda (a b) (+ a b)))
(lambda (a b) (+ a b))
(eval add)
(lambda (a b) (+ a b))
(eval `(,add 1 2))
3

(defmacro q (arg)
  `(quote ,arg))
q
(macroexpand '(q a))
(quote a)
(q a)
a
