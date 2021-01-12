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
: Boolean defauls toFalse, when true and option is not given aften argument parsing a X::GP::MissedOption Exception should be thrown.

help
: A text describing the option.

dest
: The key name of the option the argumet parser should return, defaults to the long option name.

meta
: A word describing the argument of an option, eg. <file>.

#### Methods
value()
: Returns value of option, should be defined by derived class.

set(Str <argument>)
set()
: Set the option value, return true when <argument> is used and false when not. These method must be defined by the option object, if called in base an exception will be thrown.

gengist()
: Returns string of internals to use it in gist() method.

result()
: Returns pair of dest as key and the value of the option.

optstr()
: Returns optchar and optlong as string, for the use in help messages.

reset()
: this function must be defined by the option object and shall reset the option value to its default.

value()
: this function must return the options argument and must be defined by option object.

### Getopt::ArgParse::Option::Boolean
A boolean option does not need an argument, but here are the arguments yes, no, true, false allowed to set a boolean value.
Without a argument, the current value will be toggled.

#### Attributes
default
: set initial boolean value

#### Methods
set()
set(Bool)
set(Str [yes|no|true|false])
: set or toggle value

### Getopt::ArgParse::Option::String

#### Attributes
verify
: A regex to verify the option argument, if it is defined and verify does not match a exception X::GP::Value will be thrown.

#### Methods
set(Str)
: set the value, returns True.

value()
: returns the option value.

reset()
: reset to default.

### Getopt::ArgParse::Option::Number
Manage a option with an integer argument.

#### Attributes
default
: the default value

min
: when defined, the minimal value of argument

max
: when defined, the maximal value of argument

#### Methods
et(Str)
: set value, throws an exception if parameter isn't a number.

set(Int)
: set value, throws an exception if parameter isn't between defined min max.

### Getopt::ArgParse::Option::Float
Manage a option with an floating point argument.

#### Attributes
default
: the default value

min
: when defined, the minimal value of argument

max
: when defined, the maximal value of argument

#### Methods
set(Str)
: set value, throws an exception if parameter isn't a number.

set(Float)
: set value, throws an exception if parameter isn't between defined min max.

### Getopt::ArgParse::Option::Rational
An option with an rational argument.

#### Attributes
default
: the default value

min
: when defined, the minimal value of argument

max
: when defined, the maximal value of argument

#### Methods

### Getopt::ArgParse::Option::Count
Counts the amount of occurrence of the option, eg. -vvv results in 3.

#### Attributes
default
: The initial value of the counter.

max
: When defined, it throws exception when value >= maximum.

#### Methods
set(Int)
: set the counter to given parameter.

=defn set(Str)
when a integer is given as argument, the value will be set to it, otherwise the counter will be increased.

=defn set()
increase the counter.

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





