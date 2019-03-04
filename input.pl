#!/usr/bin/perl

use InputStream;
use feature qw\say\;

my $input = new InputStream(<STDIN>);

while(!($input->eof)) {
    print $input->next;
    print $input->error;
}
