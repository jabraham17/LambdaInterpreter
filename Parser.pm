#!/usr/bin/perl

use ASTNode;

#turn a stream of tokens into an AST
package Parser;

use feature qw\say\;
use Data::Dumper;

#constructor, requires a valid Lexer
sub new {
    my $class = shift;
    $self = {
        lexer => shift,
    };
    bless $self, $class;
    return $self;
}

#define operator precendence
%op_precedence = (
    "=" => 1,
    "||" => 2,
    "&&" => 3,
    "<" => 7, ">" => 7, "<=" => 7, ">=" => 7, "==" => 7, "!=" => 7,
    "+" => 10, "-" => 10,
    "*" => 20, "/" => 20, "%" => 20,
);

# check if token is punction, keyword, or opertor
# we check if we have a valid token and a valid ch, then check if type and value are the same
sub is_kind {
    my ($kind, $ch) = @_;
    $token = $self->{lexer}->peek;

    #return token if true, otherwise 0
    return $token if defined $token and $token->get_type eq $kind and (!defined $ch or $token->get_value eq $ch);
    return 0;
}

#we use is_kind to skip the kind
sub skip_kind {
    my ($kind, $ch) = @_;

    # return it if ok
    return $self->{lexer}->next if is_kind($kind, $ch);

    #print "$kind $ch\n";

    #failure
    die &unexpected($self->{lexer}->peek)
    
}

# return a list surrounded by start and stop and seperated by seprator
# each item seperated is parsed by a callback func parser
sub delimited {
    my ($start, $stop, $separator, $parser) = @_;
    my @items = ();
    my $first = 1;


    # skip the start
    &skip_kind("punc", $start);
    while(!($self->{lexer}->eof)) {

        # if end, done
        last if &is_kind("punc", $stop);

        # if its the first item, no need to skip punctionation, otherwise need to skip punctutaion
        &skip_kind("punc", $separator) if --$first;

        last if &is_kind("punc", $stop);

        # add our parsed item to the list
        push @items, &$parser;

    }
    # now we skip the last punc
    &skip_kind("punc", $stop);

    # return our list
    return @items;
}

# parse the whole proram, basically just parse each expresssion
sub parse() {
    @prog = ();
    while(!($self->{lexer}->eof)) {
        # parse each expression and add them to the list
        push @prog, &parse_expression;
        #print $prog[-1]->pretty_str."\n";
        # every statment must end with the seprator
        &skip_kind("punc", ";");
    }
    return new ASTNode("prog", {"prog" => \@prog});
}

# parse a variable name
sub parse_varname {
    $name = $self->{lexer}->next;
    return $name->get_value if $name->get_type eq "var";

    #failed, die
    die &unexpected("Looking for variable");
}

# parse an if statment
sub parse_if() {
    # skip the keyword
    &skip_kind("kw", "if");

    # define our if node
    $ifnode = new ASTNode("if");
    # get the condition
    #print("Error1\n");
    $ifnode->setValue("cond", &parse_expression);

    #print($ifnode->getValue("cond")->pretty_str."\n");

    
    # then keyword is required, we just skip it
    &skip_kind("kw", "then");
    # get the then condition
    $ifnode->setValue("then", &parse_expression);
    
    # if else clause, parse it and add it to node
    if(&is_kind("kw", "else")) {
        &skip_kind("kw", "else");
        $ifnode->setValue("else", &parse_expression);
    }
    return $ifnode;
}

# parse a bool
sub parse_bool {
    return new ASTNode("bool", {"value", $self->{lexer}->next->get_value});
}

# parse a lambad expression
sub parse_lambda {
    #gonna need a fix
    return new ASTNode("lambda", {"vars", &delimited("(", ")", ",", \&parse_varname), "body", &parse_expression})
}

# main parsing dispatch done here
sub parse_atom {
    return &maybe_call(sub {

        #its an expressions, parse it skipping the aoprenthsis
        if(&is_kind("punc", "(")) {
            $self->{lexer}->next;
            my $expr = &parse_expression;
            skip_kind("kind", ")");
            return $expr;
        }
        # the follwoing are pretty self expanotry
        # note they dont eat the kw
        return &parse_prog if is_kind("punc", "{");
        # $self->{lexer}->peek->str."\n";
        return &parse_if if is_kind("kw", "if");
        return &parse_bool if is_kind("kw", "true") or is_kind("kw", "false");

        # this one does eat the keyword
        if(is_kind("kw", "lambda")) {
            $self->{lexer}->next;
            return &parse_lambda;
        }

        # if a var or constant is found, make an ast node from the token and return it
        my $token = $self->{lexer}->next;
        return ASTNode::astFromToken($token) if $token->get_type eq "var" or $token->get_type eq "num" or $token->get_type eq "str";
            
        # nothing found, unexpected token
        die &unexpected;
    });
}

# parse a sequence of expressions
# basically just call the delemited func for braces
sub parse_prog {
    return new ASTNode("prog", {"prog", &delimited("{", "}", ";", parse_expression)});
}

# parse an expression
sub parse_expression {
    return maybe_call(sub {
        return maybe_binary(&parse_atom, 0);
    });
}

# check if expression needs to be wrapped in a call
sub maybe_call {
    my ($callback) = @_;
    my $expr = &$callback;
    # if it needs to be wrapped, do so
    return is_kind("punc","(") ? parse_call($expr) : $expr;
}

#parse a fucntion call
sub parse_call {
    my ($func) = @_;

    #make an ast node
    my $ast = new ASTNode("call");
    $ast->setValue("func", $func);
    # parse the paramaters for the func call
    $ast->setValue("args", &delimited("(", ")", ",", \&parse_expression));

    return $ast;
}

# get a binary expression
# get next operators precendence
#if precnede of left is lower, parse the next atom in recursive definiton
sub maybe_binary {
    my ($left, $prec) = @_;

    my $token = &is_kind("op");

    if($token) {
        #get op precendence
        my $op_prec = $op_precedence{$token->get_value};
        if ($op_prec > $prec) {
            #print "T".$token->str."\n" if ref $token eq "Token";
            # throw away next 
            $self->{lexer}->next;
            # if assignment, mark as such
            my $ast = new ASTNode($token->get_value eq "=" ? "assign" : "binary");
            $ast->setValue("operator", $token->get_value);
            $ast->setValue("left", $left);
            $ast->setValue("right", &maybe_binary(&parse_atom, $op_prec));
            return $ast;
        }
    }
    return $left;
}


# throw an error if unexpected token found
sub unexpected {
    my ($token) = @_;
    return $self->{lexer}->error("Unexpected token: ".$token->str) if defined $token and ref $token eq Token;
    return $self->{lexer}->error("Unexpected token: $token");
}

1;