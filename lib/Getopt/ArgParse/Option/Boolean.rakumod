#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=head1 Getopt::ArgParse::Option::Boolean
manage boolean options

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
is Getopt::ArgParse::Option::Base is export {
    has Bool:D $!value = Bool::False;
    constant $rey = rx:i/( yes || true || ja || wahr) /;
    constant $ren = rx:i/( no || false || nein || falsch) /;
    
    submethod TWEAK(Bool :$value) {
        if $value.defined {
            $!value=$value;
        } else {
            $!value=Bool::False;
        }
#        if !self.meta.defined { self.meta = '[true|false]'; }
    }
    method value() { $!value; }
    multi method set( --> Bool) { $!value = !$!value; True;}
    multi method set(Bool:D $val --> Bool) { $!value = $val; True;}
    multi method set(Str:D $val --> Bool) {
        if ($val ~~ $rey ) {
            $!value = Bool::True;
        } elsif($val ~~ $ren ) {
            $!value = Bool::False;
        } else {
            $!value = !$!value;
            return False; # no boolen parameter
        }
        return True;
    }
}
