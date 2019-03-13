#!/usr/bin/perl

use InputStream;
use Lexer;
use Token;
use feature qw\say\;

my $input = new InputStream(<STDIN>);

# while(!($input->eof)) {
#     print $input->next.".";
# }

# $input->reset;

my $lexer = new Lexer($input);


my $token = $lexer->next->str;
print "|".$token."|\n";

