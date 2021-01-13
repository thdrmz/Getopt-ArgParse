=begin pod

=TITLE Getopt::ArgParse

A class to parse cmd line options.

I'd like to parse the command line in a oo style, so create the parser object and
add the option objects. The parser accepts short options prepend by a single dash (-abe), followed by characters, when there are multiple characters 

As result of parse() you get the Hash of options and the argv() method gives the remaing arguments.

When an error occurs while parsing, an exception will be thrown.


=head2 Synopsis

=begin code
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

=end code

=head1 Getopt::ArgParse.new()

=defn prog
The name of the program, defaults to $*PROGRAM-NAME.

=defn descr
Description of the program.

=defn epilog
Text below option list.

=head2 Methods

=defn add(<Option>)
Add an option object to the parser.

=defn argv()
Return the list of remaining arguments after parsing.

=defn parse()
Parse @*ARGS

=defn parse(Str <cmd>)
The String <cmd> will be splitted like bash do.

=defn parse(@args)
Parse argument list returns a Hash, with options as pairs.


=head2 See also

=item Getopt::ArgParse::Option::Boolean;
=item Getopt::ArgParse::Option::String;
=item Getopt::ArgParse::Option::Number;
=item Getopt::ArgParse::Option::Float;
=item Getopt::ArgParse::Option::Rational;
=item Getopt::ArgParse::Option::Count;
=item Getopt::ArgParse::Option::Choices;
=item Getopt::ArgParse::Option::Array;
=item Getopt::ArgParse::Option::Pairs;
=item Getopt::ArgParse::Option::File;

=AUTHOR Thomas Drillich <th@drillich.com>

=end pod
#----------------------------------------
use Getopt::ArgParse::Option;
use Getopt::ArgParse::Exception;
#----------------------------------------
class Getopt::ArgParse is export {
    has Str $!prog = $*PROGRAM-NAME.IO.basename();
    has Str $!descr = 'program description';
    has Str $!epilog;
    has Bool $!isparsed = False;
    has @!opts;
    has %!optchar;
    has %!optlong;
    has @!argv;
    
    submethod TWEAK(Str :$prog, Str :$descr, Str :$epilog) {
        if $prog.defined { $!prog = $prog; }
        if $descr.defined { $!descr = $descr; }
        if $epilog.defined { $!epilog = $epilog; }
        my $op=Getopt::ArgParse::Option::Boolean.new(
            optlong=>'help',
            help=>'display this message');
        self.add($op);
    }
    multi method parse(--> Hash) {
        return self.parse(@*ARGS);
    }
    multi method parse(Str $astr --> Hash) {
        use Getopt::ArgParse::Str2Arg;
        return self.parse(str2args($astr));
    }
    multi method parse(@args is copy --> Hash) {
        self.reset() if $!isparsed;
        while (@args.elems > 0 && @args[0] ~~ rx{^ \-+}) {
            my $opt=@args.shift;
            if ( $opt ~~ rx{^ \- ** 2 (<alpha> <[\w \- \+]>+) \= (.*) $} ) {
                self.parselong($0.Str,$1.Str);
            } elsif ( $opt ~~ rx{^ \- ** 2 (<alpha> <[\w \- \+]>+) } ) {
                @args.shift
                    if self.parselong($0.Str, @args[0]) 
                    && @args.elems > 0;
            } elsif ( $opt ~~ rx{^ \- (<alpha>+) $} ) {
                my $opt=$0;
                for $opt.split('',:skip-empty) -> $c {
                    @args.shift
                        if self.parseshort($c, @args[0])
                        && @args.elems > 0;
                }
            } else {
                X::GP::Parse
                    .new(message=>qq{Option $opt does not exist!})
                    .throw;
            }
        }
        $!isparsed=True;
        @!argv=@args;
        my %res;
        for @!opts -> $opt {
            my $res = $opt.result;
            if $res.key.defined && $res.value.defined {
                %res{$res.key}=$res.value;
            } elsif $opt.required {
                X::GP::Parse
                    .new(message=>q{Option } 
                        ~ $opt.optstr 
                        ~ q{ is required!})
                    .throw;
            }
        }
        self.help, exit if %res<help>;
        return %res;
    }
    submethod parseshort(Str $opt, $arg --> Bool) {
        if %!optchar{$opt}:exists {
            if $arg === Any {
                return %!optchar{$opt}.set();
            }
            return %!optchar{$opt}.set($arg);
        }
        X::GP::Parse.new(message=>qq{Option -$opt does not exist!}).throw;
    }
    submethod parselong(Str $opt, $arg --> Bool) {
        if %!optlong{$opt}:exists {
            if $arg === Any {
                return %!optlong{$opt}.set();
            }
            return %!optlong{$opt}.set($arg);
        }
        X::GP::Parse.new(message=>qq{Option --$opt does not exist!}).throw;        
    }
    method argv() {
        if !$!isparsed {
            X::GP::Parse.new(message=>q{parse argv first!}).throw;
        }
        return @!argv;
    }    
    method add($opt) {
        if ($opt.optchar.defined && $opt.optchar ne '') {
            if %!optchar{$opt.optchar()}:exists {
                X::GP::Double.new(message=>self.optstr() 
                    ~ q{ is already defined!}).throw;
            }
            %!optchar{$opt.optchar}=$opt;
        }
        if ($opt.optlong.defined && $opt.optlong ne '') {
            if %!optlong{$opt.optlong()}:exists {
                X::GP::Double.new(message=>self.optstr() 
                    ~ q{ is already defined!}).throw;
            }
            %!optlong{$opt.optlong}=$opt;
        }
        @!opts.append($opt);
    }
    method help() {
        my %oo;
        say $!prog;
        if $!descr.defined { say "\t" ~ $!descr; }
        for @!opts -> $op {
            my $k = $op.optstr;
            if $op.meta.defined { $k~=' ' ~ $op.meta;}
            %oo{$k}=$op.help.defined ?? "\n\t\t" ~ $op.help !! '';
        }
        for %oo.keys.sort() -> $op {
            say "\t" ~ $op ~ %oo{$op};
        }
        if $!epilog.defined {
            say "\t" ~ $!epilog;
        }
    }
    submethod reset() {
        $!isparsed=False;
        for @!opts -> $op {
            $op.reset();
        }
    }
}
