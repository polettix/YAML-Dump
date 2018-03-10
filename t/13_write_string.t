use strict;
use warnings;
use Test::More 0.88;
use Test::Exception;

use YAML::Dump qw< Dump INDENT >;

my $obj1 = bless {what => 'ever', you => 'do'}, 'Whatever';
my $obj2 = bless [1..4], 'Some::Thing';
my $obj3 = bless {}, 'Un::Known';

my @ok_tests = (
   [string => 'ciao', '--- ciao'],
);
for my $ok_test (@ok_tests) {
   my ($name, $data, $expected) = @$ok_test;
   my $got;
   lives_ok { $got = Dump($data) } "$name lives";
   is $got, $expected, "$name result";
}



sub YAML::Dump::dumper_for_unknown {
   my ($self, $element, $line, $indent, $seen) = @_;
   my $type = ref $element;

   return {%$element} if $type eq 'Whatever';

   if ($type eq 'Some::Thing') {
      my $i = INDENT x $indent;
      my @e = @$element;
      my @ls;
      while (@e) {
         my ($k, $v) = splice @e, 0, 2;
         push @ls, $i . "$k: $v";
      }
      if ($line =~ m{-\s*$}mxs) {
         substr $ls[0], 0, length($line), $line;
      }
      else {
         unshift @ls, $line;
      }
      return @ls;
   }

   die \"Unknown type $type";
}

done_testing;
