use Test;

use Getopt::ArgParse::Option::String;

plan 14;
my $op=Getopt::ArgParse::Option::String.new();
ok $op.defined, 'opt string defined';
is $op.required, Bool::False, 'option is not required';
nok $op.value().defined, 'value is not set';

throws-like( { $op.result(); },
             X::GP::NoName,
             message => ' Option has no dest name!');

#done-testing; exit;

$op=Getopt::ArgParse::Option::String.new(
    value   =>'blabla',
    verify  =>rx/^<alpha>+$/,
    optchar =>'s',
    optlong =>'set-string',
    help    =>'string option',
    dest    =>'thestring',
    meta    =>'<word>'
);

ok $op.defined, 'opt string defined';
is $op.required, Bool::False, 'option is not required';
ok $op.value().defined, 'value is set';
is $op.value(), 'blabla', 'value preset';
ok $op.set('blabum'), 'set value';

my $res= $op.result();
is $res.key, 'thestring', 'result key';
is $res.value, 'blabum', 'result value';

throws-like( { $op.set("ab0099"); },
             X::GP::Value,
             message => "ab0099 does not match");

like $op.gist, /verify.+/, 'gist verify';
like $op.gist, /value.+blabum/, 'gist value';

done-testing;
