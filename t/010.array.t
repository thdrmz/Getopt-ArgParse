use Test;

use Getopt::ArgParse::Option::Array;

plan 18;
my $op=Getopt::ArgParse::Option::Array.new();
ok $op.defined, 'opt Array defined';
is $op.required, Bool::False, 'option is not required';
is $op.elems, 0, 'zero elems';
ok $op.value().defined, 'value is set';
is $op.value(), '', 'value preset';
throws-like( { $op.result(); },
             X::GP::NoName,
             message => ' Option has no dest name!');

$op=Getopt::ArgParse::Option::Array.new(
    optchar =>'a',
    optlong =>'set-array',
    value   =>'xyz,uvw',
    valid =>rx{^ <alpha>+ $},
    quantity=>10,
    help    =>'array option',
    dest    =>'thearray',
    meta    =>'<elem>[,<elem>]'
);

ok $op.defined, 'opt Array defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(), 'xyz uvw', 'value preset';
is $op.elems, 2, 'amount of elems';
is $op.set('abc,def,hhh,ggg'), True, 'set value()';
is $op.set('ghi,jkl,mno'), True, 'set value()';

my $res= $op.result();
#say $res;
is $res.key, 'thearray', 'result key';
is $res.value, <xyz uvw abc def hhh ggg ghi jkl mno>, 'result value';

throws-like( { $op.set('b2r'); },
             X::GP::Value,
             message => 'b2r contains invalid elements');
$op.set("last");
throws-like( { $op.set('over'); },
             X::GP::Value,
             message => '"over" exceeds limit 10 elements');

#say $op;
like $op.gist, /last/, 'gist value';
done-testing;
