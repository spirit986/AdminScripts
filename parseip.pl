#!/usr/bin/perl

use strict;
use warnings;
use Regexp::Common qw /net/;
use IO::Prompter;

my $date_input = prompt "Enter a date, ex: Jan 01:", -echo=>'';

my $today = `date +"%b %d"`;
chomp($today);
if ($date_input eq '')
{
	$date_input = $today;
	print "No date specified, using today's date - $date_input.\n\n";
}

my $cmd = "journalctl -u postfix.service | grep '$date_input'";
print "$cmd";

my @output = `$cmd`;
chomp @output;

print "\n\nDumping log output: \n-------------------------------------------------------------------------------\n";
my $line;
foreach $line (@output)
{
	print "$line\n";
}

# Extract the ip addresses, then put them into an array
my $RE;
my @ip_addresses = ();
foreach $line (@output)
{
	$line =~ /$RE{net}{IPv4}{-keep}/;
	push @ip_addresses, $1;
}

print "-------------------------------------------------------------------------------\n\n\n";
print "Creating IPTables drop commands.\nAccessing IP whois reccords. Please wait, it may take a while.\n";

# Sort the unique IP Address.
# Get unique whois information
# Create IPTables command with the whois information in comments
my %seen = ();
my @iptables_cmds = ();
my $ipaddress;
my $iptables_command;
my @whois_country;
my $country;
foreach $ipaddress (@ip_addresses)
{
	unless ($seen{$ipaddress})
	{
		# if we get here, we have not seen it before
		$seen{$ipaddress} = 1;

		# whois may return multible values (rows)
		@whois_country = `whois $ipaddress | grep -i country:`;
		if (!@whois_country)
		{
			$country = "No Country information available...";
		} else {
			chomp($whois_country[0]);
			$country = substr $whois_country[0], -2;
		}

		# Put some warnings if the country is MK or US
		if (uc($country) eq 'MK' || uc($country) eq 'US')
		{
			$country .= ' | *** CAREFULL ***';
		}

		$iptables_command = "iptables -I FORWARD -s $ipaddress -j DROP # Country: $country\n";
		push @iptables_cmds, $iptables_command;
		@whois_country = ();
	}
}

foreach $line (@iptables_cmds)
{
	print "$line";
}
