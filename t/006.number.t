use Test;

use Getopt::ArgParse::Option::Number;

plan 19;
my $op=Getopt::ArgParse::Option::Number.new();
ok $op.defined, 'opt number defined';
is $op.required, Bool::False, 'option is required';
nok $op.value().defined, 'value is set';
nok $op.max.defined, 'max must be undefined';
nok $op.min.defined, 'max must be undefined';
throws-like( { $op.result(); },
             X::GP::NoName,
             message => ' Option has no dest name!');

#done-testing; exit;

$op=Getopt::ArgParse::Option::Number.new(
    min     =>10,
    max     =>30,
    value   =>16,
    optchar =>'n',
    optlong =>'set-number',
    help    =>'number option',
    dest    =>'thenumber',
    meta    =>'<number>'
);

ok $op.defined, 'opt string defined';
is $op.required, Bool::False, 'option is required';
ok $op.value().defined, 'value is set';
is $op.value(), 16, 'value preset';
ok $op.set(20), 'set value';
is $op.value(), 20, 'value 20';
ok $op.set('18'), 'set value';

my $res= $op.result();
#say $res;
is $res.key, 'thenumber', 'result key';
is $res.value, 18, 'result value';

throws-like( { $op.set(5); },
             X::GP::Value,
             message => '5 is lower than 10');
throws-like( { $op.set(50); },
             X::GP::Value,
             message => '50 is greater than 30');
throws-like( { $op.set('bla'); },
             X::GP::Value,
             message => 'bla is not a number');

#say $op;
like $op.gist, /value.+18/, 'gist value';
done-testing;
