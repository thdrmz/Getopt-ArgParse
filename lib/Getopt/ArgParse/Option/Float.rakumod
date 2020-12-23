#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod
=head1 Float
=end pod
class Getopt::ArgParse::Option::Float 
is Getopt::ArgParse::Option::Base 
is export {
    has Real $!value;
    has Real $.min;
    has Real $.max;
    submethod BUILD( Real :$min, Real :$max, Real :$value) {
        $!min=$min;
        $!max=$max;
        if $value.defined { self.set($value); }
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
}
