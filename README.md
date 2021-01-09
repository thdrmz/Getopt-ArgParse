# Getopt-ArgParse

perl6 / raku Library to parse command line arguments.

I'd like to parse the command line in a oo style, so create the parser object and
add the option objects. The parser accepts short options prepend by a single dash, followed by characters, 
when there are multiple characters
As result of parse() you get the Hash of options and the argv() method gives the remaing arguments.

When an error occurs while parsing, an exception will be thrown.

Synopsis
--------

    my $go=Getopt::ArgParse(
        descr=>'program description', 
        epilog=>'text below help');

    my $op=Getopt::ArgParse::Option::String(
        optchar=>'s',
        optlong=>'string',
        default=>'default',
        verify=>rx{^ <alpha>+ $},
        dest=>'destinationKey'
    );
    $go.add($op);
    %options = $go.parse();
    @arguments = $go.argv();

Getopt::ArgParse.new()
======================
At object creation, a boolean option (--help) will be created. 
When help option is set, the parser prints the description and exits.

## Attributes
prog
: The name of the program, defaults to $*PROGRAM-NAME.

descr
: Description of the program.

epilog
: Text below option list.

## Parser methods
add(<obj>)
: add an option object 

parse()
: when called without argument, the program arguments @*ARGS will be parsed

parse(Str <cmd>)
: The String <cmd> will be splitted like bash do.

parse(Array @ar)
: parse list of arguments. 

argv()
: return remaining arguments after parsing

## Option Objects

### Base
The base of all option objects

#### Attributes
optchar
: A single charakter, used with a single dash in options.

optlong
: A word starting with an <alpha> followed by <alphanum> and the charakters - and. This word will be used at options starting with double dash '--'.

required
: Boolean defauls to Bool::False, when true and option is not given aften argument parsing a X::GP::MissedOption Exception should be thrown.

help
: A text describing the option.

dest
: The key name of the option the argumet parser should return, defaults to the long option name.

meta
: A word describing the value of an option, eg. <file>.

#### Methods
value()
: Returns value of option, should be defined by derived class.

set(Str <argument>)
set()
: Set the option value, return true when <argument> is used and false when not.

gengist()
: Returns string of internals to use it in gist() method.

result()
: Returns pair of dest as key and the value of the option.

optstr()
: Returns optchar and optlong as string, for the use in help messages.

### Getopt::ArgParse::Option::Boolean

#### Attributes

#### Methods

### Getopt::ArgParse::Option::String

#### Attributes

#### Methods

### Getopt::ArgParse::Option::Number

#### Attributes

#### Methods

### Getopt::ArgParse::Option::Float

#### Attributes

#### Methods

### Getopt::ArgParse::Option::Rational

#### Attributes

#### Methods

### Getopt::ArgParse::Option::Count

#### Attributes

#### Methods

### Getopt::ArgParse::Option::Array

#### Attributes

#### Methods

### Getopt::ArgParse::Option::Choices

#### Attributes

#### Methods

### Getopt::ArgParse::Option::Pairs

#### Attributes

#### Methods

### Getopt::ArgParse::Option::File

#### Attributes

#### Methods





