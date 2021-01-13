#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=TITLE Getopt::ArgParse::Option::Count
Counts the amount of occurrence of the option, eg. -vvv results in 3.

=head2 Attributes
=defn default
The initial value of the counter.

=defn max
When defined, it throws exception when value >= maximum.

=head2 Methods
=defn set(Int)
set the counter to given parameter.

=defn set(Str)
when a integer is given as argument, the value will be set to it, otherwise the counter will be increased.

=defn set()
increase the counter.

=end pod
class Getopt::ArgParse::Option::Count
is Option::Base
is export {
    has Int $!value = 0;
    has Int $.default is default(0) is rw = 0;
    has Int $.max;
    submethod TWEAK(Int :$default) {
        self.set($!default);
        self.meta='[num]' ~ ($!max.defined ?? qq{ < $!max} !! '')
            if !self.meta.defined;
    }
    method value() { $!value; }
    multi method set(Int:D $val --> Bool) { 
        if $!max.defined && $val > $!max { 
            X::GP::Value
            .new(message=>"$val exceeds $!max")
            .throw;
        }
        $!value=$val;
        return True;
    }
    multi method set(Str:D $val --> Bool) {
        if $val ~~ rx/^ <[+-]>? \d+ $/ {
            return self.set($val.Int);
        }
        return( self.set() );
    }
    multi method set( --> Bool) { 
        if $!max.defined && $!value >= $!max { 
            X::GP::Value
            .new(message=>"$!value exceeds $!max")
            .throw;
        }
        ++$!value;
        return False;
    }
    method gist() {
        self.gengist()
        ~ ($!value.defined ?? 'value=>' ~  $!value ~ ". " !! '' )
        ~ ($!max.defined ?? 'max=>' ~  $!max ~ ", " !! '' );
    }
    method reset() { $!value = $!default; }
}
