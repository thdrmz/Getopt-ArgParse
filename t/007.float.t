use Test;

use Getopt::ArgParse::Option::Float;

plan 22;
my $op=Getopt::ArgParse::Option::Float.new();
ok $op.defined, 'opt float defined';
is $op.required, Bool::False, 'option is required';
nok $op.value().defined, 'value is set';
nok $op.max.defined, 'max must be undefined';
nok $op.min.defined, 'max must be undefined';
throws-like( { $op.result(); },
             X::GP::NoName,
             message => ' Option has no dest name!');

#done-testing; exit;

$op=Getopt::ArgParse::Option::Float.new(
    min     =>5.5,
    max     =>11.5,
    default =>10.75,
    optchar =>'n',
    optlong =>'set-real',
    help    =>'float option',
    dest    =>'thefloat',
    meta    =>'<float>'
);

ok $op.defined, 'opt float defined';
is $op.required, Bool::False, 'option is required';
ok $op.value().defined, 'value is set';
ok $op.max.defined, 'max defined';
ok $op.min.defined, 'max defined';
is $op.value(), 10.75, 'value preset';
ok $op.set(5.6), 'set value';
is $op.value, 5.6, 'set value';
ok $op.set('6.7'), 'set value';

my $res= $op.result();
#say $res;
is $res.key, 'thefloat', 'result key';
is $res.value, 6.7, 'result value';

throws-like( { $op.set(5); },
             X::GP::Value,
             message => '5 is lower than 5.5');
throws-like( { $op.set(50); },
             X::GP::Value,
             message => '50 is greater than 11.5');
throws-like( { $op.set('bla'); },
             X::GP::Value,
             message => 'bla is not a real');

#say $op;
like $op.gist, /value .+ 6.7/, 'gist value';

$op.reset();
is $op.value, 10.75, 'reset to default';

done-testing;
