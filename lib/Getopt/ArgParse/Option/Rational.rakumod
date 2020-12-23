#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod
=head1 Rat
=end pod
class Getopt::ArgParse::Option::Rational 
is Getopt::ArgParse::Option::Base 
is export {
    has Rat $!value;
    has Rat $.min;
    has Rat $.max;
    submethod TWEAK(Rat :$min, Rat :$max, Rat :$value) {
        $!min=$min;
        $!max=$max;
        if $value.defined { self.set($value); }
        if !self.meta.defined { self.meta=q{<Rational>}; }
    }
    method value() { $!value; }
    multi method set(Rat:D $val --> Bool) {
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
}
