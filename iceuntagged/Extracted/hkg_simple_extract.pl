#!/usr/bin/perl

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">hkg-log.txt");
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
			if (defined($line) && $line ne '')
			{
				if ($txt =~ /^W/i)
				{
					$line =~ s/^<p> //i;
					$line =~ s/^\s+//;
					$line =~ s/\s+$//;
					if ($line =~ /^<ICE-HK/)
					{
						$line =~ s/^<ICE-HK([^>]+?)>/\nICE-HK$1\t/;
#						$line =~ s/^<//;
#						$line =~ s/>$//;
						$line =~ s/#/:/;
						$line =~ s/ICE-HK/ICE-HKG/;
#						$line = "\n" . $line . "\t";
						push(@newcontent, $line);
					}
					elsif ($line =~ /^<\$(A-Z){1,2}>$/ || $line =~ /^<[A-Z]{1,2}>$/)
					{
					}
					elsif ($line =~ /ICE-HK/)
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
#						print LOG "3: $line\n";
					}
				}
				if ($txt =~ /^S/i)
				{
					$line =~ s/^\s+//;
					$line =~ s/\s+$//;
					$line =~ s/^<\$A>  //;
					if ($line =~ /^<ICE-HK/)
					{
						$line =~ s/^<ICE-HK([^>]+?)>/\nICE-HK$1\t/;
#						$line =~ s/^<//;
#						$line =~ s/>$//;
						$line =~ s/#/:/;
						$line =~ s/ICE-HK/ICE-HKG/;
#						$line = "\n" . $line . "\t";
						push(@newcontent, $line);
					}
					elsif ($line =~ /^<#([A-Z0-9:])>/)
					{
						$line =~ s/^<#([^>]+?)>/\nICE-HK#$1\t/;
						$line =~ s/#/:/;
						$line =~ s/ICE-HK/ICE-HKG/;
						push(@newcontent, $line);
					}
					elsif ($line =~ /^<\$(A-Z){1,2}>$/ || $line =~ /^<[A-Z]{1,2}>$/)
					{
					}
					elsif ($line =~ /ICE-HK/)
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
#						print LOG "3: $line\n";
					}
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
print "Check log fila, hkg-log.txt\n";
exit;
