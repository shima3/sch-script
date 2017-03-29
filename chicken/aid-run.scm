;; (display (command-line-arguments))(newline)
(let ((args (command-line-arguments)))
  (load (car args))
  (apply main-proc args))
