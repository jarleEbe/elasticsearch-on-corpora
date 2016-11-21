#!/usr/binperl

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">jam-log.txt");
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
			$line =~ s/\x1C//g;
			$line =~ s/\x1D//g;
			if (defined($line) && $line ne '')
			{
				if ($txt =~ /^W/i)
				{
					$line =~ s/^<\$([A-Z\?]){1,2}>//;
					$line =~ s/^<p>//;
					$line =~ s/^<P>//;
					$line =~ s/^([ ]+)//;
					$line =~ s/\s+$//;
					if ($line =~ /^<ICE-JA/)
					{
						$line =~ s/^<ICE-JA([^>]+?)>/\nICE-JA$1\t/;
						$line =~ s/#/:/;
						$line =~ s/ICE-JA/ICE-JAM/;
						push(@newcontent, $line);
					}
					elsif ($line =~ /^<\$(A-Z){1,2}>$/ || $line =~ /^<[A-Z]{1,2}>$/)
					{
					}
					elsif ($line =~ /(.+)<ICE-JA/)
					{
						my @temp = split/ICE-JA/, $line;
						my $rest = $temp[0];
						my $ice = $temp[1];
						$rest =~ s/<$//;
						$rest = ' ' . $rest . ' ';
						push(@newcontent, $rest);
						$ice =~ s/^:([^>]+?)>/\nICE-JA:$1\t/;
						$ice =~ s/#\t /\t/;
						$ice =~ s/#/:/;
						$ice =~ s/ICE-JA/ICE-JAM/;
						push(@newcontent, $ice);
						if ($#temp > 2)
						{
							print LOG "2a: $line\n";
						}
#						print LOG "2b: $rest\n$ice\n";
					}
					elsif ($line =~ /ICE-JA/)
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
					$line =~ s/^<\$([A-Z\? ]){1,2}>//;
					$line =~ s/^<\$A //;
					$line =~ s/^<\$student([^>]*?)>//;
					$line =~ s/^<\$audience>//;
					$line =~ s/^ <\&>([^>]+?)<\/\&>//;
					$line =~ s/^([ ]+)//;
					$line =~ s/\s+$//;
					if ($line =~ /^<ICE-JA/)
					{
						$line =~ s/^<ICE-JA([^>]+?)>/\nICE-JA$1\t/;
						$line =~ s/#/:/;
						$line =~ s/ICE-JA/ICE-JAM/;
#						$line = "\n" . $line . "\t";
						push(@newcontent, $line);
					}
					elsif ($line =~ /^<#([A-Z0-9:])>/)
					{
						$line =~ s/^<#([^>]+?)>/\nICE-JA#$1\t/;
						$line =~ s/#/:/;
						$line =~ s/ICE-JA/ICE-JAM/;
						push(@newcontent, $line);
					}
					elsif ($line =~ /^<\$(A-Z){1,2}>$/ || $line =~ /^<[A-Z]{1,2}>$/)
					{
					}
					elsif ($line =~ /(.+)<ICE-JA/)
					{
						my @temp = split/ICE-JA/, $line;
						my $rest = $temp[0];
						my $ice = $temp[1];
						$rest =~ s/<$//;
						$rest = ' ' . $rest . ' ';
						push(@newcontent, $rest);
						$ice =~ s/^:([^>]+?)>/\nICE-JA:$1\t/;
						$ice =~ s/#\t /\t/;
						$ice =~ s/#/:/;
						$ice =~ s/ICE-JA/ICE-JAM/;
						push(@newcontent, $ice);
						if ($#temp > 2)
						{
							print LOG "2a: $line\n";
						}
#						print LOG "2b: $rest\n$ice\n";
					}
					elsif ($line =~ /ICE-JA/)
					{
						print LOG "2x: $line\n";
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
	$sentence = &split_contractions($sentence);
	if ($sentence =~ /\n/ && $sentence !~ /\t/)
	{
		print LOG "1x: $sentence\n";		
	}
	print OUT "$sentence";
}
close(OUT);
close(LOG);
print "Check log fila, jam-log.txt\n";
exit;

sub split_contractions
{
	my ($splitted) = @_;
	
	$splitted =~ s/Let\'s/Let \'s/g;
	$splitted =~ s/Let\'m/Let \'m/g;
	$splitted =~ s/let\'s/let \'s/g;
	$splitted =~ s/let\'m/let \'m/g;

	$splitted =~ s/([I]{1})(\'m)(\s|\W)/$1 $2$3/gi;

	$splitted =~ s/([[:alpha:]]{1})(\'n)(\s|\W)/$1 \'n$3/gi;
	$splitted =~ s/([[:alpha:]]{1})(\'em)(\s|\W)/$1 \'em$3/gi;
	
	$splitted =~ s/([[:alpha:]]{1})(n\'t)(\s|\W)/$1 $2$3/gi;

	$splitted =~ s/(^|\s|\W)(He|She|It|he|she|it|This|That|Who|There|How|What|Where|Here|Something|Everything|Anything|this|that|who|there|how|what|where|here|something|everything|anything)\'s(\s|\W)/$1$2 \'s$3/g;
	
	return $splitted;
}
