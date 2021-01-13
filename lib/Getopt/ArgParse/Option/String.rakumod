#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=TITLE Getopt::ArgParse::Option::String

=head1 Attributes

=defn verify
A regex to verify the option argument, if it is defined and verify does not match a exception X::GP::Value will be thrown.

=head1 Methods

=defn set(Str)
set the value, returns True.

=defn value()
returns the option value.

=defn reset()
reset to default.

=end pod
class Getopt::ArgParse::Option::String 
is Option::Base 
is export {
    has Str $!value;
    has Str $.default;
    has Regex $.verify;
    
    submethod TWEAK() {
        self.set($!default) if $!default.defined;
        if !self.meta.defined { self.meta=q{<string>}; }
    }
    method value(--> Str) { $!value; }
    multi method set(Str:D $val --> Bool) { 
        if ( $!verify.defined && $val !~~ $!verify ) {
            X::GP::Value
            .new(message=>"$val does not match on option " ~ self.optstr)
            .throw;
        } 
        $!value = $val; 
        return True;
    }
    method gist() {
        self.gengist()
        ~ ($!default.defined ?? ' default=>' ~ $!default ~ ", " !! '' )
        ~ ($!verify.defined ?? ' verify=>' ~ $!verify.gist ~ ", " !! '' );
    }
    method reset() { $!value = $!default; }
}
