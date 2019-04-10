# this is a comment
#another comment

a = a <= b;

b = true;
d = false;

c = d - 2 * 4;

test = lambda(x) if x < 2 then x;

println("Hello World");

println(2 + 3 * 4);

# functions are introduced with `lambda`
fib = lambda (n) if n < 2 then n else fib(n - 1) + fib(n - 2);

println(fib(15));

printrange = lambda(a, b)             # `λ` is synonym to `lambda`
                if a <= b then {  # `then` here is optional as you can see below
                  print(a);
                  temp = a + 1;
                  if temp <= b then {
                    print(", ");
                    print-range(a + 1, b);
                  } else println("");        # newline
                };
printrange(1, 5);