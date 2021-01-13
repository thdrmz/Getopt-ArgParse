use Test;

use Getopt::ArgParse::Option::Count;

plan 22;
my $op=Getopt::ArgParse::Option::Count.new();
ok $op.defined, 'opt counter defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(), 0, 'value preset';
throws-like( { $op.result(); },
             X::GP::NoName,
             message => ' Option has no dest name!');

$op=Getopt::ArgParse::Option::Count.new(
    default =>6,
    max     =>10,
    optchar =>'c',
    optlong =>'set-count',
    help    =>'count option',
    dest    =>'thecount',
    meta    =>'<countstart>'
);

ok $op.defined, 'opt counter defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(), 6, 'value preset';
nok $op.set(), 'set';
is $op.value(), 7, 'value()';
nok $op.set(), 'set';
is $op.value(), 8, 'value()';
ok $op.set(9), 'set value 9';
nok $op.set('bla'), 'invalid set';
#done-testing; exit;

my $res= $op.result();
#say $res;
is $res.key, 'thecount', 'result key';
is $res.value, 10, 'result value';

throws-like( { $op.set(); },
             X::GP::Value,
             message => '10 exceeds 10');
throws-like( { $op.set(13); },
             X::GP::Value,
             message => '13 exceeds 10');

is $res.value, 10, 'result after exception';

#say $op;
like $op.gist, /Type .* Count/, 'gist value';

$op.reset;
is $op.value, 6, 'reset to default';
done-testing; exit;
