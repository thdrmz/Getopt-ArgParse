use Test;

use Getopt::ArgParse;
use Data::Dump::Tree;
#plan 1;

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
    optchar=>q{d},
    optlong=>q{string},
);
$go.add($op);
$op=Getopt::ArgParse::Option::Number.new(
    optchar=>q{e},
    optlong=>q{number},
);
$go.add($op);
$op=Getopt::ArgParse::Option::Float.new(
    optchar=>q{f},
    optlong=>q{float},
);
$go.add($op);
$op=Getopt::ArgParse::Option::Rational.new(
    optchar=>q{g},
    optlong=>q{rat},
);
$go.add($op);
$op=Getopt::ArgParse::Option::Count.new(
    optchar=>q{i},
    optlong=>q{count},
);
$go.add($op);
$op=Getopt::ArgParse::Option::Array.new(
    optchar=>q{j},
    optlong=>q{array},
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

my Str $astr = q{-ab --string blablubtrrr -c yes --number=10 --float 12.3 --rat 3/4 -iii --array abc,def,jkl --choices dab -k ooo --count
--pairs nnn=123 -l zzz=321 --file } ~ $*PROGRAM-NAME ~ q{ arg1 arg2};

my %res = $go.parse($astr);

ok %res.defined, 'got result';
nok %res<help>, 'a bool';
ok %res<abool>, 'a bool';
ok %res<bbool>, 'b bool';
ok %res<cbool>, 'c bool';
is %res<string>, 'blablubtrrr', 'set string';
is %res<number>, 10, 'set number';
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
#say $go.prog;
done-testing;
