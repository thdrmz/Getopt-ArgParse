#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=head1 Pairs

=defn multiple
Boolean defaults to true, when true allows multiple pairs.

=defn validval
A Regex defining valid valus, 

=end pod
class Getopt::ArgParse::Option::Pairs 
is Getopt::ArgParse::Option::Base 
is export {
    has %!value;
    has Bool:D $!multiple = Bool::True;
    has Regex $!validkey;
    has Regex $!validval;
    
    submethod TWEAK(Bool :$multiple, Regex :$validkey, Regex :$validval) {
        if $multiple.defined { $!multiple=$multiple; }
        if $validkey.defined { $!validkey=$validkey; }
        if $validval.defined { $!validval=$validval; }
        if !self.meta.defined { self.meta=q{<key>=<value>}; }
    }
    method set(Str $in --> Bool) {
        my Str $k;
        my Str $v;
        ($k,$v) = $in.split('=');
        if !($k.defined && $v.defined) {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ requires <key>=<value>, "$in" is invalid!})
            .throw;
        }
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
}
