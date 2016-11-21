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
#	$sentence = &cleanUp($sentence);
#	if ($sentence =~ /</ || $sentence =~ />/ || $sentence =~ /\&([^ ]+);/)
#	{
#		print LOG "$sentence\n";
#	}
	$sentence = &split_contractions($sentence);
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

sub cleanUp
{
	my $toclean = shift(@_);

	$toclean =~ s/([[:alpha:]]{1}) 's /$1's /g;
	$toclean =~ s/([[:alpha:]]{1}) 's$/$1's/g;
	
#	$toclean =~ s/([[:alpha:]]{1})#l-#/$1-/g;

	$toclean =~ s/<,>/#,#/g;
	$toclean =~ s/<,,>/#,,#/g;
	$toclean =~ s/<unclear> (.+) <\/unclear>/#..#/g;
	
#Special
	$toclean =~ s/<\*> greater than sign <\/\*>/>/g;
	$toclean =~ s/<\*> \'less than\' sign <\/\*>/</g;
	$toclean =~ s/<\*> less than sign <\/\*>/</g;
	$toclean =~ s/<\*> is less than sign <\/\*>/</g;
	$toclean =~ s/<\*> equals sign <\/\*>/=/g;

	$toclean =~ s/<\*> ampersand <\/\*>/\&/g;
	$toclean =~ s/<\*> ampsersand <\/\*>/\&/g;
	$toclean =~ s/<\*> ampersand <\*>/\&/g;
	
	$toclean =~ s/<\*> pound sign <\/\*>/£/g;
	$toclean =~ s/<\*> dollar sign <\/\*>/\$/g;

	$toclean =~ s/<\&> (.+) <\/\&>/#..#/g;
	$toclean =~ s/<\*> sigma <\/\*>/Σ/g;

	$toclean =~ s/<\*> per cent sign <\/\*>/\%/g;
	$toclean =~ s/<\*> per cent <\/\*>/\%/g;
	$toclean =~ s/<\*> per cent sign, <\/\*>/\%,/g;
	$toclean =~ s/<\*> plus sign <\/\*>/\+/g;
	$toclean =~ s/<\*> minus sign <\/\*>/\-/g;
	$toclean =~ s/<\*> alpha sign <\/\*>/α/g;
	$toclean =~ s/<\*> asterisk <\/\*>/\*/g;
	$toclean =~ s/<\*> three asterisk signs <\/\*>/\*\*\*/g;
	$toclean =~ s/<\*> hash sign <\/\*>/#/g;
	$toclean =~ s/<\*> agus sign <\/\*>/#\?#/g;

	$toclean =~ s/<\*> less than or equal to sign <\/\*>/≤/g;
	$toclean =~ s/<\*> alpha and delta sign <\/\*>/αΔ/g;
	$toclean =~ s/<\*> double alpha sign <\/\*>/αα/g;
	$toclean =~ s/<\*> inches sign <\/\*>/\'/g;
	$toclean =~ s/<\*> inch sign <\/\*>/\'/g;
	$toclean =~ s/<\*> delta sign <\/\*>/Δ/g;
	$toclean =~ s/<\*> delta <\/\*>/Δ/g;
	$toclean =~ s/<\*> degrees sign <\/\*>/°/g;
	$toclean =~ s/<\*> degree sign <\/\*>/°/g;
	$toclean =~ s/<\*> degree sign, <\/\*>/°,/g;
	$toclean =~ s/<\*> degrees centigrade sign <\/\*>/°C/g;
	$toclean =~ s/<\*> degrees centigrade <\/\*>/°C/g;

	$toclean =~ s/<\*> mu sign <\/\*>/μ/g;
	$toclean =~ s/<\*> mu <\/\*>/μ/g;
	
	$toclean =~ s/<\*> multiplication sign <\/\*>/·/g;
	$toclean =~ s/<\*> mulltiplication sign <\/\*>/·/g;
	
	$toclean =~ s/\&ccedille;/ç/g;
	$toclean =~ s/<\*> bullet point <\/\*>/--/g;
	$toclean =~ s/\&right-arrow;/->/g;

	$toclean =~ s/\&less-than;/</g;
	$toclean =~ s/\&smaller-than;/</g;

	$toclean =~ s/\&BETA;/Β/g;
	$toclean =~ s/\&omega;/ω/g;
	$toclean =~ s/\&Omega;/Ω/g;
	$toclean =~ s/<\*> plus or minus sign <\/\*>/±/g;
	$toclean =~ s/<\*> plus minus sign <\/\*>/±/g;

	$toclean =~ s/<\*> dash sign <\/\*>/--/g;
	$toclean =~ s/\&curved-dash;/--/g;
	$toclean =~ s/\&very-long-dash;/--/g;
	$toclean =~ s/\&square;/--/g;
	$toclean =~ s/\&arrowhead;/--/g;
	$toclean =~ s/\&dotted-line;/.../g;
	$toclean =~ s/\&Eacute;/É/g;
	$toclean =~ s/\&eacute;/é/g;
	$toclean =~ s/\&Ocircumflex;/Ô/g;
	$toclean =~ s/\&aumlaut;/ä/g;
	$toclean =~ s/\&Oacute;/Ò/g;

	$toclean =~ s/\&eumlaut;/ë/g;
	$toclean =~ s/\&uumlaut;/ü/g;
	$toclean =~ s/\&AEligature;/Æ/g;
	$toclean =~ s/\&double-arrow;/>>/g;
	$toclean =~ s/\&Beta;/Β/g;

	$toclean =~ s/\&black-square;/--/g;
	$toclean =~ s/\&dagger;/†/g;
	$toclean =~ s/\&caret;/^/g;
	$toclean =~ s/\&approximate-sign;/≈/g;
	$toclean =~ s/\&female;/♀/g;
	$toclean =~ s/\&arrow;/->/g;
	$toclean =~ s/\&oumlaut;/ö/g;
	$toclean =~ s/\&star;/\*/g;
	$toclean =~ s/<\*> beta sign <\/\*>/β/g;
	$toclean =~ s/\&oeligature;/œ/g;
	$toclean =~ s/\&down-arrow;/↓/g;
	$toclean =~ s/\&Angstrom;/Å/g;
	$toclean =~ s/\&larger-than;/>/g;
	$toclean =~ s/\&because-symbol;/>/g;
	$toclean =~ s/\&delta;/δ/g;

	$toclean =~ s/<\*> sign <\/\*>//g;
	$toclean =~ s/<([^>]+?)>//g;
	$toclean =~ s/ <\/p//;
	$toclean =~ s/<> //;
 	$toclean =~ s/\/\[>$//;
 	
	$toclean =~ s/\t\s+/\t/g;
	$toclean =~ s/\s+$//;
	
	$toclean =~ s/([ ]){2,5}/ /g;
#	$toclean =~ s/ +/ /g;
	
	return $toclean;
}

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
#	$splitted =~ s/([[:alpha:]]{1})(\'ll)(\s|\W)/$1 $2$3/gi;
#	$splitted =~ s/([[:alpha:]]{1})(\'ve)(\s|\W)/$1 $2$3/gi;
#	$splitted =~ s/([[:alpha:]]{1})(\'d)(\s|\W)/$1 $2$3/gi;
#	$splitted =~ s/([[:alpha:]]{1})(\'re)(\s|\W)/$1 $2$3/gi;

	$splitted =~ s/(^|\s|\W)(He|She|It|he|she|it|This|That|Who|There|How|What|Where|Here|Something|Everything|Anything|this|that|who|there|how|what|where|here|something|everything|anything)\'s(\s|\W)/$1$2 \'s$3/g;
	
	return $splitted;
}
