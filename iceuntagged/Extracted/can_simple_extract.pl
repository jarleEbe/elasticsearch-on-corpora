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
#	$sentence = &cleanUp($sentence);
#	if ($sentence =~ /</ || $sentence =~ />/ || $sentence =~ /\&([^ ]+);/)
#	{
#		print LOG "2: $sentence\n";
#	}
	$sentence = &split_contractions($sentence);
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

sub cleanUp
{
	my $toclean = shift(@_);

	$toclean =~ s/<unclear>(.+)<\/unclear>/ \#\.\.\.\# /g;
	$toclean =~ s/<O>(.+)<\/O>/ \#\.\.\.\# /g;
#	$toclean =~ s/<o>(.+)<\/O>/ \#\.\.\.\# /g;
	
	$toclean =~ s/<unclear> word$/\#\.\.\.\# /g;
	$toclean =~ s/^word <\/unclear>/ \#\.\.\.\# /g;

	$toclean =~ s/<O> laughter$/\#\.\.\.\# /g;
	$toclean =~ s/^laughter <\/O>/ \#\.\.\.\# /g;
	$toclean =~ s/^laugh <\/O>/ \#\.\.\.\# /g;
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

	$toclean =~ s/<l>//g;
	$toclean =~ s/<\/l>//g;
	
	$toclean =~ s/<it>//g;
	$toclean =~ s/<\/it>//g;

	$toclean =~ s/<bold>//g;
	$toclean =~ s/<\/bold>//g;
	
	$toclean =~ s/<foreign>//g;
	$toclean =~ s/<\/foreign>//g;

	$toclean =~ s/<indig>//g;
	$toclean =~ s/<\/indig>//g;
	
	$toclean =~ s/<smallcaps>//g;
	$toclean =~ s/<\/smallcaps>//g;
	
	$toclean =~ s/<I>//ig;
	$toclean =~ s/<\/I>//ig;

	$toclean =~ s/<X>//ig;
	$toclean =~ s/<\/X>//ig;

	$toclean =~ s/<ul>//g;
	$toclean =~ s/<\/ul>//g;
	
	$toclean =~ s/<del>//g;
	$toclean =~ s/<\/del>//g;
	
	$toclean =~ s/<fnr>//g;
	$toclean =~ s/<\/fnr>//g;
	
	$toclean =~ s/<sp>//g;
	$toclean =~ s/<\/sp>//g;

	$toclean =~ s/<sb>//g;
	$toclean =~ s/<\/sb>//g;
	
	$toclean =~ s/<footnote>//g;
	$toclean =~ s/<\/footnote>//g;
	$toclean =~ s/<footnote\/>//g;
	
	$toclean =~ s/<w>//g;
	$toclean =~ s/<\/w>//g;
	
	$toclean =~ s/<bold>//g;
	$toclean =~ s/<\/bold>//g;
	
	$toclean =~ s/<mention>//g;
	$toclean =~ s/<\/mention>//g;
	
	$toclean =~ s/<space>//g;
	$toclean =~ s/<\/space>//g;

	$toclean =~ s/<marginalia>//g;
	$toclean =~ s/<\/marginalia>//g;
	
	$toclean =~ s/<typeface:([^>]+?)>//g;
	$toclean =~ s/<\/typeface:([^>]+?)>//g;
	
	$toclean =~ s/<typeface>//g;
	$toclean =~ s/<\/typeface>//g;
	
	$toclean =~ s/<sent>//g;
	$toclean =~ s/<\/sent>//g;
	
	$toclean =~ s/<hi>//g;
	$toclean =~ s/<\/hi>//g;

	$toclean =~ s/\&ccedille;/ç/g;
	$toclean =~ s/\&ccedilla;/ç/g;
	
	$toclean =~ s/\&Eacute;/É/g;
	$toclean =~ s/\&eacute;/é/g;
	$toclean =~ s/\&egrave;/è/g;	
	$toclean =~ s/\&aacute;/á/g;
	$toclean =~ s/\&iacute;/í/g;
	$toclean =~ s/\&agrave;/à/g;
	$toclean =~ s/\&Agrave;/À/g;
	$toclean =~ s/\&ugrave;/ù/g;

	$toclean =~ s/\&auml;/ä/g;
	$toclean =~ s/\&ouml;/ö/g;
	$toclean =~ s/\&Ouml;/Ö/g;
	$toclean =~ s/\&iuml;/ï/g;
	$toclean =~ s/\&uuml;/ü/g;
	$toclean =~ s/\&euml;/ë/g;
	
	$toclean =~ s/\&Ocircumflex;/Ô/g;
	$toclean =~ s/\&ocircumflex;/ô/g;
	$toclean =~ s/\&acircumflex;/â/g;
	$toclean =~ s/\&ecircumflex;/ê/g;
	$toclean =~ s/\&icircumflex;/î/g;
	$toclean =~ s/\&ucircumflex;/û/g;
	$toclean =~ s/\&Acircumflex;/Â/g;
	$toclean =~ s/\&Icircumflex;/Î/g;
	$toclean =~ s/\&utilde;/ũ/g;
	$toclean =~ s/\&ntilde;/ñ/g;
	
	$toclean =~ s/\&oeligature;/œ/g;
	$toclean =~ s/\&aeligature;/æ/g;
	
	$toclean =~ s/\&aumlaut;/ä/g;
	$toclean =~ s/\&Oacute;/Ò/g;
	$toclean =~ s/\&eumlaut;/ë/g;
	$toclean =~ s/\&oumlaut;/ö/g;
	$toclean =~ s/\&uumlaut;/ü/g;
	$toclean =~ s/\&AEligature;/Æ/g;
	$toclean =~ s/\&oumlaut;/ö/g;
	$toclean =~ s/\&numl;/¨n/g;

	$toclean =~ s/\&alpha;/α/g;	
	$toclean =~ s/\&mu;/μ/g;
	$toclean =~ s/\&gamma;/γ/g;
	$toclean =~ s/\&theta;/θ/g;
	$toclean =~ s/\&BETA;/Β/g;
	$toclean =~ s/\&omega;/ω/g;
	$toclean =~ s/\&Omega;/Ω/g;
	$toclean =~ s/\&Delta;/Δ/g;
	$toclean =~ s/\&DELTA;/Δ/g;	
	$toclean =~ s/\&Beta;/Β/g;
	$toclean =~ s/\&delta;/δ/g;
	
	$toclean =~ s/\&pound-sign;/£/g;
	$toclean =~ s/\&dollar;/\$/g;
	$toclean =~ s/\&amp;/\&/g;
	$toclean =~ s/\&bullet;/--/g;
	$toclean =~ s/\&right-arrow;/->/g;
	$toclean =~ s/\&degree;/°/g;
	$toclean =~ s/\&less-than;/</g;
	$toclean =~ s/\&smaller-than;/</g;

	$toclean =~ s/&circle;/°/g;

	$toclean =~ s/\&plus-or-minus;/±/g;
	$toclean =~ s/\&long-dash;/--/g;
	$toclean =~ s/\&curved-dash;/--/g;
	$toclean =~ s/\&very-long-dash;/--/g;
	$toclean =~ s/\&square;/--/g;
	$toclean =~ s/\&arrowhead;/--/g;
	$toclean =~ s/\&dotted-line;/.../g;

	$toclean =~ s/\&double-arrow;/>>/g;

	$toclean =~ s/\&dot;/·/g;
	$toclean =~ s/\&black-square;/--/g;
	$toclean =~ s/\&dagger;/†/g;
	$toclean =~ s/\&caret;/^/g;
	$toclean =~ s/\&approximate-sign;/?/g;
	$toclean =~ s/\&female;/?/g;
#	$toclean =~ s/\&arrow;/->/g;
	$toclean =~ s/\&star;/\*/g;
	$toclean =~ s/\&beta;/β/g;

	$toclean =~ s/\&down-arrow;/>/g;
	$toclean =~ s/\&Angstrom;/Å/g;
	$toclean =~ s/\&larger-than;/>/g;
	$toclean =~ s/\&because-symbol;/>/g;

	$toclean =~ s/\&cent;/¢/g;
	$toclean =~ s/&circumflex;/û/g;
	
	$toclean =~ s/<\$([A-Z &]+?)>//g;
	
	$toclean =~ s/<([A-Z]{1,1})>//g;
	$toclean =~ s/<([0-9]{1,1})>//g;

	$toclean =~ s/<\/([A-Z]{1,1})>//g;
	$toclean =~ s/<\/([0-9]{1,1})>//g;
	
	$toclean =~ s/<,>/#,#/g;
	$toclean =~ s/<\.,>/#\.,#/g;
	
	$toclean =~ s/<,,>/#,,#/g;
	$toclean =~ s/<,,,>/#,,,#/g;

	$toclean =~ s/\/ \[ >//g;
	$toclean =~ s/\/ \- >//g;
	
	$toclean =~ s/<\{>//g;
	$toclean =~ s/<\}>//g;
	
	$toclean =~ s/<\->//g;
	
	$toclean =~ s/<\[>//g;
	
	$toclean =~ s/<\/\[>//g;
	
	$toclean =~ s/<\/\{>//g;

	$toclean =~ s/<\{(\d+?)>//g;
	$toclean =~ s/<\}(\d+?)>//g;
	$toclean =~ s/<\[(\d+?)>//g;
	$toclean =~ s/<\/\[(\d+?)>//g;
	$toclean =~ s/<\/\{(\d+?)>//g;
		
	$toclean =~ s/<(\d+?)\{>//g;
	$toclean =~ s/<(\d+?)\}>//g;
		
	$toclean =~ s/<\/->//g;

	$toclean =~ s/<\/ \[ >//g;
	$toclean =~ s/<\/ - >//g;
	
	$toclean =~ s/<\/\[>//g;
	$toclean =~ s/<\/\}>//g;
	
	$toclean =~ s/< \} >//g;
	$toclean =~ s/<\/\}>//g;
	
	$toclean =~ s/<\/\)>//g;
	
	$toclean =~ s/<=>//g;
	$toclean =~ s/<\/=>//g;
	$toclean =~ s/<\/\}>//g;
		
	$toclean =~ s/<\?>//g;
	$toclean =~ s/<\/\?>//g;
	
	$toclean =~ s/<\&>//g;
	$toclean =~ s/<\/\&>//g;

	$toclean =~ s/<\$>//g;
	$toclean =~ s/<\/\$>//g;
	
	$toclean =~ s/<\@>//g;
	$toclean =~ s/<\/\@>//g;
		
	$toclean =~ s/<\+>//g;
	$toclean =~ s/<\/\+>//g;

	$toclean =~ s/<=\+>//g;
	$toclean =~ s/<\/=\+>//g;
	
	$toclean =~ s/<\?>//g;
	$toclean =~ s/<\/\?>//g;
	
	$toclean =~ s/<\.>//g;
	$toclean =~ s/<\/\.>//g;
	
	$toclean =~ s/<O> Research assistant's voice <\/O>/ \#\.\.\.\#/;
	$toclean =~ s/\&hash;/\#/;

	$toclean =~ s/<O>//;

	$toclean =~ s/<quote>/"/g;
	$toclean =~ s/<\/quote>/"/g;

	$toclean =~ s/([=\\\/@\[<>\)\(\}\{\]\+]{2,})//g;
	
	$toclean =~ s/([A-Za-z0-9\"]+)>/$1/g;
	$toclean =~ s/<([A-Za-z0-9]+)/$1/g;
	$toclean =~ s/>([A-Za-z0-9]+)/$1/g;
	
	$toclean =~ s/\/\->//g;
	$toclean =~ s/<\-//g;
	$toclean =~ s/\{ >//g;
	$toclean =~ s/< \} >//g;
	$toclean =~ s/2\[>//g;
	$toclean =~ s/\/>//g;
	
	$toclean =~ s/\&lt;/</g;
	$toclean =~ s/\&gt;/>/g;
	
	$toclean =~ s/([ ]+)$//;
	$toclean =~ s/^([ ]+)//;
	
	$toclean =~ s/([ ]){2,5}/ /g;
	
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
