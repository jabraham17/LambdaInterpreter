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
my $id = $id_start.'|'.$digit;
my $op = '[\+\-\*\/%=&\|<>!]';
my $punc = '[,;\(\){}\[\]]';

#read from the in stream until the regex is false
sub read_while {
    my ($regex) = @_;
    my $str = '';
    while (!$self->{instr}->eof and $self->{instr}->peek =~ /$regex/) {
        $str .= $self->{instr}->next;
    }
    return $str;
}

#read a str
sub read_string() {
    #if a char is escaped, such as a quote, we dont want it ending the loop early
    my $escaped = 0;
    my $str = '';
    my $end = "\"";
    
    #discard the inital char
    $self->{instr}->next();
    while(!$self->{instr}->eof) {
        my $ch = $self->{instr}->next;
        if($escaped) {
            $str .= $ch;
            $escaped = 0;
        }
        elsif($ch eq '\\') {
            $escaped = 1;
        }
        elsif($ch eq $end) {
            last;
        }
        else {
            $str .= $ch;
        }
    }
    return new Token("str", $str);
}

#read a number
sub read_number {
    my $num = read_while($digit.'|\.');
    return new Token("num", $num);
}

# read an identifier
sub read_id() {
    my $identifier = read_while($id);
    # check if the identifer is a keyword, if it is mark it as such
    return new Token($identifier =~ /$keyword/ ? "kw" : "var", $identifier);
}

#return the next token
sub read_next() {
    #read extra whitespace and discard it
    &read_while($whitespace);
    #return undef if end of file
    if($self->{instr}->eof) {return undef;}
    #peek the next char, used to determine what to do
    my $ch = $self->{instr}->peek;

    #if its a comment, skip the comment and try again
    if($ch eq "#") {
        &read_while('[^\n]');
        return &read_next;
    }
    #if its a string, read the string
    if($ch eq '"') {
        return &read_string;
    }
    # if its a number, read the number
    if($ch =~ /$digit/) {
        return &read_number;
    }

    if($ch =~ /$id_start/) {
        return &read_id;
    }
    # if its punctuation, wrap it in token and return it
    if($ch =~ /$punc/) {
        return new Token("punc", $self->{instr}->next);
    }
    # if its an operator, read the while operator and return it
    if($ch =~ /$op/) {
        return new Token("op", &read_while($op));
    }
    die $self->{instr}->error("Can't handle character: $ch");
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