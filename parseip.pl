#!/usr/bin/perl

use strict;
use warnings;
use Regexp::Common qw /net/;
use IO::Prompter;

my $date_input = prompt "Enter a date, ex: Jan 01:", -echo=>'';
my $cmd = "journalctl -u postfix.service | grep '$date_input'";

my @output = `$cmd`;
chomp @output;

print "Dumping log output: \n";
my $line;
foreach $line (@output)
{
	print "$line\n";
}

print "\n\n";
print "Creating IPTables drop commands:\n";

# Extract the ip addresses, then put them into an array
my $RE;
my $iptables_command;
my @raw_iptables_cmds = ();
foreach $line (@output)
{
	$line =~ /$RE{net}{IPv4}{-keep}/;
	$iptables_command = "iptables -I FORWARD -s $1 -j DROP\n";
	push @raw_iptables_cmds, $iptables_command; 
}

my %seen = ();
my @iptables_cmds = ();
my $item;
foreach $item (@raw_iptables_cmds)
{
	unless ($seen{$item})
	{
		# if we get here, we have not seen it before
		$seen{$item} = 1;
		push @iptables_cmds, $item;
	}
}

foreach $line (@iptables_cmds)
{
	print "$line";
}
