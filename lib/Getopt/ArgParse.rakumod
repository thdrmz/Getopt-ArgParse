=begin pod

=head1 Getopt::ArgParse

A class to parse cmd line options.

=head2 Synopsis

my $go=Getopt::ArgParse(
    descr=>'program description', 
    epilog=>'text beiow help');

my $op=Getopt::ArgParse::Option::String(
    optchar=>'s',
    optlong=>'string',
    value=>'default',
    verify=>rx{^ <alpha>+ $},
    dest=>'destinationKey'
);

$go.add($op);

%options = $go.parse();
@arguments = $go.argv();

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

=defn parse(@args)
Parse argument list returns a Hash, with options as pairs.

=defn parse(Str $cmd [, Regex $split])
Split a string into argument list using $split, 
which defaults to whitespace.

Todo: allow quoting with "" and ''.

=head2 See also

Getopt::ArgParse::Option::Boolean;
Getopt::ArgParse::Option::String;
Getopt::ArgParse::Option::Number;
Getopt::ArgParse::Option::Float;
Getopt::ArgParse::Option::Rational;
Getopt::ArgParse::Option::Count;
Getopt::ArgParse::Option::Choices;
Getopt::ArgParse::Option::Array;
Getopt::ArgParse::Option::Pairs;
Getopt::ArgParse::Option::File;

=end pod
#----------------------------------------
use Getopt::ArgParse::Option;
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
    multi method parse(Str $astr, Regex $sp = rx/\s+/ --> Hash) {
        return self.parse($astr.split($sp));
    }
    multi method parse(@args is copy --> Hash) {
        while (@args.elems > 0 && @args[0] ~~ rx{^ \-+}) {
            my $opt=@args.shift;
            if ( $opt ~~ rx{^ \- ** 2 (<alnum>+) \= (.*) $} ) {
                self.parselong($0.Str,$1.Str);
            } elsif ( $opt ~~ rx{^ \- ** 2 (<alnum>+) } ) {
                if self.parselong($0.Str, @args[0]) 
                    && @args.elems > 0 {
                    @args.shift;
                }
            } elsif ( $opt ~~ rx{^ \- (<alnum>+) $} ) {
                my $opt=$0;
                for $opt.split('',:skip-empty) -> $c {
                    if self.parseshort($c, @args[0])
                        && @args.elems > 0 {
                        @args.shift;
                    }
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
                        ~ %res{$res.key}.optstr 
                        ~ q{ is required!})
                    .throw;
            }
        }
        if %res<help> {
            self.help;
        }
        return %res;
    }
    submethod parseshort(Str $opt, $arg --> Bool) {
        if %!optchar{$opt}:exists {
            if $arg === Any {
                return %!optchar{$opt}.set();
            }
            return %!optchar{$opt}.set($arg);
        }
        X::GP::Parse.new(message=>qq{Option $opt does not exist!}).throw;
    }
    submethod parselong(Str $opt, $arg --> Bool) {
        if %!optlong{$opt}:exists {
            if $arg === Any {
                return %!optlong{$opt}.set();
            }
            return %!optlong{$opt}.set($arg);
        }
        X::GP::Parse.new(message=>qq{Option $opt does not exist!}).throw;        
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
    submethod help() {
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
}
