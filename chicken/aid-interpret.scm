(include "chicken/wrapper.scm")
(let ((args (command-line-arguments)))
  (load (car args))
  (apply main-proc args))
