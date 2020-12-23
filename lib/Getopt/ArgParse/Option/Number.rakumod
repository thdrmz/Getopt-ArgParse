#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=head1 Number

=end pod
class Getopt::ArgParse::Option::Number 
is Getopt::ArgParse::Option::Base 
is export {
    has Int $!value;
    has Int $.min;
    has Int $.max;
    submethod TWEAK( Int :$min, Int :$max, Int :$value) {
        $!min=$min;
        $!max=$max;
        if $value.defined { self.set($value); }
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
}
