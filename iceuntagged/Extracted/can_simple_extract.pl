#!/usr/bin/perl

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">can-log.txt");
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
			$line =~ s/^<\$([A-Z0-9\?]{1,3})> //;
			$line =~ s/^\$([A-Z0-9\?]{1,3})> //;
			$line =~ s/^<\$([A-Z]{1,3})  </</;
			$line =~ s/^<p> //;
			
			if (defined($line) && $line ne '')
			{
				if ($line =~ /^<\$([A-Z]+)>/)
				{
					print LOG "1: $line\n";
				}
				elsif ($line =~ /^<#/)
				{
					print LOG "1,5: $txt : $line\n";
				}
				elsif ($line =~ /^<ICE-CAN/) # || $line =~ /^<\$ICE-CAN/ || $line =~ /^ICE-CAN:/)
				{
					$line =~ s/^<//;
					if ( ($line =~ /^ICE-CAN/) ) # && ( ( $line =~ /#([A-Z0-9\/-]+):\d+(.*)> ([a-zA-Z0-9<\(":]+)/ ) || ( $line =~ /-(\d+)#> ([a-zA-Z0-9<\(":]+)/ ) || ( $line =~ /-(\d+)#([0-9\/-]+)> ([a-zA-Z0-9<\(":]+)/ ) ))
					{
						my $temp1 = $line;
						my $temp2 = $line;
						if ($temp1 !~ /^ICE-CAN([^ ]+?) (.+)/)
						{
#							print LOG "$line\n";
							$temp1 =~ s/^ICE-CAN([^>]+?)/ICE-CAN$1/;
							$temp2 = '';
						}
						else
						{
							$temp1 =~ s/^ICE-CAN([^ ]+?) (.+)/ICE-CAN$1/;
							$temp2 =~ s/^ICE-CAN([^ ]+?) //;
						}
						$temp1 =~ s/>$//;
						$temp1 =~ s/#/:/;
						push(@newcontent, "\n$temp1\t");
						push(@newcontent, $temp2);
#						print "\n$temp1\t$temp2";
					}
					else
					{
						$line =~ s/>$//;
						$line =~ s/#/:/;
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
my @oneliner = ();
foreach my $sentence (@newcontent)
{
	if ($sentence =~ /\n/ && $sentence !~ /\t/)
	{
		print LOG "3: $sentence\n";		
	}
	if (defined($sentence) && $sentence ne '')
	{
		if ($sentence =~ /^\n/)
		{
			print OUT "$sentence ";
		}
		else
		{
			print OUT " $sentence";
		}
	}
}
close(OUT);
close(LOG);
print "Check log file\n";
exit;
