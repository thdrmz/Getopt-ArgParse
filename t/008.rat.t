use Test;

use Getopt::ArgParse::Option::Rational;

plan 20;

my $op=Getopt::ArgParse::Option::Rational.new();
ok $op.defined, 'opt rational defined';
is $op.required, Bool::False, 'option is not required';
nok $op.value().defined, 'value isnt set';
throws-like( { $op.result(); },
             X::GP::NoName,
             message => ' Option has no dest name!');

$op=Getopt::ArgParse::Option::Rational.new(
    min     =>1/9,
    max     =>10/3,
    default =>2/3,
    optchar =>'r',
    optlong =>'set-rat',
    help    =>'rat option',
    dest    =>'therat',
    meta    =>'<rational>'
);

ok $op.defined, 'opt rational defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(), 2/3, 'value preset';
ok $op.set(3/4), 'set value';
is $op.value, 3/4, 'value check';
ok $op.set('3.2'), 'set value';
is $op.value, 3.2, 'value check';
ok $op.set('5/3'), 'set value 5/3';

my $res= $op.result();
#say $res;
is $res.key, 'therat', 'result key';
is $res.value, 1.666667, 'result value';

throws-like( { $op.set(0.1); },
             X::GP::Value,
             message => '0.1 is lower than 0.111111');
throws-like( { $op.set(11/3); },
             X::GP::Value,
             message => '3.666667 is greater than 3.333333');
throws-like( { $op.set('bla'); },
             X::GP::Value,
             message => 'bla is not a rational');

#say $op;
like $op.gist, /value .+ 6.7/, 'gist value';

$op.reset();
is $op.value, 2/3, 'reset to default';
done-testing;
