#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod
=TITLE Getopt::ArgParse::Option::Rational
An option with an rational argument.

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

=defn set(Rat)
set value, throws an exception if parameter isn't between defined min max.
=end pod
class Getopt::ArgParse::Option::Rational 
is Option::Base 
is export {
    has Rat $!value;
    has Rat $.default is rw;
    has Rat $.min;
    has Rat $.max;
    submethod TWEAK() {
        self.set($!default) if $!default.defined;
        self.meta=q{<Rational>} if !self.meta.defined;
    }
    method value() { $!value; }
    multi method set(Rat:D $val --> Bool) {
        X::GP::Value
        .new(message=>"$val is lower than $!min")
        .throw
            if $!min.defined && $val < $!min;
        X::GP::Value
        .new(message=>"$val is greater than $!max")
        .throw
            if $!max.defined && $val > $!max;
        $!value=$val;
        True;
    }
    multi method set(Str:D $val --> Bool) { 
        if $val ~~ /^ <[-+]>? \d <[,./\d]>+$/ { 
            return self.set($val.Rat);
        }
        X::GP::Value
        .new(message=>"$val is not a rational")
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
