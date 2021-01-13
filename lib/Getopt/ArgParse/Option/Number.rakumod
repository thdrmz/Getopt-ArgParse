#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=TITLE Getopt::ArgParse::Option::Number

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

=defn set(Int)
set value, throws an exception if parameter isn't between defined min max.

=end pod
class Getopt::ArgParse::Option::Number 
is Option::Base 
is export {
    has Int $!value;
    has Int $.default;
    has Int $.min;
    has Int $.max;
    submethod TWEAK() {
        self.set($!default) if $!default.defined;
        if !self.meta.defined { self.meta=q{<integer>}; }
    }
    method value() { $!value; }
    multi method set(Int:D $val --> Bool) {
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
        True;
    }
    multi method set(Str:D $val --> Bool) {
        if $val ~~ /^ <[-+]>? \d+$/ { return self.set($val.Int); }
        X::GP::Value
        .new(message=>"$val is not a number")
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
