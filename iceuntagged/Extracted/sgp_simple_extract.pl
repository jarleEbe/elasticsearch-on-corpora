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
	if ($txt =~ /\.$ext/i)
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
#	$sentence = &cleanUp($sentence);
#	if ($sentence =~ /</ || $sentence =~ />/ || $sentence =~ /\&([^ ]+);/)
#	{
#		print LOG "$sentence\n";
#	}
	$sentence = &split_contractions($sentence);
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

sub cleanUp
{
	my $toclean = shift(@_);

	$toclean =~ s/<unclear>(.+)<\/unclear>/ \#\.\.\.\# /g;
	$toclean =~ s/<O>(.+)<\/O>/ \#\.\.\.\# /g;
	$toclean =~ s/<o>(.+)<\/O>/ \#\.\.\.\# /g;
	
	$toclean =~ s/<unclear> word$/\#\.\.\.\# /g;
	$toclean =~ s/^word <\/unclear>/ \#\.\.\.\# /g;

	$toclean =~ s/<O> laughter$/\#\.\.\.\# /g;
	$toclean =~ s/^laughter <\/O>/ \#\.\.\.\# /g;
	$toclean =~ s/^telephone rings <\/O>/ \#\.\.\.\# /;
	
	$toclean =~ s/<O> laughs/ \#\.\.\.\# /;
	$toclean =~ s/<\/O>//g;
	
	$toclean =~ s/<unclear>//g;
	$toclean =~ s/<\/unclear>//g;
	$toclean =~ s/<\/umclear>//g;
	
	$toclean =~ s/<h>//g;
	$toclean =~ s/<\/h>//g;
	
	$toclean =~ s/<p>//g;
	$toclean =~ s/<\/p>//g;
	
	$toclean =~ s/<it>//g;
	$toclean =~ s/<\/it>//g;

	$toclean =~ s/<foreign>//g;
	$toclean =~ s/<\/foreign>//g;

	$toclean =~ s/<smallcaps>//g;
	$toclean =~ s/<\/smallcaps>//g;
	
	$toclean =~ s/<I>//ig;
	$toclean =~ s/<\/I>//ig;

	$toclean =~ s/<X>//ig;
	$toclean =~ s/<\/X>//ig;
	
	$toclean =~ s/<w>//g;
	$toclean =~ s/<\/w>//g;
	
	$toclean =~ s/<bold>//g;
	$toclean =~ s/<\/bold>//g;
	
	$toclean =~ s/<mention>//g;
	$toclean =~ s/<\/mention>//g;
	
	$toclean =~ s/<sent>//g;
	$toclean =~ s/<\/sent>//g;
	
	$toclean =~ s/<hi>//g;
	$toclean =~ s/<\/hi>//g;

	$toclean =~ s/<\$([A-Z &]+?)>//g;

	$toclean =~ s/<\{>//g;
	$toclean =~ s/<\[>//g;
	$toclean =~ s/<\/\[>//g;
	$toclean =~ s/<\/\{>//g;
		
	$toclean =~ s/<\&>//g;
	$toclean =~ s/<\/\&>//g;

	$toclean =~ s/<\$>//g;
	$toclean =~ s/<\/\$>//g;
	
	$toclean =~ s/<\?>//g;
	$toclean =~ s/<\/\?>//g;
	
#Special
	$toclean =~ s/<> \/ \{ >//;
	$toclean =~ s/<\$A  <//;
	$toclean =~ s/<\$B  <//;
	$toclean =~ s/<SIGH>//;
	$toclean =~ s/<O> Research assistant's voice <\/O>/ \#\.\.\.\#/;
	$toclean =~ s/\&dolalr;/\$/;
	$toclean =~ s/\&hash;/\#/;
	$toclean =~ s/<\/h <>//;

	$toclean =~ s/<O>//;
		
	$toclean =~ s/<quote>/"/g;
	$toclean =~ s/<\/quote>/"/g;
	
	$toclean =~ s/\&dollar;/ £/g;
	$toclean =~ s/\&degree;/°/g;
	$toclean =~ s/\&cent;/¢/g;

	$toclean =~ s/^ +//;
	$toclean =~ s/<  >//;
	$toclean =~ s/<>//;
	$toclean =~ s/< £>//;
	$toclean =~ s/> $//;
	$toclean =~ s/^<//;
	$toclean =~ s/<\/h //;
	
#	$toclean =~ s/ $//;
	$toclean =~ s/([ ]){2,5}/ /g;
#	$toclean =~ s/  / /g;
	
#	$toclean =~ s/</\&lg;/g;
#	$toclean =~ s/>/\&gt;/g;
	
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
	$splitted =~ s/([[:alpha:]]{1})(\'ll)(\s|\W)/$1 $2$3/gi;
	$splitted =~ s/([[:alpha:]]{1})(\'ve)(\s|\W)/$1 $2$3/gi;
	$splitted =~ s/([[:alpha:]]{1})(\'d)(\s|\W)/$1 $2$3/gi;
	$splitted =~ s/([[:alpha:]]{1})(\'re)(\s|\W)/$1 $2$3/gi;

	$splitted =~ s/(^|\s|\W)(He|She|It|he|she|it|This|That|Who|There|How|What|Where|Here|Something|Everything|Anything|this|that|who|there|how|what|where|here|something|everything|anything)\'s(\s|\W)/$1$2 \'s$3/g;
	
	return $splitted;
}
