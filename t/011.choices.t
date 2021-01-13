use Test;

use Getopt::ArgParse::Option::Choices;

plan 30;
my $op=Getopt::ArgParse::Option::Choices.new();
ok $op.defined, 'opt Choice defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(), '', 'value preset';
throws-like( { $op.result(); },
             X::GP::NoName,
             message => ' Option has no dest name!');

$op=Getopt::ArgParse::Option::Choices.new(
    optchar =>'a',
    optlong =>'set-choice',
    choices =><abc dab rrr kkk ooo>,
    help    =>'choices option',
    dest    =>'choices',
    meta    =>'<choice>'
);

ok $op.defined, 'opt Choice defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(),
    {abc=>False,dab=>False,rrr=>False,kkk=>False,ooo=>False},
    'value empty';
is $op.set('abc'), True, 'set abc';
is $op.set('kkk'), True, 'set kkk';
ok $op.value(){'abc'}, 'abc == True';
nok $op.value(){'dab'}, 'dab == False';
ok $op.value(){'kkk'}, 'kkk == True';
nok $op.value(){'ooo'}, 'ooo == False';

my $res= $op.result();
#say $res;
is $res.key, 'choices', 'result key';
is $res.value, {abc => True, dab => False, kkk => True, ooo => False, rrr => False}, 'result value';

throws-like( { $op.set('bla'); },
             X::GP::Value,
             message => '"bla" is not a valid choice!');

throws-like( { $op.set('dAb'); },
             X::GP::Value,
             message => '"dAb" is not a valid choice!');


#say $op;
like $op.gist, /Choices/, 'gist value';

$op=Getopt::ArgParse::Option::Choices.new(
    optchar =>'a',
    optlong =>'set-choice',
    choices =><Abc Dab Rrr Kkk Ooo>,
    help    =>'choices option',
    dest    =>'choices',
    meta    =>'<choice>',
    case    =>False,
    multiple=>False,
    required=>True
);

ok $op.defined, 'opt Choice defined';
is $op.required, True, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(),
    {Abc => False, Dab => False, Kkk => False, Ooo => False, Rrr => False},
    'value empty';
is $op.set('dAb'), True, 'set Dab';
ok $op.value(){'Dab'}, 'dab == True';
nok $op.value(){'Kkk'}, 'kkk == False';

throws-like( { $op.set('kkk'); },
    X::GP::Value,
    message => '-a | --set-choice allows only one choice! (Dab,Kkk) selected');
ok $op.value(){'Kkk'}, 'kkk == True is false after throw';

$op.reset();
is $op.value(),
    {Abc => False, Dab => False, Kkk => False, Ooo => False, Rrr => False},
    'reset choices';
done-testing;
