#!/usr/bin/perl

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">usa-log.txt");
my @newcontent = ();
while (my $txt = readdir(SUBDIR))
{
	if ($txt =~ /\.$ext$/i)
	{
		open(INN, "$path$txt");
		my @content = <INN>;
		close(INN);
		if ($#content <= 0)
		{
			print "Empty file? $path$txt\n";
			next;
		}
		$num_files++;
		my $written = 0;
		my $lead = '';
		foreach my $line (@content)
		{
			chomp($line);
#			if ($line =~ /\x19/)
#			{
#			    print LOG "$line\n";
#			}
			$line =~ s/\x19/'/g;
			$line =~ s/\x1C//g;
			$line =~ s/\x1D//g;
			$line =~ s/^<I>//;
			$line =~ s/^<p> //i;
			$line =~ s/^<p>//i;
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;
			$line =~ s/^<\$([^>]+?)> //;
			if (defined($line) && $line ne '')
			{
				if ($txt =~ /^W/)
				{
					if ($line =~ /^<ICE-USA/)
					{
						$line =~ s/^<ICE-USA([^>]+?)>/\nICE-USA$1\t/;
						$line =~ s/#/:/;
						push(@newcontent, $line);
					}
					elsif ($line =~ /ICE-USA/)
					{
						print LOG "2: $line\n";
					}
					elsif (defined($line) && $line ne '')
					{
						$line = ' ' . $line . ' ';
						push(@newcontent, $line);
					}
					else
					{
						print LOG "3: $line\n";
					}
				}
				if ($txt =~ /^S/)
				{
				    print LOG "4: Spoken ???\n";
				}
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
		print LOG "1x: $sentence\n";		
	}
	print OUT "$sentence";
}
close(OUT);
close(LOG);
print "Check log fila, usa-log.txt\n";
exit;
