#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod
=TITLE Getopt::ArgParse::Option::Float

=head2 Attributes

=defn default
the default value

=defn min
when defined, the minimal value of argument

=defn max
when defined, the maximal value of argument

=head2 Methods
=defn set(Str)
set value, throws an exception if parameter isn't a number.

=defn set(Float)
set value, throws an exception if parameter isn't between defined min max.
=end pod
class Getopt::ArgParse::Option::Float 
is Option::Base 
is export {
    has Real $!value;
    has Real $.default;
    has Real $.min;
    has Real $.max;
    submethod TWEAK( Real :$default) {
        self.set($!default) if $!default.defined; 
        if !self.meta.defined { self.meta=q{<float>}; }
    }
    method value() { $!value; }
    multi method set(Real:D $val --> Bool) {
        if $!min.defined && $val < $!min {
            X::GP::Value
            .new(message=>"$val is lower than $!min")
            .throw;
        }
        if $!max.defined && $val > $!max {
            X::GP::Value
            .new(message=>"$val is greater than $!max")
            .throw;
        }
        $!value=$val;
        return True;
    }
    multi method set(Str:D $val --> Bool) { 
        if $val ~~ /^ <[-+]>? \d <[,.\d]>+$/ { 
            return self.set($val.Real); 
        }
        X::GP::Value
        .new(message=>"$val is not a real")
        .throw;
    }
    method gist() {
        self.gengist()
        ~ ($!value.defined ?? 'value=>' ~  $!value ~ ". " !! '' )
        ~ ($!min.defined ?? 'min=>' ~  $!min ~ ", " !! '' )
        ~ ($!max.defined ?? 'max=>' ~  $!max ~ ", " !! '' );
    }
    method reset() { $!value = $!default; }
}
