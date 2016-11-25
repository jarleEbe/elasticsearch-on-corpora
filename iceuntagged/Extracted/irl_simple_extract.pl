#!/usr/bin/perl

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">>irl-log.txt");
my @newcontent = ();
while (my $txt = readdir(SUBDIR))
{
	if ($txt =~ /\.$ext$/i)
	{
		open(INN, "$path$txt");
#		binmode INN, ":utf8";
		print LOG "$txt\n";
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
		my @cachen = ();
		foreach my $temp (@content)
		{
			chomp($temp);
			$temp =~ s/\x0A//g;
			$temp =~ s/\x0D//g;
			$temp =~ s/> <X> <#> /> <#> /;
			$temp =~ s/ <#> /\n<#> /g;
			my @temparr = split/\n/, $temp;
			foreach my $temp2 (@temparr)
			{
				push(@cachen, $temp2)
			}
		}
		foreach my $line (@cachen) #(@content)
		{
			if (defined($line) && $line ne '')
			{
				my $country = 'ICE-IRL:';
				if ($path =~ /written/ || $path =~ /spoken/)
				{
					if ($line =~ /^<W([A-Z0-9\$-]+)>$/ || $line =~ /^<S([A-Z0-9\$-]+)>$/)
					{
						$lead = '';
						$line =~ s/^<//;
						$line =~ s/>$//;
						$line =~ s/\$/:/;
						$lead = "\n" . $country . $line . "\t";
					}
					elsif ($line =~ /^<W([A-Z0-9\$-]+)> / || $line =~ /^<S([A-Z0-9\$-]+)> /)
					{
						$lead = '';
						my $letter = '';
						if ($line =~ /^<W/)
						{
							$letter = 'W';
						}
						else
						{
							$letter = 'S';
						}
						$line =~ s/^<W([A-Z0-9\$-]+)> (.*)/<W$1\t$2/;
						$line =~ s/^<S([A-Z0-9\$-]+)> (.*)/<S$1\t$2/;
						$lead = "\n" . $country . $letter . $1 . "\t";
						$line =~ s/^<//;
						$line =~ s/\$/:/;
						$lead =~ s/\$/:/;
						my $sunit = "\n" . $country . $line;
						push(@newcontent, $sunit);

					}
					elsif ($line =~ /^<#> /)
					{
						$line =~ s/^<#> //;
						my $sunit = $lead . $line;
						push(@newcontent, $sunit);
					}
					elsif ($line =~ /^<S([^ ]+) ([^>]+?)>$/ || $line =~ /^<W([^ ]+) ([^>]+?)>$/ || $line eq '<I>' || $line eq '</I>'  || $line eq ' <p> ')
					{
#						print LOG "1: $line\n";
					}
					elsif ($line =~ / <#> /)
					{
						$line =~ s/^<p> //;
						$line =~ s/^<h> //;
						$line =~ s/^<quote> //;
						$line =~ s/^<ul> //;
						$line =~ s/^<bold> //;
						$line =~ s/^<it> //;
						$line =~ s/^<#> //;
						$line =~ s/^<quote> //;
						$line =~ s/^<ul> //;
						$line =~ s/^<bold> //;
						$line =~ s/^<it> //;
						$line =~ s/^<#> //;
						$line =~ s/^<p><#> //;
						$line =~ s/^><ul> <bold> <#> //;
	
#						$line =~ s/<#>/#.#/g;
#						push(@newcontent, $lead);
#						my $sunit = $lead . $line;
#						push(@newcontent, $sunit);
						print LOG "2: $line\n";
					}
					else
					{
						$line = ' ' . $line . ' ';
						push(@newcontent, $line);
#						print LOG "3: $line\n";
					}
				}
				if ($path =~ /unknown/)
				{
					if ($line =~ /^<S([A-Z0-9\$-]+)>/)
					{
						$lead = '';

						$line =~ s/^<([^>]+)> <unclear> (.+) <\/unclear>$/$1\t/;
						$line =~ s/> <X> <#> /> <#> /;
						$line =~ s/> <(\{|\[)> /> <#> /;
						$line =~ s/> <([A-Z]{1,1})> (\w)/> <#> $1/;
						$line =~ s/^<([^>]+)> <\&> (.+) <\/\&> <#> /$1\t/;
						$line =~ s/^<([^>]+)> <X> <\&> (.+) <\/\&> <#> /$1\t/;
						$line =~ s/^<([^>]+)> <\&> (.+) <\/\&>/$1\t#,,#/;
						$line =~ s/^<([^>]+)> <\&(.+)<\/\&([^>]+?)> (.+)/$1\t$3/;
						$line =~ s/^<([^>]+)> (\w)/$1\t$2/;
						$line =~ s/> <X> <#> /\t/;
						$line =~ s/^<([^>]+)> <#> /$1\t/;
						$line =~ s/\$/:/;
#						$line =~ s/<#>/#.#/g;
						$line =~ s/^<//;
						$line = "\n" . $country . $line;
						#print "$line\n";
						push(@newcontent, $line);
					}
					elsif ($line =~ /^<\&> (.+) <\/\&>$/)
					{
					}
					elsif ($line =~ /^<#> /)
					{
						$line =~ s/^<#> / #.# /g;
						push(@newcontent, $line);
					}
					else
					{
						
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
		print LOG "1: $sentence\n";		
	}
	print OUT "$sentence";
}
close(OUT);
close(LOG);
print "Check log file, irl-log.txt\n";
exit;
