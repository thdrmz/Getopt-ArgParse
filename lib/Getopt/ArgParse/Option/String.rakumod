#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=head1 String

=end pod
class Getopt::ArgParse::Option::String 
is Getopt::ArgParse::Option::Base 
is export {
    has Str $!value;
    has Regex $!verify;
    
    submethod TWEAK(Regex :$verify, Str :$value) {
        if $verify.defined { $!verify=$verify; }
        if $value.defined { self.set($value); }
        if !self.meta.defined { self.meta=q{<string>}; }
    }
    method value() { $!value; }
    method set(Str:D $val --> Bool) { 
        if ( $!verify.defined && $val !~~ $!verify ) {
            X::GP::Value
            .new(message=>"$val does not match")
            .throw;
        } 
        $!value = $val; 
        return True;
    }
    method gist() {
        self.gengist()
        ~ ($!verify.defined ?? ' verify=><defined>' ~ ", " !! '' );
    }
}
