#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#----------------------------------------
=begin pod

=head1 Getopt::ArgParse::Option::Choices

=defn multiple
Boolean defaults to true. 
When true allows multiple choices, 
on false only one choice is allowed.

=defn case
Boolean defaults to true, the choices keys are case sensitiv.

=head2 Methods

=defn set(Str <choice>)
Set a choice to true, throws exception when <choice> does not match a key.

=defn value()
Returns Hash with choices as keys and the choices which are set are true, the others are false.

=end pod
class Getopt::ArgParse::Option::Choices 
is Option::Base 
is export {
    has %!value;
    has Bool:D $!multiple = Bool::True;
    has Bool:D $!case     = Bool::True;
    submethod TWEAK(Bool :$multiple, Bool :$case, :@choices) {
        if $multiple.defined { $!multiple=$multiple; }
        if $case.defined { $!case=$case; }
        for @choices {
            %!value{$_} = False; 
        }
        if !self.meta.defined {
            self.meta = '<' ~ %!value.keys.join('|') ~ '>';
        }
    }
    method set(Str $val is copy --> Bool) {
        if !$!case { 
            $val = %!value.keys.grep(/:i ^ <$val> $/)[0]; 
        }
        if %!value{$val}:exists {
            %!value{$val} = True;
        } else {
            X::GP::Value
            .new(message=>"\"$val\" is not a valid choice!")
            .throw;
        }
        if !$!multiple {
            my @keys;
            for %!value.pairs -> $k {
                if $k.value { @keys.append($k.key); }
            }
            if @keys.elems > 1 {
                X::GP::Value
                .new(message=>self.optstr ~ " allows only one choice! (" 
                    ~ @keys.sort.join(',') ~ ') selected')
                .throw;
            }
        }
        return True;
    }
    method value() { %!value; }
    method gist() {
        self.gengist()
        ~ ($!multiple.defined ?? 'multiple=>"' ~  $!multiple ~ "\", " !! '' )
        ~ ($!case.defined ?? 'case=>"' ~  $!case ~ "\", " !! '' );
    }
    method reset() {
        for %!value.keys {
            %!value{$_} = False; 
        }
    }
}
