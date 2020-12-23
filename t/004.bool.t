use Test;

use Getopt::ArgParse::Option::Boolean;

plan 36;
my $op=Getopt::ArgParse::Option::Boolean.new();
ok $op.defined, 'opt bool defined';
is $op.required, Bool::False, 'is not required';
is $op.value(), Bool::False, 'initial value';
nok $op.optchar.defined, 'optchar shall not defined';
nok $op.optlong.defined, 'optlong shall not defined';

throws-like( { $op.result(); },
             X::GP::NoName,
             message =>' Option has no dest name!');

$op=Getopt::ArgParse::Option::Boolean.new(
        optchar=>'h',
        optlong=>'help',
        help=>'display this message');

ok $op.defined, 'opt bool defined';
is $op.required, Bool::False, 'is not required';
is $op.optchar, 'h', 'short option';
is $op.optlong, 'help', 'long option';
is $op.value(), False, 'initial value';
is $op.set(), True, 'set() should toggle bool';
is $op.value(), True, 'initial value';
is $op.set(False), True, 'set(Bool::False)';
is $op.set(True), True, 'set(Bool::True)';

is $op.set('False'), True, 'set by string False';
nok $op.value,'now False';
is $op.set('True'), True, 'set by string True';
ok $op.value, 'now True';
is $op.set('no'), True, 'set by string no';
nok $op.value,'now False';
is $op.set('yes'), True, 'set by string yes';
ok $op.value, 'now True';
is $op.set('nein'), True, 'set by string nein';
nok $op.value,'now False';
is $op.set('ja'), True, 'set by string ja';
ok $op.value, 'now True';
is $op.set('falsch'), True, 'set by string falsch';
nok $op.value,'now False';
is $op.set('wahr'), True, 'set by string wahr';
ok $op.value, 'now True';

my $res= $op.result();
is $res.key, 'help', 'result key';
is $res.value, Bool::True, 'result value';

#say Option::OptType.enums;
#say Option::BOOL, ' = ', Option::STRING;
#say $op.type();
nok $op.set("dummy"), 'wrong parameter';
nok $op.value, 'swapped to false';

#throws-like( { $op.set("dummy"); },
#             X::GP::Value,
#             message => "Invalid value dummy on boolean option");

#say $op;
like $op.gist, /value.+False/, 'result of gist';

done-testing;
