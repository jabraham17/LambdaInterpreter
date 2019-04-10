#!/usr/bin/perl

#base class for an AST node, all it has is a type
package ASTNode;

use Data::Dumper;

#constructor, the type is stored and the info is a hash of more elemtns
sub new {
    my $class = shift;
    $self = {
        type => shift,
        info => shift,
    };

    bless $self, $class;
    return $self;
}

#return a ASTNode object from a Token object
sub astFromToken {
    my ($token) = @_;
    my $ast = new ASTNode($token->get_type);
    $ast->setValue("value", $token->get_value);
    return $ast;
}


# set a value into the node
sub setValue {
    my ($self, $name, $value) = @_;
    $self->{info}{$name} = $value;

    return undef;
}

# get a value from the node
sub getValue {
    my ($self, $name) = @_;
    return $self->{info}{$name};
}

# print everything pretty
sub pretty_str {
    my ($self) = @_;

    my $pretty = "";
    my $indent = 0;

    # go through the chars
    foreach (split("", $self->str)) {

        # if open bracket or brace, increase indent and add newline
        if($_ eq '{' or $_ eq '[') {
            $pretty .= "$_\n";
            $indent++;
            $pretty .= "\t"x$indent;
        }
        # if comma, add newline
        elsif($_ eq ',') {
            $pretty .= ",\n"."\t"x$indent;
        }
        # if close bracket or brace, decrese indetn and add newline
        elsif($_ eq '}' or $_ eq ']') {
            $indent--;
            $pretty .= "\n"."\t"x$indent.$_;
        }
        # if its a colon, add a space
        elsif($_ eq ':') {
            $pretty .= $_." ";
        }
        # add char to buffer
        else {
            $pretty .= $_;
        }
    }

    return $pretty;
}

# retunr a sclar wrapped in quotes if apprioate
sub wrap_scalar {
    my ($scal) = @_;
    return "\"".$scal."\"";
}

# return a str of the node and all sub nodes
sub str {
    my ($self) = @_;

    # the items will all have a type
    my @items = ("\"type\":".&wrap_scalar($self->{type}));
    
    # get the str of each item and put it in a list
    while(my ($k, $v) = each(%{$self->{info}})) {
    #foreach $k (keys %{$self->{info}}) {
        my $new_item = "\"$k\":";
        my $ref_type = ref $v;

        #if its a list, resolve the list and put it there
        if($ref_type eq ref []) {
            $new_item.=&str_list(@{$v});
            #$new_item.=Dumper($v);
        }
        #if its a ASTNode, call its str func
        elsif($ref_type eq ref $self) { 
            $new_item.=$v->str;
        }
        #treat it as scalar
        else {
            $new_item.=&wrap_scalar($v);
        }

        push @items, $new_item;
    }

    # retunrn the str
    return "{".join(",", @items)."}";
}

# stringify and return a list
sub str_list {
    # the list of all items
    my @items = ();

    #get the str of each item and put it in a list
    foreach (@_) {
        my $ref_type = ref $_;

        #if its a list, resolve the list and put it there
        if($ref_type eq ref []) {
            push @items, &str_list(@{$_});
        }
        #if its a ASTNode, call its str func
        elsif($ref_type eq ref $self) {
            push @items, $_->str;
        }
        #treat it as scalar
        else {
            push @items, &wrap_scalar($_);
        }
    }

    # retunrn the str
    return "[".join(",", @items)."]";
}

1;