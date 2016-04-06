(define null. (lambda (x) (eqv? x '())))
(define list. (lambda (x) (cond((null. x) '())('t(cons(car x)(list. (cdr x)))))))
(define append. (lambda (x) (cond((null. (car x)) (cadr x))('t(cons(caar x)(append. (cons (cdar x)(cdr x))))))))
(append. '(() (a)))
