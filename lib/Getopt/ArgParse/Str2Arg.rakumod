unit module Getopt::ArgParse::Str2Arg;

class X::Str2Arg::Incomplete is Exception is export {
    has $.word;
    method message { "Input is malformed or incomplete, ends with '$!word'" }
}
#use Grammar::Debugger;
#use Grammar::Tracer;

grammar Grammar {
    rule TOP {
        <?> <word> *
    }
    token word {
     <atom> +
    }
    proto regex atom { <...> }
    token atom:sym<backslashed> {
        \\ ( . )
    }
    token atom:sym<single-str> {
        "'" ~ "'" (<-[']> *)
    }
    token atom:sym<double-str> {
        '"' ~ '"'
        [$<plain> = <-[\\"]> *] *
            %% $<bs> = [\\ .]
    }
    token atom:sym<incomplete> {
        # Catch atom prefixes to identify an incomplete atom at the end
        \\ | "'" | '"'
    }
    token atom:sym<simple> {
        # Because of Longest Token Matching, other atoms will always be
        # tried first, so we just need to avoid the word delimiter
        \S
    }
}

my class WordFailure is Failure {
    method Str {
        self.handled ?? self.exception.word !! self.fail
    }
}

class Actions {
    has Bool $.keep;

    method TOP($/) { make $<word>.map(*.made) }
    method word($/) {
        my $incomplete;
        my $word = '';
        for $<atom>».made {
            when Pair { $incomplete = True; $word ~= .value }
            default   { $word ~= $_ }
        }

        make $incomplete
#                ?? WordFailure.new(X::Str2Arg::Incomplete.new: :$word)
                ?? X::Str2Arg::Incomplete.new(word=>$word).throw
                !! $word;
    }
    method atom:sym<backslashed>($/) {
        # Escaped newline in double-quoted strings is removed entirely
        # in Bourne Shell
        make ~ ($!keep ?? $/ !! $0 eq "\n" ?? '' !! $0);
    }
    method atom:sym<single-str>($/) {
        make ~ ($!keep ?? $/ !! $0);
    }
    method atom:sym<double-str>($/) {
        make $/.chunks.map(-> $c {
            given $c.key {
                when '~' {
                    succeed $c.value if $!keep;
                    ''
                }
                when 'bs' {
                    succeed $c.value if $!keep;
                    given $c.value.substr(1) {
                        when any(<\ ">)     { $_ }
                        when "\n"           { '' }
                        default             { $c.value }
                    }
                }
                when 'plain' {
                    succeed $c.value
                }
            }
        }).join
    }
    method atom:sym<incomplete>($/) { make 'incomplete' => ~$/ }
    method atom:sym<simple>($/) { make ~$/ }
}
=head2 str2args

#| Split a string into its shell-quoted words. If C<keep> is True, the
#| quote characters are preserved in the returned words. By default they
#| are removed.
sub str2args(
    Cool:D $input,
    Bool :$keep = False,
) is export {
    my $grammar = Grammar.new;
    my $actions = Actions.new: :$keep;

    $grammar.parse($input, :$actions)
        or die "Unexpected parse failure of ｢$input｣";

    $/.made<>
}

=begin pod

=head1 SEE ALSO

This module is inspired by, but has different behavior than, Perl's
L<Text::ParseWords|https://metacpan.org/pod/Text::ParseWords> and
L<Text::Shellwords|https://metacpan.org/pod/Text::Shellwords>.

The L<Bash manual page|https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Quoting> describes the three quoting mechanisms copied by this module.

=head1 AUTHOR


=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute and modify it under the
L<Artistic License 2.0|http://www.perlfoundation.org/artistic_license_2_0>.

=end pod
