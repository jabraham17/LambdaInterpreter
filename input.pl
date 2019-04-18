#!/usr/bin/perl

use InputStream;
use Lexer;
use Token;
use ASTNode;
use Parser;
use feature qw\say\;
use Data::Dumper;

my $parser = new Parser(new Lexer(new InputStream(<>)));

$ast = $parser->parse;

say $ast->pretty_str;

# while(!($lexer->eof)) {
#     say $lexer->next->str;
# }


# my @nodes = ();
# $ast1 = new ASTNode("prog");
# push @nodes, $ast1;

# $ast2 = new ASTNode("num");
# $ast2->setValue("value", 5);
# push @nodes, $ast2;

# $ast3 = new ASTNode("if");
# $ast3->setValue("cond", new ASTNode("var", {"value", "foo"}));
# $ast3->setValue("then", new ASTNode("var", {"value", "bar"}));
# push @nodes, $ast3;

# $ast4 = new ASTNode("lambda", {"vars" => ["x", "y"], "body" => $ast2});
# push @nodes, $ast4;

# $ast5 = new ASTNode("expr");
# $ast5->setValue("expressions", [$ast3, $ast4, ["B", "A"]]);
# push @nodes, $ast5;

# #say Dumper(@nodes);

# foreach (@nodes) {
#     say $_->pretty_str;
# }
