use Test;
use Getopt::ArgParse::Str2Arg;
use Data::Dump::Tree;

plan 39;

my Str $astr = qq:to/END/;
    -ab
    --set-string blablubtrrr
    --set-str3 "bb aa cc"
    --set-str4 cc\\ rrr
    --str-quote1 "bb aa \\"nn ara\\" rr"
    --str-quote2 'bb aa "nn ara" dd ll rr'
    --str-quote3="bb aa 'nn ara' rr"
    --str-quote4='bb aa nn ara dd lt rr'
    -c yes 
    --the_number=10 
    --float 12.3 
    --rat 3/4 
    -iii 
    --array abc,def,jkl 
    --choices dab 
    -k ooo
    --pairs nnn=123 
    -l zzz=321 
    --file $*PROGRAM-NAME 
    arg1 arg2
    --
    --endofargs
    END

my @res=str2args($astr);

is @res[0], q{-ab}, 'result 0';
is @res[1], q{--set-string}, 'result 1';
is @res[2], q{blablubtrrr}, 'result 2';
is @res[3], q{--set-str3}, 'result 3';
is @res[4], q{bb aa cc}, 'result 4';
is @res[5], q{--set-str4}, 'result 5';
is @res[6], q{cc rrr}, 'result 6';
is @res[7], q{--str-quote1}, 'result 7';
is @res[8], q{bb aa "nn ara" rr}, 'result 8';
is @res[9], q{--str-quote2}, 'result 9';
is @res[10], q{bb aa "nn ara" dd ll rr}, 'result 10';
is @res[11], q{--str-quote3=bb aa 'nn ara' rr}, 'result 11';
is @res[12], q{--str-quote4=bb aa nn ara dd lt rr}, 'result 12';
is @res[13], q{-c}, 'result 13';
is @res[14], q{yes}, 'result 14';
is @res[15], q{--the_number=10}, 'result 15';
is @res[16], q{--float}, 'result 16';
is @res[17], q{12.3}, 'result 17';
is @res[18], q{--rat}, 'result 18';
is @res[19], q{3/4}, 'result 10';
is @res[20], q{-iii}, 'result 20';
is @res[21], q{--array}, 'result 21';
is @res[22], q{abc,def,jkl}, 'result 22';
is @res[23], q{--choices}, 'result 23';
is @res[24], q{dab}, 'result 24';
is @res[25], q{-k}, 'result 25';
is @res[26], q{ooo}, 'result 26';
is @res[27], q{--pairs}, 'result 27';
is @res[28], q{nnn=123}, 'result 28';
is @res[29], q{-l}, 'result 29';
is @res[30], q{zzz=321}, 'result 30';
is @res[31], q{--file}, 'result 31';
is @res[32], q{t/018.str2args.t}, 'result 32';
is @res[33], q{arg1}, 'result 33';
is @res[34], q{arg2}, 'result 34';
is @res[35], q{--}, 'result 35';
is @res[36], q{--endofargs}, 'result 36';

$astr = qq:to/END/;
    --set-string blab"lubtrrr
    END
#" 
throws-like( { str2args($astr); },
             X::Str2Arg::Incomplete,
             message => q{Input is malformed or incomplete, ends with 'blab"lubtrrr'});

$astr = qq:to/END/;
    --set-string blab'lubtrrr
    END
#' 

throws-like( { str2args($astr); },
             X::Str2Arg::Incomplete,
             message => q{Input is malformed or incomplete, ends with 'blab'lubtrrr'});
#'
#@res=str2args($astr);
    
done-testing;
