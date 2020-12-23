use Test;

use Getopt::ArgParse::Option::File;

constant $NotWriteable = q{/etc/passwd};
constant $NotExistant = q{non-existing-file.üöä};

plan 25;
# check new without parameters
my $op=Getopt::ArgParse::Option::File.new();
ok $op.defined, 'opt file defined';
is $op.required, Bool::False, 'is not required';
nok $op.value().defined, 'initial value';
nok $op.optchar.defined, 'optchar shall not defined';
nok $op.optlong.defined, 'optlong shall not defined';
is $op.meta, '<file>', q{default meta};

throws-like( { $op.result(); },
             X::GP::NoName,
             message =>' Option has no dest name!');

# check readable file
$op=Getopt::ArgParse::Option::File.new(
        optchar=>'f',
        optlong=>'file',
        help=>'file option',
        meta=>'<bla>');

ok $op.defined, 'opt bool defined';
is $op.required, Bool::False, 'is not required';
is $op.optchar, 'f', 'short option';
is $op.optlong, 'file', 'long option';
is $op.meta, '<bla>', q{preset meta};
nok $op.value().defined, 'initial value';
ok $op.set($*PROGRAM-NAME), 'set() to' ~ $*PROGRAM-NAME;
is $op.value().dirname, 't', 'dirname';
is $op.value().basename, $*PROGRAM-NAME.IO.basename, 'basename';

#say $op.result();
my $res = $op.result();
is $res.key, 'file', 'result key';
is $res.value.basename, $*PROGRAM-NAME.IO.basename, 'result value';

throws-like( { $op.set(IO::Path.new($op.value()
        .dirname).add($NotExistant).path); },
    X::GP::Value,
    message => q{-f | --file t/non-existing-file.üöä is not readable!});

# check file to write
$op=Getopt::ArgParse::Option::File.new(
        optchar=>'f',
        optlong=>'file',
        help=>'file option',
        write=>True,
        meta=>'<writeto>');

ok $op.set($*PROGRAM-NAME), 'script shall be writeable';
ok $NotWriteable.IO ~~ :e && $NotWriteable.IO !~~ :w,
    $NotWriteable ~ q{ this file should not writeable}; 

throws-like( { $op.set($NotWriteable); },
    X::GP::Value,
    message => q{-f | --file /etc/passwd is not writeable!});

# check new flag: file must not exist and directory must be writeable
$op=Getopt::ArgParse::Option::File.new(
        optchar=>'f',
        optlong=>'file',
        help=>'file option',
        new=>True,
        meta=>'<new>');

ok $op.set($NotExistant), 'new file is current directory';
#$op.set(IO::Path.new($NotWriteable.IO.dirname).add($NotExistant).path);
throws-like( 
    {$op.set(IO::Path.new($NotWriteable.IO.dirname).add($NotExistant).path);},
    X::GP::Value,
    message => q{-f | --file /etc/non-existing-file.üöä directory isn't writeable!}); #'

#say $op;
like $op.gist, 
    /Option \s* Type .* File .* value .* non\-existing\-file.üöä/, 
    'result of gist';

done-testing;
