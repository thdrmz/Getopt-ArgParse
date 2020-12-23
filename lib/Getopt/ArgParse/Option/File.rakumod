#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#use IO::Path;
#----------------------------------------
=begin pod

=head1 File

=end pod
class Getopt::ArgParse::Option::File 
is Getopt::ArgParse::Option::Base is export {
    has IO::Path $!value;
    has Regex $!verify;
    has Bool $!write = False;
    has Bool $!new = False;
    has Bool $!read = True;
    has Bool $!dir = False;
    submethod TWEAK(Regex :$verify, Str :$value, 
        Bool :$write = False, Bool :$new = False, 
        Bool :$read = True, Bool :$dir = False) {
        if $verify.defined { $!verify=$verify; }
        $!write=$write;
        $!new=$new;
        $!read=$read;
        $!dir=$dir;
        if !self.meta.defined { self.meta = q{<file>}; }
        if $value.defined { self.set($value); }
    }
    method value() { $!value; }
    method set(Str:D $val --> Bool) {
        if ( $!verify.defined && $val !~~ $!verify ) {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ $val is not a valid file name!})
            .throw;
        }
        my $pp = IO::Path.new($val);
        if $!new {
            if $pp ~~ :e {
                X::GP::Value
                .new(message=>self.optstr 
                    ~ qq{ $val shall not exist!})
                .throw;
            } elsif $pp.dirname.IO !~~ :w {
                X::GP::Value
                .new(message=>self.optstr
                    ~ qq{ $val directory isn't writeable!})
                .throw;
            }
        } elsif $!write && $pp !~~ :w {
            X::GP::Value
            .new(message=>self.optstr
                ~ qq{ $val is not writeable!})
            .throw;
        } elsif $!read && $pp !~~ :r {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ $val is not readable!})
            .throw;
        }
        if $!dir && $pp !~~ :d {
            X::GP::Value
            .new(message=>self.optstr 
                ~ qq{ $val is not a directory!})
            .throw;
        }
        $!value = $pp; 
        True;
    }
    method gist() {
        self.gengist()
        ~ ($!verify.defined ?? 'verify=>' ~ $!verify.gist ~ ", " !! '' )
        ~ ($!new.defined ?? 'new=>' ~ $!new.gist ~", " !! '' )
        ~ ($!dir.defined ?? 'dir=>' ~ $!dir.gist ~", " !! '' )
        ~ ($!read.defined ?? 'read=>' ~ $!read.gist ~", " !! '' )
        ~ ($!write.defined ?? 'write=>' ~ $!write.gist ~", " !! '' );
    }
}
