use Test;

use Getopt::ArgParse::Option::Pairs;
#say $op.^name;

plan 25;
my $op=Getopt::ArgParse::Option::Pairs.new();
ok $op.defined, 'opt Pairs defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(), '', 'value preset';
throws-like( { $op.result(); },
             X::GP::NoName,
             message => ' Option has no dest name!');

$op=Getopt::ArgParse::Option::Pairs.new(
    optchar =>'p',
    optlong =>'set-pairs',
    help    =>'pairs option',
    dest    =>'pairs',
    meta    =>'<key>=<value>',
    validkey=>rx:i{^ <alpha>+ $},
    validval=>rx{^ \d+ $}
);

ok $op.defined, 'opt pairs defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(),{},'value empty';
ok $op.set('abc=123'), 'set abc';
ok $op.set('kkk=333'), 'set kkk';
is $op.value(){'abc'}, 123, 'abc=123';
is $op.value(){'kkk'}, 333, 'kkk=333';

my $res= $op.result();
#say $res;
is $res.key, 'pairs', 'result key';
is $res.value, {abc => 123, kkk => 333}, 'result value';

throws-like( { $op.set('a1a=333'); },
    X::GP::Value,
    message => q{-p | --set-pairs invalid key a1a! (rx:i{^ <alpha>+ $})});

throws-like( { $op.set('aza=3a3'); },
    X::GP::Value,
    message => q{-p | --set-pairs invalid value 3a3! (rx{^ \d+ $})});

#say $op;
like $op.gist, /Pairs/, 'gist value';

$op=Getopt::ArgParse::Option::Pairs.new(
    optchar =>'p',
    optlong =>'set-pairs',
    help    =>'pairs option',
    dest    =>'pairs',
    meta    =>'<key>=<value>',
    validkey=>rx:i{^ <alpha>+ $},
    validval=>rx{^ \d+ $},
    multiple=>False
);

ok $op.defined, 'opt pairs defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(),{},'value empty';
ok $op.set('abc=123'), 'set abc';
is $op.value(){'abc'}, 123, 'abc=123';

throws-like( { $op.set('kkk=333'); },
    X::GP::Value,
    message => q{-p | --set-pairs only one pair allowed!});


done-testing;exit;
