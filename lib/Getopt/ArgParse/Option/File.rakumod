#----------------------------------------
use Getopt::ArgParse::Exception;
use Getopt::ArgParse::Option::Base;
#use IO::Path;
#----------------------------------------
=begin pod

=head1 File

=end pod
class Getopt::ArgParse::Option::File
is Option::Base
is export {
    has IO::Path $!value;
    has IO::Path $!default;
    has Regex $.verify is rw;
    has Bool:D $.write   is default(False) is rw = False;
    has Bool:D $.newfile is default(False) is rw = False;
    has Bool:D $.read    is default(True)  is rw = True;
    has Bool:D $.dir     is default(False) is rw = False;

    submethod TWEAK(Str :$default) {
        if !self.meta { self.meta = q{<file>}; }
        if $default.defined {
            self.set($default);
            $!default = $!value;
        }
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
        if $!newfile {
            if $pp ~~ :e {
                X::GP::Value
                .new(message=>self.optstr 
                    ~ qq{ $val shall not exist!})
                .throw;
            } elsif $pp.dirname.IO !~~ :rw {
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
        if $!dir && $pp !~~ :d && $pp !~~ :rw {
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
        ~ ($!newfile.defined ?? 'newfile=>' ~ $!newfile.gist ~", " !! '' )
        ~ ($!dir.defined ?? 'dir=>' ~ $!dir.gist ~", " !! '' )
        ~ ($!read.defined ?? 'read=>' ~ $!read.gist ~", " !! '' )
        ~ ($!write.defined ?? 'write=>' ~ $!write.gist ~", " !! '' );
    }
    method reset() { $!value = $!default; }
}
