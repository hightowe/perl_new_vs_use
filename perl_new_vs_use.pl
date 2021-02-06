#!/usr/bin/perl

####################################################################
# Quick hack to search for module object instantiations in perl code
# but where that module is not imported with a use statement.
#
# A better approach to this might be to use the PPI module, but this
# quick hack suites my purpose for today.
#
# First written Feb-06-2021 by Lester Hightower
####################################################################

use strict;
use diagnostics;
use File::Slurp qw(read_file);	# core
use Data::Dumper;		# core
use Pod::Strip;			# libpod-strip-perl

my $file = $ARGV[0] || '';
if (! (length($file) && -f $file)) {
  die "Script requires one argument, the name of an existing file to analyze.\n";
}
print "$file\n";

# Read file, strip POD, and place code lines into @file_lines
my $file_contents = read_file($file);
# Stip POD as the synopsis sections often match our searches
my $contents_no_pod = '';
my $p=Pod::Strip->new;              # create parser
$p->output_string(\$contents_no_pod);
$p->parse_string_document($file_contents);
my @file_lines = split(/[\r\n]/, $contents_no_pod);

# Gather the "->new" and the "use" lines into arrays.
# Later, it might be nice to store and report the ->new line numbers.
my @new_arrow_lines = grep(/[a-zA-Z0-9_]->new([(]|->)/, @file_lines);
my @use_lines = grep(/^use\s+([^\s]+)/, @file_lines);

# Build a convenience hash of used modules and report on any that
# are used more than once.
my %used_modules=();
foreach my $ul (@use_lines) {
  my ($module_name) = $ul =~ m/^use\s+([^\s;]+)/;
  $used_modules{$module_name}++;
}
foreach my $module (sort keys %used_modules) {
  if ($used_modules{$module} > 1) {
    print " * $module is used more than once: $used_modules{$module} times\n";
  }
}
#print Dumper(\@new_arrow_lines, \@use_lines, \%used_modules) . "\n";

foreach my $nal (@new_arrow_lines) {
  my ($module, $trash, $newpart) = $nal =~ m/\s*([a-zA-Z0-9_]+(::[a-zA-Z0-9_]+)*)(->new([(]|->)([a-zA-Z0-9_]+([(;]|->))*)/;
  if (! defined($used_modules{$module})) {
    print " * $module$newpart was seen but no corresponding \"use $module\"\n";
  }
  #print "($module, $trash, $newpart)\n";
}

