#!/usr/bin/perl

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">sgp-log.txt");
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
			$line =~ s/^\s+//;
			$line =~ s/\s+$//;
			$line =~ s/&lsquo;/"/g;
			$line =~ s/&rsquo;/"/g;
			$line =~ s/&ldquo;/"/g;
			$line =~ s/&rdquo;/"/g;
			$line =~ s/^<I>$//;
			$line =~ s/^<\/I>$//;
			
			if (defined($line) && $line ne '')
			{
				if ($line =~ /^<\$([A-Z]+)>$/)
				{
					
				}
				elsif ($line =~ /^<ICE-SIN/ || $line =~ /^<\$ICE-SIN/ || $line =~ /^ICE-SIN:/)
				{
					$line =~ s/^<//;
					$line =~ s/^\$//;
#ICE-SIN:S1B-031#> ICE-SIN:S2A-042#>
					if ( ($line =~ /^ICE-SIN/) && ( ( $line =~ /#([A-Z0-9\/-]+):\d+(.*)> ([a-zA-Z0-9<\(":]+)/ ) || ( $line =~ /-(\d+)#> ([a-zA-Z0-9<\(":]+)/ ) || ( $line =~ /-(\d+)#([0-9\/-]+)> ([a-zA-Z0-9<\(":]+)/ ) ))
					{
						my $temp1 = $line;
						$temp1 =~ s/^ICE-SIN([^ ]+?) (.+)/ICE-SIN$1/;
						$temp1 =~ s/>$//;
						my $temp2 = $line;
						$temp2 =~ s/^ICE-SIN([^ ]+?) //;
						$temp1 =~ s/ICE-SIN/ICE-SGP/;
						#$temp1 = lc($temp1);
						$temp1 =~ s/#/:/;
						push(@newcontent, "\n$temp1\t");
						push(@newcontent, $temp2);
#						print "\n$temp1\t$temp2";
					}
					else
					{
						$line =~ s/>$//;
						$line =~ s/ICE-SIN/ICE-SGP/;
						$line =~ s/#/:/;
						#$line = lc($line);
						push(@newcontent, "\n$line\t");
					}
				}
				else
				{
					$line = ' ' . $line . ' ';
					push(@newcontent, $line);
				}
			}
			else
			{
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
	if (defined($sentence) && $sentence ne '')
	{
		print OUT $sentence;
	}
}
close(OUT);
close(LOG);
print "Check log file\n";
exit;
