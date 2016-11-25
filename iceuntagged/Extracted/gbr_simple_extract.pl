#!/usr/bin/perl

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">gbr-log.txt");
my @newcontent = ();
while (my $txt = readdir(SUBDIR))
{
	if ($txt =~ /\.$ext$/i)
	{
		open(INN, "$path$txt");
#		binmode INN, ":utf8";
		my @content = <INN>;
		close(INN);
		if ($#content <= 0)
		{
			print "Empty file? $txt\n";
			next;
		}
		$num_files++;
		my $written = 0;
		foreach my $line (@content)
		{
			chomp($line);
			if (defined($line) && $line ne '')
			{
				$line = 'ICE-GBR:' . $line;
				$line =~ s/^ICE-GBR:s1a-/ICE-GBR:S1A-/;
				$line =~ s/^ICE-GBR:s2a-/ICE-GBR:S2A-/;
				$line =~ s/^ICE-GBR:s1b-/ICE-GBR:S1B-/;
				$line =~ s/^ICE-GBR:s2b-/ICE-GBR:S2B-/;

				$line =~ s/^ICE-GBR:w1a-/ICE-GBR:W1A-/;
				$line =~ s/^ICE-GBR:w2a-/ICE-GBR:W2A-/;
				$line =~ s/^ICE-GBR:w1b-/ICE-GBR:W1B-/;
				$line =~ s/^ICE-GBR:w2b-/ICE-GBR:W2B-/;
				$line =~ s/^ICE-GBR:w1c-/ICE-GBR:W1C-/;
				$line =~ s/^ICE-GBR:w2c-/ICE-GBR:W2C-/;
				$line =~ s/^ICE-GBR:w1d-/ICE-GBR:W1D-/;
				$line =~ s/^ICE-GBR:w2d-/ICE-GBR:W2D-/;
				$line =~ s/^ICE-GBR:w1e-/ICE-GBR:W1E-/;
				$line =~ s/^ICE-GBR:w2e-/ICE-GBR:W2E-/;
				$line =~ s/^ICE-GBR:w1f-/ICE-GBR:W1F-/;
				$line =~ s/^ICE-GBR:w2f-/ICE-GBR:W2F-/;

				push(@newcontent, $line);
			}
		}
	}
}
close(SUBDIR);
print "Number of files read: $num_files\n";
open(OUT, ">$output");
binmode OUT, ":utf8";
foreach my $sentence (@newcontent)
{
	if ($sentence =~ /\n/ && $sentence !~ /\t/)
	{
		print LOG "$sentence\n";		
	}
	print OUT "$sentence\n";
}
close(OUT);
close(LOG);
print "Check log fila, log.txt\n";
exit;

