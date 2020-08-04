(include (car (cdr (command-line))))
(let( [wrapper&args (cdr (command-line))] )
  (let( [wrapper (car wrapper&args)]
	[args (cdr wrapper&args)] )
    (load (car args))
    (apply main-proc args)
    ))
