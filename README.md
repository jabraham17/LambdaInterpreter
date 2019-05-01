# Lambda Interpreter

This is a syntax parser written in Perl for a simple lambda based programming language.

## Running

This was devloped using Perl v5.18.2. This is the recommended version of Perl to use.
To check if syntax is valid run the following shell command `perl input.pl <file>`.
A sample program is provided [here][3]. 
If the syntax is valid, the corresponding Abstract Syntax Tree will be printed in valid JSON. This JSON can be put in a JSON viewer such as [this][2] to view the programs syntax in a graphical structure.


## Acknolwdlements

This project is based upon [this][1] tutorial.


[1]: http://lisperator.net/pltut/
[2]: http://jsonviewer.stack.hu/
[3]: https://github.com/jacob-abraham/LambdaInterpreter/blob/master/myprogram.l
