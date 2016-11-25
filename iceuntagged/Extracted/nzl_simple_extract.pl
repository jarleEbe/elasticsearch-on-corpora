#!/usr/bin/perl

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">nzl-log.txt");
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
			$line =~ s/\x0A//g;
			$line =~ s/\x0D//g;
			if (defined($line) && $line ne '')
			{
				if ($txt =~ /^W/)
				{
					if ($line =~ /^<ICE-NZ/ && $line !~ / <ICE-NZ/ && $line !~ /><ICE-NZ/)
					{
						$line =~ s/^<ICE-NZ:([^>]+?)>/\nICE-NZ:$1\t/;
						$lead = '';
						$line =~ s/^<//;
						$line =~ s/>$//;
						$line =~ s/#/:/;
						$line =~ s/ICE-NZ/ICE-NZL/;
						push(@newcontent, $line);
#						print LOG "-1: $line\n";
					}
					elsif ($line =~ /<ICE-NZ/)
					{
						my @morelines = split/(ICE-NZ)/, $line;
						foreach my $ice (@morelines)
						{
#							print LOG "0: $ice\n";
							if ($ice =~ /^:W/ && $ice =~ /<$/)
							{
								$ice =~ s/\s*<$//;
								$ice =~ s/^([^>]+?)>(.*)$/$1\t$2/;
								$ice =~ s/#/:/;
								$ice = "\n" . 'ICE-NZL' . $ice;
								push(@newcontent, $ice);
#								print LOG "1: $ice\n";
							}
							elsif ($ice =~ /^:W/)
							{
								$ice =~ s/^([^>]+?)>(.*)$/$1\t$2/;
								$ice =~ s/#/:/;
								$ice = "\n" . 'ICE-NZL' . $ice;
								push(@newcontent, $ice);
#								print LOG "2: $ice\n";
							}
							elsif ($ice !~ /^:W/ && $ice ne 'ICE-NZ')
							{
								$ice =~ s/\s*<$//;
								$ice = ' ' . $ice . ' ';
								push(@newcontent, $ice);
#								print LOG "3: $ice\n";
							}
							elsif ($ice eq 'ICE-NZ')
							{
							}
							else
							{
								print LOG "4: $ice\n";
							}
						}
					}
					else
					{
						$line = ' ' . $line . ' ';
						push(@newcontent, $line);
#						print LOG "6: $line\n";
					}
				}
				if ($txt =~ /^S/)
				{
					$line =~ s/^\s+//;
					if ($line =~ /^<ICE-NZ/)
					{
						$line =~ s/^<//;
						$line =~ s/>$//;
						$line =~ s/#/:/;
						$line =~ s/ICE-NZ/ICE-NZL/;
						$line = "\n" . $line . "\t";
						push(@newcontent, $line);
					}
					elsif ($line =~ /^<\&>(.+)<\/\&>$/ || $line =~ /^<[A-Z]{1,2}>$/)
					{
					}
					else
					{
						$line = ' ' . $line . ' ';
						push(@newcontent, $line);
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
print "Check log fila, nzl-log.txt\n";
exit;
