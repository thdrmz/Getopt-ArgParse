# Getopt-ArgParse

perl6 / raku Library to parse command line arguments.

I'd like to parse the command line in a oo style, so create the parser object and
add the option objects. As result of parse() you get the Hash of options and the argv() method gives the remaing arguments.

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
: 
