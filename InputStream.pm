#!/usr/bin/perl

package InputStream;

#constructor, make input the slurped arguments
sub new {
    my $class = shift;
    $self = {
        input => join('', @_),
        pos => 0,
        line => 1,
        col => 0,
    };
    bless $self, $class;
    return $self;
}

#get the next char
sub next {
    my $next = &charat($self->{input}, $self->{pos}++);
    #update position
    if ($next eq "\n") {
        $self->{line}++;
        $self->{col} = 0;
    } 
    else {
        $self->{col}++;
    }
    return $next;
}
#get the peek char
sub peek {
    return &charat($self->{input}, $self->{pos});
}
#end of file is when peek returns undef
sub eof {
    return !defined peek;
}
#print an error message
sub error {
    my ($self, $msg) = @_;
    return $msg." (".$self->{line}.":".$self->{col}.")";
}

#define a charAt func
sub charat {
    my($str, $index) = @_;
    return substr($str, $index, 1);
}

1;