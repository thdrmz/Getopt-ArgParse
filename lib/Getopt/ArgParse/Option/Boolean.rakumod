#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=TITLE Getopt::ArgParse::Option::Boolean
A boolean option defaults to False.
A boolean option does not need an argument, but here are the arguments yes, no, true, false allowed to set a boolean option.
Without a argument, the current value will be toggled.

=head2 Methods

=defn set()
when called without arguments, the boolean value will be toggled.

=defn set(Bool)
sets the value to the given boolean.

=defn set(Str)
set the value to Bool::True when string is yes, true, ja or wahr and
to Bool::False when string is no, false, nein or falsch.

=defn value()
Returns the boolean value.

=end pod
class Getopt::ArgParse::Option::Boolean 
is Option::Base is export {
    has Bool:D $!value = False;
    has Bool:D $.default is default(False) is rw = False;
    constant $rey = rx:i/ yes || true || ja || wahr /;
    constant $ren = rx:i/ no || false || nein || falsch /;
    
    method value(--> Bool) { $!value; }
    multi method set( --> Bool) { $!value = !$!value; True;}
    multi method set(Bool:D $val --> Bool) { $!value = $val; True;}
    multi method set(Str:D $val --> Bool) {
        if ($val ~~ $rey ) {
            $!value = True;
        } elsif($val ~~ $ren ) {
            $!value = False;
        } else {
            $!value = !$!value;
            return False; # no boolen parameter
        }
        return True;
    }
    method reset() { $!value = $!default; }
}
