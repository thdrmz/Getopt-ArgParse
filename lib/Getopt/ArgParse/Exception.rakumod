unit module Getopt::ArgParse::Exception;

class X::GP::Exception is Exception {
    has Str $.message;
}

class X::GP::Value is X::GP::Exception {}
class X::GP::MissedOption is X::GP::Exception {}
class X::GP::NoName is X::GP::Exception {}
class X::GP::Double is X::GP::Exception {}
class X::GP::Parse is X::GP::Exception {}
class X::GP::OptNotDef is X::GP::Exception {}
