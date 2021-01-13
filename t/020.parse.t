use Test;

use Getopt::ArgParse;
use Data::Dump::Tree;

plan 29;
my $go=Getopt::ArgParse.new(
        prog=>'program',
        descr=>'descr',
        epilog=>'epilog');

ok $go.defined, 'objekt created';
my $op=Getopt::ArgParse::Option::Boolean.new(
    optchar=>q{a},
    optlong=>q{abool}
);
$go.add($op);
$op=Getopt::ArgParse::Option::Boolean.new(
    optchar=>q{b},
    optlong=>q{bbool}
);
$go.add($op);
$op=Getopt::ArgParse::Option::Boolean.new(
    optchar=>q{c},
    optlong=>q{cbool}
);
$go.add($op);
$op=Getopt::ArgParse::Option::String.new(
    optchar =>q{d},
    optlong =>q{set-string},
    verify  =>rx:i{^ <[a .. z \h]>+ $}
);
$go.add($op);
$op=Getopt::ArgParse::Option::Number.new(
    optchar=>q{e},
    optlong=>q{the_number},
    min=>9,
    max=>15
);
$go.add($op);
$op=Getopt::ArgParse::Option::Float.new(
    optchar=>q{f},
    optlong=>q{float},
    min=>11.5,
    max=>13.5
);
$go.add($op);
$op=Getopt::ArgParse::Option::Rational.new(
    optchar=>q{g},
    optlong=>q{rat},
    min=>2/3,
    max=>4/5
);
$go.add($op);
$op=Getopt::ArgParse::Option::Count.new(
    optchar=>q{i},
    optlong=>q{count},
    max=>5
);
$go.add($op);
$op=Getopt::ArgParse::Option::Array.new(
    optchar=>q{j},
    optlong=>q{array},
    valid =>rx{^ <alpha>+ $},
    quantity=>4,
);
$go.add($op);
$op=Getopt::ArgParse::Option::Choices.new(
    optchar=>q{k},
    optlong=>q{choices},
    choices =><abc dab rrr kkk ooo>,  
);
$go.add($op);
$op=Getopt::ArgParse::Option::Pairs.new(
    optchar=>q{l},
    optlong=>q{pairs},
);
$go.add($op);
$op=Getopt::ArgParse::Option::File.new(
    optchar=>q{m},
    optlong=>q{file},
);
$go.add($op);

#ddt $go;
#$go.parse("--help");
#done-testing; exit;

my Str $astr = qq:to/END/;
        -ab 
        --set-string "bla blub trrr" 
        -c yes 
        --the_number=10 
        --float 12.3 
        --rat 3/4 
        -iii 
        --array abc,def,jkl 
        --choices dab 
        -k ooo 
        --count
        --pairs nnn=123 
        -l zzz=321 
        --file $*PROGRAM-NAME
        arg1 arg2
    END

my %res = $go.parse($astr);
my @arg= $go.argv;
ok %res.defined, 'got result';
nok %res<help>, 'a bool';
ok %res<abool>, 'a bool';
ok %res<bbool>, 'b bool';
ok %res<cbool>, 'c bool';
is %res<set-string>, 'bla blub trrr', 'set string';
is %res<the_number>, 10, 'set number';
is %res<float>, 12.3, 'set float';
is %res<rat>, 3/4, 'set rat';
is %res<count>, 4, 'set count';
is %res<choices><abc>, False, 'set <choices><abc>';
is %res<choices><dab>, True, 'set <choices><dab>';
is %res<choices><kkk>, False, 'set <choices><kkk>';
is %res<choices><ooo>, True, 'set <choices><ooo>';
is %res<choices><rrr>, False, 'set <choices><rrr>';
is %res<array>[0], 'abc', 'set <array>[0]';
is %res<array>[1], 'def', 'set <array>[1]';
is %res<array>[2], 'jkl', 'set <array>[2]';
is %res<pairs><nnn>, 123, 'set <pairs><nnn>';
is %res<pairs><zzz>, 321, 'set <pairs><zzz>';
is %res<file>.path, $*PROGRAM-NAME, 'set file';
is @arg[0], 'arg1', 'argument 1';
is @arg[1], 'arg2', 'argument 2';

# new parse, result should be the defaults + new option
$astr = qq:to/END/;
    --set-string "abc def"
END
%res=$go.parse($astr);
is %res,
    {abool => False, array => [], bbool => False, cbool => False, choices => {abc => False, dab => False, kkk => False, ooo => False, rrr => False}, count => 0, help => False, pairs => {}, set-string => 'abc def'},
    'new parse';

# force exception invalid opt arg
$astr = qq:to/END/;
    --set-string "abc 123"
END
throws-like( { $go.parse($astr); },
    X::GP::Value,
    message => q{abc 123 does not match on option -d | --set-string});

#force exeption when undefined option is called
$astr = qq:to/END/;
    --set-bla "abc"
END
throws-like( { $go.parse($astr); },
    X::GP::Parse,
    message => q{Option --set-bla does not exist!});

#force exeption when undefined option is called
$astr = qq:to/END/;
    -x "abc"
END
throws-like( { $go.parse($astr); },
    X::GP::Parse,
    message => q{Option -x does not exist!});

#force exeption when required option is not given
$op.required = True;
$astr = qq:to/END/;
    --set-string "abc"
END
throws-like( { $go.parse($astr); },
    X::GP::Parse,
    message => q{Option -m | --file is required!});

# check help
done-testing;
