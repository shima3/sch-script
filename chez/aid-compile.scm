;; (include "chez/wrapper.scm")
(let ((args (command-line-arguments)))
  (let ((src (car args))
	 (dst (car (cdr args))))
    (parameterize
      ([optimize-level 3])
      (compile-file src dst))))
