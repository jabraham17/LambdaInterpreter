#!/usr/bin/perl

#struct to hold tokens
#each token has a type and a value
package Token;

#constructor, requires a valid InputStream
sub new {
    my $class = shift;
    $self = {
        type => shift,
        value => shift
    };
    bless $self, $class;
    return $self;
}

#getters and setters
sub get_type {
    return $self->{type};
}
sub get_value {
    return $self->{value};
}
sub set_type {
    $self->{type} = shift;
}
sub set_value {
    $self->{value} = shift;
}

#convert this token to a string represenattion
sub str {
    return "{type:".$self->{type}.",value:".$self->{value}."}";
}

1;