#!/usr/bin/perl

use InputStream;
use Lexer;
use Token;
use feature qw\say\;
use Data::Dumper;

my $input = new InputStream(<STDIN>);

my $lexer = new Lexer($input);

while(!($lexer->eof)) {
    $check = $lexer->next;
    say $check->str;
}

