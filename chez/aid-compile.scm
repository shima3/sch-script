(include "chez/prologue.scm")
(let ((args (command-line-arguments)))
  (let ((src (car args))
	 (dst (car (cdr args))))
    (parameterize
      ([optimize-level 3])
      (compile-script src dst))))
