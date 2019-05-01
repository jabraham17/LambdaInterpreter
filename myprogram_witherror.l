println("Hello World");

println(2 + 3 * 4);

# I am a comment

fib = lambda (n) if n < 2 then n else fib(n - 1) + fib(n - 2);

println(fib(15))

printrange = lambda(a, b)
                if a <= b then { 
                  print(a);
                  temp = a + 1;
                  if temp <= b then {
                    print(", ");
                    print-range(a + 1, b);
                  } else println("");
                };
printrange(1, 5);
