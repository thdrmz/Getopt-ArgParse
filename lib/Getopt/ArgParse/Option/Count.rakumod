#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod
=head1 Count
=end pod
class Getopt::ArgParse::Option::Count
is Getopt::ArgParse::Option::Base
is export {
    has Int $!value = 0;
    has Int $!max;
    submethod TWEAK(Int :$max, Int :$value) {
        $!max=$max;
        if $value.defined { 
            self.set($value); 
        } else {
            $!value = 0;
        }
        if !self.meta.defined {
            self.meta='[num]' ~ ($!max.defined ?? qq{ < $!max} !! '');
        }
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
}
