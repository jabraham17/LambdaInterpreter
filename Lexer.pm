#!/usr/bin/perl

use Token;

#turn a stream of chars into a stream of tokens
package Lexer;

#constructor, requires a valid InputStream
sub new {
    my $class = shift;
    $self = {
        instr => shift,
        current => undef
    };
    bless $self, $class;
    return $self;
}

#define my regexs
my $keyword = ' (if|then|else|lambda|true|false) ';
my $whitespace = '\s';
my $digit = '[0-9]';
my $id_start = '[a-zA-Z_]';
my $id = $start.'|'.$digit;
my $op = '+-*/%=&|<>!';
my $punc = ',;(){}[]';

#read from the in stream until the regex is false
sub read_while {
    my ($regex) = @_;
    my $str = '';
    while (!$self->{instr}->eof and $self->{instr}->peek =~ /$regex/) {
        $str .= $self->{instr}->next;
    }
    return $str;
}

#read a number
sub read_number {
    my $num = read_while($digit.'|\.');
    return new Token("num", $num);
}

#return the next token
sub read_next() {
    #read extra whitespace and discard it
    &read_while($whitespace);
    #return undef if end of file
    if ($self->{instr}->eof) {return undef;}
    #peek the next char, used to determine what to do
    my $ch = $self->{instr}->peek;

    #if its a comment, skip the comment and try again
    if($ch eq "#") {
        &read_while('[^\n]');
        return &read_next;
    }
    # if its a number, read the number
    if($ch =~ /$digit/) {
        return &read_number;
    }
}

#peek the next token
sub peek {
    #if no current token, get the current token
    if (!defined $self->{current}) {
        $self->{current} = &read_next
    }
    #return the current token
    return $self->{current};
}
#get the next token
sub next {
    #put the current token in a temp var
    my $token = $self->{current};
    $self->{current} = undef;
    #if there was no current token, need to get the next token
    if (!defined $token) {
        $token = &read_next;
    }
    return $token;
}
#check for the end of the file
sub eof {
    return !defined &peek;
}

1;