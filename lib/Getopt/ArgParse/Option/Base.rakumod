#----------------------------------------
=begin pod

=head1 Getopt::ArgParse::Option::Base
Base class of options.

=head2 new object(optchar=>'?', optlong=>'word', …)

=defn optchar
A single charakter, used with a single dash in options.

=defn optlong
A word starting with an <alpha> followed by <alphanum> and the charakters - and. This word will be used at options starting with double dash '--'.

=defn required
Boolean defauls to Bool::False, when true and option is not given aften argument parsing a X::GP::MissedOption Exception should be thrown.

=defn help
A text describing the option.

=defn dest
The key name of the option the argumet parser should return,
defaults to the long option name.

=defn meta
A word describing the value of an option, eg. <file>.

=head2 methods

=defn value()
Returns value of option, should be defined by derived class.

=defn set([<argument>])
Set the option value, return true when <argument> is used and false when not.

=defn gengist()
Returns string of internals to use it in gist() method.

=defn result()
Returns pair of dest as key and the value of the option.

=defn optstr()
Returns optchar and optlong as string, for the use in help messages.

=AUTHOR Thomas Drillich <th@drillich.com>

=end pod
#----------------------------------------
use Getopt::ArgParse::Exception;
#----------------------------------------
class Option::Base is export {
    has Str $.optchar;
    has Str $.optlong;
    has Bool:D $.required is default(False) is rw = False;
    has Str $.help is default('') is rw = '';
    has Str $.dest is default('') is rw = '';   
    has Str $.meta is rw;
    
    method gengist() {
        my $val = self.value();
        self.^name ~~ m/<alnum>+ $/;
        my $name = ~$/;
        ( 'Option Type = ' ~ $name ~ ', ' )
        ~ ($val.defined ?? 'value=>' ~  $val.gist ~ ', ' !! '' )
        ~ ($!optchar.defined ?? 'optchar=>"' ~  $!optchar ~ '", ' !! '' )
        ~ ($!optlong.defined ?? 'optlong=>"' ~ $!optlong ~ '", ' !! '' ) 
        ~ ($!dest.defined ?? 'dest=>"' ~ $!dest ~ '", ' !! '' ) 
        ~ ($!meta.defined ?? 'meta=>"' ~ $!meta ~ '", ' !! '')
        ~ ($!required ?? 'required=>"' ~ $!required ~ '", ' !! '')
        ~ ($!help.defined ?? 'help=>"' ~ $!help ~ '", ' !! '');
    }
    method gist() { self.gengist(); }
    method result() { 
        my $nam;
        if $!dest.defined && $!dest ~~ rx{^ <[\w \-]>+ $} { 
            $nam = $!dest; 
        } elsif $!optlong.defined && $!optlong ~~ rx{^ <[\w \-]>+ $} { 
            $nam = $!optlong; 
        } else {
            X::GP::NoName.new(message=>self.optstr() 
                ~ q{ Option has no dest name!}).throw;
        }
        return Pair.new($nam, self.value());
    }
    method optchar() { $!optchar; }
    method optlong() { $!optlong; }
    method optstr() {
        return ( $!optchar.defined ?? '-' ~ $!optchar !! '' ) 
            ~ ( $!optchar.defined && $!optlong.defined ?? ' | ' !! '' )
            ~ ( $!optlong.defined ?? '--' ~ $!optlong !! '');
    }
    multi method set() {
        X::GP::Value
        .new(message=>"option " ~ self.optstr ~ " needs an argument!")
        .throw;
     }
     multi method set(--> Bool) {
        X::GP::Value
        .new(message=>"option " ~ self.optstr ~ 
            " set() method in object undefined!")
        .throw;
     }
     multi method set(Str $arg is copy --> Bool) {
        X::GP::Value
        .new(message=>"option " ~ self.optstr ~ 
            " set(Str $arg) method in object undefined!")
        .throw;
     }
    method value() {
        X::GP::Value
        .new(message=>"In option " ~ self.optstr 
            ~ " does not exist a value() method!")
        .throw;
    }
}
