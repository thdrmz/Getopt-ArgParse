#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=head1 Pairs
On Pairs the argument of an option must submitted as "<key>=<value>". 
As result this object returns a hash object.

=head2 Attributes
=defn multiple
Boolean defaults to true, when true allows multiple pairs.

=defn validkey
Regex to verify a key.

=defn validval
A Regex defining valid values.

=head2 Methods
=defn value
Returns collected pairs as hash object.
=defn set(Str "<key>=<value>")
Split the given option argument in <key> and <value> at the first equal sign 
and colleced them in internal hash.

=end pod
class Getopt::ArgParse::Option::Pairs 
is Option::Base 
is export {
    has %!value;
    has Bool:D $.multiple = Bool::True;
    has Regex $.validkey;
    has Regex $.validval;
    constant RSP = rx{^ (<[\w \h]>+) \=+ (.*) $}; 
    submethod TWEAK() {
        if !self.meta.defined { self.meta=q{<key>=<value>}; }
    }
    method set(Str $in --> Bool) {
        my Str $k;
        my Str $v;
        if !($in ~~ RSP) {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ requires <key>=<value>, "$in" is invalid!})
            .throw;
        }
        $k = $0.Str;
        $v = $1.Str;
        if %!value{$k}:exists {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ key $k is already defined!})
            .throw;
        }
        if (!$!multiple && %!value.keys.elems > 0) {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ only one pair allowed!})
            .throw;
        }
        if ($!validkey.defined && $k !~~ $!validkey) {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ invalid key $k! (} ~ $!validkey.gist ~ ')')
            .throw;
        }
        if ($!validval.defined && $v !~~ $!validval) {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ invalid value $v! (} ~ $!validval.gist ~ ')')
            .throw;
        }
        %!value{$k}=$v;
        True;
    }
    method value() { %!value; }
    method gist() {
        self.gengist()
        ~ ($!multiple.defined 
            ?? 'multiple=>"' ~  $!multiple ~ "\", " 
            !! '' );
    }
    method reset() { %!value:={}; }
}
