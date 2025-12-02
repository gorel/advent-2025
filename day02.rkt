#lang racket

(struct range (start end) #:transparent)

(define (is-invalid? n)
  (define s (number->string n))
  (define len (string-length s))
  (and (even? len)
       (let ([half (/ len 2)])
         (string=? (substring s 0 half)
                   (substring s half len)))))

(define (is-invalid-2? n)
  (let* ([s   (number->string n)]
         [len (string-length s)])
    ;; count from 1 to len/2 (call this K)
    ;; if the string representation of n is substring(0, K) repeated len/K times, then it's invalid
    (for/or ([k (in-range 1 (add1 (floor (/ len 2))))])
      ;; no remainder (we know that repeating substring will give us the same length)
      (and (= 0 (modulo len k))
           (let* ([sub      (substring s 0 k)]
                  ;; the more "idiomatic" way to build repeated string
                  [repeated (build-string
                               len
                               (lambda (i)
                                 (string-ref sub (modulo i k))))])
             ;; s is made up of sub repeated len/k times
             (string=? s repeated))))))

(define (sum-invalid-rng rng pred?)
  (for/sum ([x (in-range (range-start rng)
                         (add1 (range-end rng)))]
               #:when (pred? x))
    x))

(define (main)
  (define input-str (string-trim (port->string)))
  (define ranges
    (for/list ([chunk (string-split input-str "," #:trim? #t)])
        (match (string-split chunk "-" #:trim? #t)
          [(list lo hi)
          (range (string->number lo)
                  (string->number hi))]
          [_ (error "Invalid range syntax:" chunk)])))
  (define part1 (for/sum ([rng ranges]) (sum-invalid-rng rng is-invalid?)))
  (displayln part1)
  (define part2 (for/sum ([rng ranges]) (sum-invalid-rng rng is-invalid-2?)))
  (displayln part2))

(main)
