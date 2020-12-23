#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=head1 Array

=defn valid
Regular expression which matches valid elements.

=defn separator
Regular expression to split the arguments, defauls to »\s*,\s*«.

=defn joiner
The charakters to join the array elements, defauls to »,«.

=defn quantity
Maximum amount of elements in the array.

=end pod
class Getopt::ArgParse::Option::Array 
is Getopt::ArgParse::Option::Base 
is export {
    has @!ar;
    has Regex $!valid;
    has Str $!separator=',';
    has Int $!quantity;
    
    submethod TWEAK(Str :$value, Str :$separator, 
        Regex :$valid, Int :$quantity) {
        if $valid.defined { $!valid=$valid; }
        if $quantity.defined { $!quantity=$quantity; }
        if $separator.defined { $!separator=$separator; }
        if $value.defined { self.set($value); }
        if !self.meta.defined { 
            self.meta = q{<elem>[} ~ $!separator ~ q{<elem>]}; 
        }
    }
    method value() { @!ar; }
    method set(Str $val --> Bool) {
        my @va = $val.split($!separator);
        if ( $!valid.defined && @va.grep($!valid).elems != @va.elems ) {
            X::GP::Value
            .new(message=>"$val contains invalid elements")
            .throw;
        }
        if ( $!quantity.defined && @!ar.elems + @va.elems > $!quantity ) {
            X::GP::Value
            .new(message=>'"' ~ @va.join(',') 
                ~ qq{" exceeds limit $!quantity elements})
            .throw;
        }
        @!ar.append(@va);
        return True;
    }
    method elems() { @!ar.elems; }
    method gist() {
        self.gengist()
        ~ ($!quantity.defined ?? 'quantity=>"' ~  $!quantity ~ "\", " !! '' )
        ~ ($!separator.defined ?? 'joiner=>"' ~  $!separator ~ "\", " !! '' );
    }
}