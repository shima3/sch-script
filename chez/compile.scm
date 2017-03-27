;; (display (command-line-arguments))
(define (find-last-char ch str)
  (let loop ((i (- (string-length str) 1)))
    (if (or (< i 0)(char=? (string-ref str i) ch))
	i
	(loop (- i 1)))))
(define (basename filename)
  (let ((i (find-last-char #\. filename)))
    (if (< i 0) filename (substring filename 0 i))))
(let ((src (car (command-line-arguments)))
      (dst (car (cdr (command-line-arguments)))))
  (parameterize
   ([optimize-level 3])
   (compile-script src dst)))