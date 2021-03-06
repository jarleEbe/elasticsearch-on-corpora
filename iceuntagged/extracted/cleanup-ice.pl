#!C:\Perl64\bin\perl.exe -w

use strict;
use utf8;

my ($input, $output, $whichICE, $logfile) = @ARGV;

my $num_files = 0;
open(LOG, ">>$logfile");
open(INN, $input);
my @content = <INN>;
close(INN);
open(OUT, ">$output");
binmode OUT, ":utf8";
foreach my $line (@content)
{
	chomp($line);
	$line = &cleanUp($line);
	if ($whichICE eq 'SGP')
	{
		$line = &SGPclean($line);
	}
	elsif ($whichICE eq 'GBR')
	{
		$line = &GBRclean($line);
	}
	elsif ($whichICE eq 'IND')
	{
		$line = &INDclean($line);
	}
	elsif ($whichICE eq 'IRL')
	{
		$line = &IRLclean($line);
	}
	elsif ($whichICE eq 'CAN')
	{
		$line = &CANclean($line);
	}
	elsif ($whichICE eq 'NZL')
	{
		$line = &NZLclean($line);
	}
	elsif ($whichICE eq 'PHL')
	{
		$line = &PHLclean($line);
	}
	elsif ($whichICE eq 'HKG')
	{
		$line = &HKGclean($line);
	}
	else
	{
		print "UNknown ICE: $whichICE\n";	
	}
	
	if ($line =~ /<([A-Za-z0-9])+?>/ || $line =~ /\&([^;]{1,20});/ || $line =~ /#([A-Za-z0-9]+?)#/)
	{
		print LOG "$line\n";
	}
	
	print OUT "$line\n";
	
}
close(OUT);
close(LOG);
print "Check log file $logfile\n";
exit;

sub cleanUp
{
	my $toclean = shift(@_);

	$toclean =~ s/<unclear>(.+)<\/unclear>/ \#\.\.\.\# /ig;
	$toclean =~ s/<O>(.+)<\/O>/ \#\.\.\.\# /ig;
	
	$toclean =~ s/<h>//g;
	$toclean =~ s/<\/h>//g;
	
	$toclean =~ s/<p>//g;
	$toclean =~ s/<\/p>//g;
	
	$toclean =~ s/<foreign>//g;
	$toclean =~ s/<\/foreign>//g;
	$toclean =~ s/<foreign\/>//g;

	$toclean =~ s/<l>//g;
	$toclean =~ s/<\/l>//g;
	
	$toclean =~ s/<it>//g;
	$toclean =~ s/<\/it>//g;

	$toclean =~ s/<italics>//g;
	$toclean =~ s/<\/italics>//g;
	
	$toclean =~ s/<italic>//g;
	$toclean =~ s/<\/italic>//g;
	
	$toclean =~ s/<bold>//g;
	$toclean =~ s/<\/bold>//g;
	
	$toclean =~ s/<b>//g;
	$toclean =~ s/<\/b>//g;
	
	$toclean =~ s/<indig>//g;
	$toclean =~ s/<\/indig>//g;

	$toclean =~ s/<roman>//g;
	$toclean =~ s/<\/roman>//g;
	
	$toclean =~ s/<call-out>//g;
	$toclean =~ s/<\/call-out>//g;

	$toclean =~ s/<logo>//g;
	$toclean =~ s/<\/logo>//g;
	
	$toclean =~ s/<smallcaps>//g;
	$toclean =~ s/<\/smallcaps>//g;
	
	$toclean =~ s/<caption>//g;
	$toclean =~ s/<\/caption>//g;

	$toclean =~ s/<smallcaps>//g;
	$toclean =~ s/<\/smallcaps>//g;
	
	$toclean =~ s/<I>//ig;
	$toclean =~ s/<\/I>//ig;

	$toclean =~ s/<X>//ig;
	$toclean =~ s/<\/X>//ig;

	$toclean =~ s/<ul>//g;
	$toclean =~ s/<\/ul>//g;
	
	$toclean =~ s/<fnr>//g;
	$toclean =~ s/<\/fnr>//g;
	
	$toclean =~ s/<sp>//g;
	$toclean =~ s/<\/sp>//g;

	$toclean =~ s/<sb>//g;
	$toclean =~ s/<\/sb>//g;
	
	$toclean =~ s/<footnote>//g;
	$toclean =~ s/<\/footnote>//g;
	$toclean =~ s/<footnote\/>//g;

	$toclean =~ s/<word>//g;
	$toclean =~ s/<\/word>//g;
	
	$toclean =~ s/<lit>//g;
	$toclean =~ s/<\/lit>//g;
	
	$toclean =~ s/<w>//g;
	$toclean =~ s/<\/w>//g;
	
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
	$toclean =~ s/\&EACUTE;/É/g;
	
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
	$toclean =~ s/\&acirc;/â/g;
	$toclean =~ s/\&ecircumflex;/ê/g;
	$toclean =~ s/\&icircumflex;/î/g;
	$toclean =~ s/\&ucircumflex;/û/g;
	$toclean =~ s/\&Acircumflex;/Â/g;
	$toclean =~ s/\&Icircumflex;/Î/g;
	$toclean =~ s/\&utilde;/ũ/g;
	$toclean =~ s/\&ntilde;/ñ/g;
	$toclean =~ s/\&Ntilde;/Ñ/g;
	
	$toclean =~ s/\&oeligature;/œ/g;
	$toclean =~ s/\&aeligature;/æ/g;
	$toclean =~ s/\&aelig;/æ/g;
	$toclean =~ s/\&oslash;/ø/g;
	$toclean =~ s/\&aring;/å/g;
	
	$toclean =~ s/\&aumlaut;/ä/g;
	$toclean =~ s/\&Oacute;/Ò/g;
	$toclean =~ s/\&eumlaut;/ë/g;
	$toclean =~ s/\&iumlaut;/ï/g;
	$toclean =~ s/\&oumlaut;/ö/g;
	$toclean =~ s/\&uumlaut;/ü/g;
	$toclean =~ s/\&AEligature;/Æ/g;
	$toclean =~ s/\&oumlaut;/ö/g;
	$toclean =~ s/\&numl;/¨n/g;
	
	$toclean =~ s/\&amacron;/ā/g;
	$toclean =~ s/\&emacron;/ē/g;
	$toclean =~ s/\&imacron;/ī/g;
	$toclean =~ s/\&omacron;/ō/g;
	$toclean =~ s/\&umacron;/ū/g;
	$toclean =~ s/\&rmacron;/r̄/g;

	$toclean =~ s/\&thorn;/þ/g;
	
	$toclean =~ s/\&iexcl;/¡/g;

	$toclean =~ s/\&alpha;/α/g;	
	$toclean =~ s/\&mu;/μ/g;
	$toclean =~ s/\&GAMMA;/Γ/g;
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
	$toclean =~ s/\&pound;/£/g;
	$toclean =~ s/\&dollar;/\$/g;
	$toclean =~ s/\&amp;/\&/g;
	$toclean =~ s/\&bullet;/--/g;
	$toclean =~ s/\&right-arrow;/->/g;
	$toclean =~ s/\&degree;/°/g;
	$toclean =~ s/\&deg;/°/g;
	$toclean =~ s/\&less-than;/</g;
	$toclean =~ s/\&smaller-than;/</g;
	$toclean =~ s/\&greater-than;/</g;

	$toclean =~ s/&circle;/°/g;

	$toclean =~ s/\&plus-or-minus;/±/g;
	$toclean =~ s/\&minus;/÷/g;
	$toclean =~ s/\&plusmn;/±/g;
	$toclean =~ s/\&long-dash;/--/g;
	$toclean =~ s/\&curved-dash;/--/g;
	$toclean =~ s/\&very-long-dash;/--/g;
	$toclean =~ s/\&square;/--/g;
	$toclean =~ s/\&arrowhead;/--/g;
	$toclean =~ s/\&dotted-line;/.../g;

	$toclean =~ s/\&double-arrow;/->>/g;

	$toclean =~ s/\&dot;/·/g;
	$toclean =~ s/\&times;/·/g;
	$toclean =~ s/\&black-square;/--/g;
	$toclean =~ s/\&dagger;/†/g;
	$toclean =~ s/\&caret;/^/g;
	$toclean =~ s/\&approximate-sign;/?/g;
	$toclean =~ s/\&female;/#.#/g;
	$toclean =~ s/\&arrow;/->/g;
	$toclean =~ s/\&star;/\*/g;
	$toclean =~ s/\&beta;/β/g;

	$toclean =~ s/\&down-arrow;/->/g;
	$toclean =~ s/\&Angstrom;/Å/g;
	$toclean =~ s/\&larger-than;/>/g;
	$toclean =~ s/\&because-symbol;/\∵/g;
	$toclean =~ s/\&square-root;/√/g;
	$toclean =~ s/\&hash;/#/g;
	
	$toclean =~ s/\&copyright;/©/g;

	$toclean =~ s/\&cent;/¢/g;
	$toclean =~ s/\&centavo;/¢/g;
	$toclean =~ s/\&yen;/¥/g;
	
	$toclean =~ s/\&lt;/</g;
	$toclean =~ s/\&gt;/>/g;
	
	$toclean =~ s/<\{([0-9]{1,1})>/<\{#>/g;
	$toclean =~ s/<\[([0-9]{1,1})>/<\[#>/g;
	$toclean =~ s/<\/\{([0-9]{1,1})>/<\/\{#>/g;
	$toclean =~ s/<\/\[([0-9]{1,1})>/<\/\[<#>/g;

	$toclean =~ s/<([0-9]{1,1})>/<#>/g;
	$toclean =~ s/<\/([0-9]{1,1})>/<\/#>/g;
	
	$toclean =~ s/([ ]+)$//;
	$toclean =~ s/^([ ]+)//;
	$toclean =~ s/\t([ ]+)/\t/;
	
	$toclean =~ s/([ ]){2,5}/ /g;
	
	return $toclean;
}

sub PHLclean
{
	my $toclean = shift(@_);

#	$toclean =~ s/<O>(.+)<O>/ \#\.\.\.\# /g;
	$toclean =~ s/<O>(.+)<\/O/ \#\.\.\.\# /g;
	$toclean =~ s/<del>(.+)<\/del>/#\.\.#/g;
	$toclean =~ s/<del>(.+)<\/del\->/#\.\.#/g;
	$toclean =~ s/<delete>(.+)<\/delete>/#\.\.#/g;
	$toclean =~ s/<delete> young children <\/>/#\.\.#/;
	$toclean =~ s/<\&>(.+)<\/\&>/#\.\.#/g;

	$toclean =~ s/<unclear>(.+)<unclear>/ \#\.\.\.\# /ig;
	$toclean =~ s/<unclear>(.+)<\/unclear\.>/ \#\.\.\.\# /g;
	$toclean =~ s/<unclear> 1 word <\/unclear//;
	
	$toclean =~ s/<O>//g;
	$toclean =~ s/<\/O>//g;
	
	$toclean =~ s/<indig=([^>]+?)>//g;
	$toclean =~ s/<\/indig=([^>]+?)>//g;
	
	$toclean =~ s/<indig>//g;
	$toclean =~ s/<\/indig>//g;
	$toclean =~ s/<Indig>//g;
	$toclean =~ s/<indi>//;
	
	$toclean =~ s/<indigo>//g;
	$toclean =~ s/<\/indigo>//g;
	
	$toclean =~ s/<\$([^>]+?)>//g;
	
	$toclean =~ s/<130>/#.#/;
	
	$toclean =~ s/<quote>//g;
	$toclean =~ s/<\/quote>//g;

	$toclean =~ s/\&ldquo;/"/g;
	$toclean =~ s/\&rdquo;/"/g;
	
	$toclean =~ s/\&peso;/₱/g;
	$toclean =~ s/\&ntidle;/ñ/g;
	
	$toclean =~ s/([ ]){2,5}/ /g;
	
	return $toclean;
}


sub HKGclean
{
	my $toclean = shift(@_);

	$toclean =~ s/<O>(.+)<\/O/ \#\.\.\.\# /g;
	$toclean =~ s/<unc>(.+)<\/unc>/#\.\.#/g;
	$toclean =~ s/<del>(.+)<\/del>/#\.\.#/g;
	$toclean =~ s/<\&>(.+)<\/\&>/#\.\.#/g;

	$toclean =~ s/<unc>(.+)<unc>/#\.\.#/g;
	
	$toclean =~ s/<O>//g;
	$toclean =~ s/<\/O>//g;
	
	$toclean =~ s/<UL>//g;
	$toclean =~ s/<\/UL>//g;
	
	$toclean =~ s/<It>//g;
	
	$toclean =~ s/<indig=([^>]+?)>//g;
	$toclean =~ s/<\/indig=([^>]+?)>//g;
	
	$toclean =~ s/<indig>//g;
	$toclean =~ s/<\/indig>//g;
	
	$toclean =~ s/<Indig>//g;
	$toclean =~ s/<del>//g;
	
	$toclean =~ s/<\$([^>]+?)>//g;
	
	$toclean =~ s/<quote>//g;
	$toclean =~ s/<\/quote>//g;

	$toclean =~ s/<symbol> because <\/symbol>/\∵/;
	
	$toclean =~ s/<unc> several words <\/uinclear>//;
	$toclean =~ s/<unc> one-word \/ unclear>//;
	$toclean =~ s/<unc> one-word//;
	
	$toclean =~ s/<unc>//g;
	
	$toclean =~ s/\&ldquo;/"/g;
	$toclean =~ s/\&ldquuo;/"/;
	$toclean =~ s/\&rdquo;/"/g;
	$toclean =~ s/\&rsdquo;/"/g;
	$toclean =~ s/\&rqduo;/"/g;
	
	$toclean =~ s/\&lsquo;/'/g;
	$toclean =~ s/\&rsquo;/'/g;
	
	$toclean =~ s/\&obrack;/\(/g;
	$toclean =~ s/\&cbrack;/\)/g;
	$toclean =~ s/\&crback;/\)/;

	$toclean =~ s/\&dash;/\-\-/g;

	$toclean =~ s/\&longdash;/\-\-/g;
	$toclean =~ s/\&swung-dash;/\-\-/g;
	$toclean =~ s/\&swungdash;/\-\-/g;
	$toclean =~ s/\&asterisk;/\*/g;
	$toclean =~ s/\&ampersand;/\&/g;
	$toclean =~ s/\&atsign;/\&/g;
	$toclean =~ s/\&percent;/\%/g;
	$toclean =~ s/\&semi;/;/g;
	$toclean =~ s/\&scol;/;/g;
	$toclean =~ s/\&equals;/\=/g;
	$toclean =~ s/\&plus;/\+/g;
	$toclean =~ s/\&squared;/²/g;
	$toclean =~ s/\&bidirectional-arrow;/<-->/;
	
	$toclean =~ s/\&esszett;/ß/g;
	$toclean =~ s/N\&tilde;/Ñ/g;
	
	$toclean =~ s/<A>//;
	$toclean =~ s/<B>//;
	$toclean =~ s/<Z>//;
	$toclean =~ s/<Z1>//;
	$toclean =~ s/<Z2>//;
	
	$toclean =~ s/([ ]){2,5}/ /g;
	
	return $toclean;
}

sub CANclean
{
	my $toclean = shift(@_);

	$toclean =~ s/<O>(.+)<O>/ \#\.\.\.\# /g;
	$toclean =~ s/<O>(.+)<\/O/ \#\.\.\.\# /g;
	$toclean =~ s/<unclear>(.+)<\/unclear/ \#\.\.\.\# /ig;
	$toclean =~ s/<unclear> phrase\/unclear>/ \#\.\.\.\# /ig;
	$toclean =~ s/<del>(.+)<\/del>/#\.\.#/g;
	$toclean =~ s/<\&>(.+)<\/\&>/#\.\.#/g;

	$toclean =~ s/<O>//g;
	$toclean =~ s/<\/O>//g;
	
	$toclean =~ s/<A>//g;
	$toclean =~ s/<B>//g;
	$toclean =~ s/<P>//g;
	$toclean =~ s/<BA>//g;

	$toclean =~ s/<0> rest of paragraph <0>//;
	
	$toclean =~ s/<quote>//g;
	$toclean =~ s/<\/quote>//g;
	
	$toclean =~ s/&circumflex;/û/g;

	$toclean =~ s/([ ]){2,5}/ /g;
	
	return $toclean;
}

sub NZLclean
{
	my $toclean = shift(@_);

	$toclean =~ s/<O>(.+)<O>/ \#\.\.\.\# /g;
	$toclean =~ s/<O>(.+)<\/O/ \#\.\.\.\# /g;
	$toclean =~ s/<del>(.+)<\/del>/#\.\.#/g;
#	$toclean =~ s/<\&>(.+)<\/\&>/#\.\.#/g;

	$toclean =~ s/<indig=([^>]+?)>//g;
	$toclean =~ s/<\/indig=([^>]+?)>//g;
	
	$toclean =~ s/<voice=([^>]+?)>//g;
	$toclean =~ s/<\/voice=([^>]+?)>//g;
	
	$toclean =~ s/<laugh=([^>]+?)>//g;
	$toclean =~ s/<\/laugh=([^>]+?)>//g;
	
	$toclean =~ s/<yawns>//g;
	$toclean =~ s/<\/yawns>//g;
	
	$toclean =~ s/<quietly>//g;
	$toclean =~ s/<\/quietly>//g;
	
	$toclean =~ s/<whispers>//g;
	$toclean =~ s/<\/whispers>//g;
	
	$toclean =~ s/<drawls>//g;
	$toclean =~ s/<\/drawls>//g;
	
	$toclean =~ s/<laughs>//g;
	$toclean =~ s/<\/laughs>//g;

	$toclean =~ s/<softly>//g;
	$toclean =~ s/<\/softly>//g;
	
	$toclean =~ s/<loudly>//g;
	$toclean =~ s/<\/loudly>//g;

	$toclean =~ s/<reads>//g;
	$toclean =~ s/<\/reads>//g;

	$toclean =~ s/<quickly>//g;
	$toclean =~ s/<\/quickly>//g;

	$toclean =~ s/<groans>//g;
	$toclean =~ s/<\/groans>//g;

	$toclean =~ s/<imitates>//g;
	$toclean =~ s/<\/imitates>//g;

	$toclean =~ s/<quotes>//g;
	$toclean =~ s/<\/quotes>//g;

	$toclean =~ s/<slowly>//g;
	$toclean =~ s/<\/slowly>//g;
	
	$toclean =~ s/<sings>//g;
	$toclean =~ s/<\/sings>//g;
	
	$toclean =~ s/<sighs>//g;
	$toclean =~ s/<\/sighs>//g;

	$toclean =~ s/<mockingly>//g;
	$toclean =~ s/<\/mockingly>//g;

	$toclean =~ s/<title>//g;
	$toclean =~ s/<\/title>//g;
	
	$toclean =~ s/<indent>//g;
	$toclean =~ s/<\/indent>//g;
	
	$toclean =~ s/<music>//g;
	$toclean =~ s/<\/music>//g;
	
	$toclean =~ s/<shouts>//g;
	$toclean =~ s/<\/shouts>//g;
	
	$toclean =~ s/<exhales>//g;
	$toclean =~ s/<\/exhales>//g;
	
	$toclean =~ s/<cheering>//g;
	$toclean =~ s/<\/cheering>//g;
	
	$toclean =~ s/<facetiously>//g;
	$toclean =~ s/<\/facetiously>//g;
	
	$toclean =~ s/<sarcastically>//g;
	$toclean =~ s/<\/sarcastically>//g;
	
	$toclean =~ s/<clapping>//g;
	$toclean =~ s/<\/clapping>//g;
	
	$toclean =~ s/<centre>//g;
	$toclean =~ s/<\/centre>//g;
	
	$toclean =~ s/<inhales>//g;
	$toclean =~ s/<\/inhales>//g;
	
	$toclean =~ s/<recites>//g;
	$toclean =~ s/<\/recites>//g;
	
	$toclean =~ s/<shrieks>//g;
	$toclean =~ s/<\/shrieks>//g;
	
	$toclean =~ s/<mouthful>//g;
	$toclean =~ s/<\/mouthful>//g;
	
	$toclean =~ s/<pleads>//g;
	$toclean =~ s/<\/pleads>//g;
	
	$toclean =~ s/<mumbles>//g;
	$toclean =~ s/<\/mumbles>//g;
	
	$toclean =~ s/<quote>//g;
	$toclean =~ s/<\/quote>//g;
	
	$toclean =~ s/<accent>//g;
	$toclean =~ s/<\/accent>//g;
	
	$toclean =~ s/<stutters>//g;
	$toclean =~ s/<\/stutters>//g;
	
	$toclean =~ s/<enthusiastically>//g;
	$toclean =~ s/<\/enthusiastically>//g;
	
	$toclean =~ s/<del>(.+)<\/del/#\.\.#/g;

	$toclean =~ s/\&spade;/♠/g;
	$toclean =~ s/\&diamond;/♦/g;
	$toclean =~ s/\&club;/♣/g;
	$toclean =~ s/\&heart;/♥/g;
	
	$toclean =~ s/\&semi;/;/g;
	$toclean =~ s/\&smileyface;/:)/g;
	$toclean =~ s/\&infinity;/\~/g;
	$toclean =~ s/\&gdot;/ġ/g;
	$toclean =~ s/\&prime;/\'/g;
	$toclean =~ s/\&therefore;/∴/g;
	
	$toclean =~ s/\&divide;/\//g;
	$toclean =~ s/\&approx;/≅/g;
	
	$toclean =~ s/<l\^>//g;
	$toclean =~ s/<space\^>//g;
	
	$toclean =~ s/<\/bold//;

	$toclean =~ s/\&lteq;/≤/g;
	$toclean =~ s/\&gteq;/≥/g;
	
	$toclean =~ s/([ ]){2,5}/ /g;
	
	return $toclean;
}


sub SGPclean
{
	my $toclean = shift(@_);

	$toclean =~ s/<unclear> word <unclear>//g;
	$toclean =~ s/<unclear> word <\/umclear>//;
	$toclean =~ s/<O> laughs //;
	
	$toclean =~ s/<SIGH>//g;
	
	$toclean =~ s/<quote>/\"/g;
	$toclean =~ s/<\/quote>/\"/g;
	
	$toclean =~ s/\&dolalr;/\$/;
	$toclean =~ s/ <unclear>$/\$/;

	return $toclean;
}

sub GBRclean
{
	my $toclean = shift(@_);
	
	$toclean =~ s/([[:alpha:]]{1}) 's /$1's /g;
	$toclean =~ s/([[:alpha:]]{1}) 's$/$1's/g;
	
	$toclean =~ s/([[:alpha:]]{1})#l-#/$1-/g;

	$toclean =~ s/#sb#//g;
	
	$toclean =~ s/#([A-Za-z]+?)#/#\.\.\.#/g;
		
#	$toclean =~ s/#laughter#/#\.\.#/g;
#	$toclean =~ s/#laughs/#\.\.#/g;
#	$toclean =~ s/#laugh/#\.\.#/g;

#	$toclean =~ s/#unclear-words#/#\.\.#/g;
#	$toclean =~ s/#unclear-syllables#/#\.\.#/g;
#	$toclean =~ s/#unclear-word#/#\.\.#/g;
#	$toclean =~ s/#unclear-syllable#/#\.\.#/g;
#	$toclean =~ s/#unclear-characters#/#\.\.#/g;
#	$toclean =~ s/#unclear-character#/#\.\.#/g;
#	$toclean =~ s/#unclear-sentence#/#\.\.\.#/g;
#	$toclean =~ s/#unclear-discussion#/#\.\.#/g;
#	$toclean =~ s/#unclear#/#\.\.\.#/g;
	
	$toclean =~ s/‹/</;

	return $toclean;
}

sub INDclean
{
	my $toclean = shift(@_);

	$toclean =~ s/<\&>(.+)<\/\&>/ \#\.\.\.\# /g;
	$toclean =~ s/<\*>(.+)<\/\*>/ \#\.\.\.\# /g;
	
	$toclean =~ s/<O>(.+)<\/\&>/ \#\.\.\.\# /g;
	$toclean =~ s/<O>(.+)<O>/ \#\.\.\.\# /g;
	
	$toclean =~ s/<del>(.+)<\/del>/#\.\.#/g;
	
	$toclean =~ s/<indig=([^>]+?)>//g;
	$toclean =~ s/<\/indig=([^>]+?)>//g;
	$toclean =~ s/<\/ndig>//g;
	
	$toclean =~ s/<indi=([^>]+?)>//g;
	$toclean =~ s/<\/indi=([^>]+?)>//g;
	$toclean =~ s/<\/indi>//g;
	
	$toclean =~ s/<box>//g;
	$toclean =~ s/<Bold>//g;
	
	if ($toclean =~ /^ICE-IND:S/)
	{
		$toclean =~ s/<quote>/\"/g;
		$toclean =~ s/<\/quote>/\"/g;
	}
	else
	{
		$toclean =~ s/<quote>//g;
		$toclean =~ s/<\/quote>//g;
	}

	$toclean =~ s/<del>(.+)<del>/#\.\.#/g;
		
	$toclean =~ s/<O> cough <O>//;
	$toclean =~ s/<O> one word <O\/>//;
	$toclean =~ s/<O> A few words//;
	$toclean =~ s/<O> a few words <\/\?>//;
	$toclean =~ s/<O> caption <\/O.//;

	$toclean =~ s/<O>//g;
	$toclean =~ s/<del>//;
	$toclean =~ s/<logos>//;
	$toclean =~ s/<P>//;
	$toclean =~ s/<E>//;
	$toclean =~ s/<SA>//;
	
	$toclean =~ s/<\@([A-Z]){1,2}>/<\@##>/g;
	
	$toclean =~ s/<\/\&>//;
	
	$toclean =~ s/<\*> dotted line<\/\*>/\.\.\.\.\./g;
	
	return $toclean;
}

sub IRLclean
{
	my $toclean = shift(@_);
	
	$toclean =~ s/([[:alpha:]]{1}) 's /$1's /g;
	$toclean =~ s/([[:alpha:]]{1}) 's$/$1's/g;
	
	$toclean =~ s/<del>(.+)<\/del>/#\.\.#/g;
	
	$toclean =~ s/<\*> plus or minus sign <\/\*>/±/g;
	$toclean =~ s/<\*> plus minus sign <\/\*>/±/g;

	$toclean =~ s/<\*> dash sign <\/\*>/--/g;
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

	$toclean =~ s/<\&>(.+)<\/\&>/#..#/g;
	$toclean =~ s/<\*> sigma <\/\*>/S/g;

	$toclean =~ s/<\*> per cent sign <\/\*>/\%/g;
	$toclean =~ s/<\*> per cent <\/\*>/\%/g;
	$toclean =~ s/<\*> per cent sign, <\/\*>/\%,/g;
	$toclean =~ s/<\*> plus sign <\/\*>/\+/g;
	$toclean =~ s/<\*> minus sign <\/\*>/\-/g;
	$toclean =~ s/<\*> alpha sign <\/\*>/a/g;
	$toclean =~ s/<\*> asterisk <\/\*>/\*/g;
	$toclean =~ s/<\*> three asterisk signs <\/\*>/\*\*\*/g;
	$toclean =~ s/<\*> hash sign <\/\*>/#/g;
	$toclean =~ s/<\*> agus sign <\/\*>/#\?#/g;

	$toclean =~ s/<\*> less than or equal to sign <\/\*>/<=/g;
	$toclean =~ s/<\*> alpha and delta sign <\/\*>/αδ/g;
	$toclean =~ s/<\*> double alpha sign <\/\*>/αα/g;
	$toclean =~ s/<\*> inches sign <\/\*>/\'/g;
	$toclean =~ s/<\*> inch sign <\/\*>/\'/g;
	$toclean =~ s/<\*> delta sign <\/\*>/?/g;
	$toclean =~ s/<\*> delta <\/\*>/δ/g;
	$toclean =~ s/<\*> degrees sign <\/\*>/°/g;
	$toclean =~ s/<\*> degree sign <\/\*>/°/g;
	$toclean =~ s/<\*> degree sign, <\/\*>/°,/g;
	$toclean =~ s/<\*> degrees centigrade sign <\/\*>/°C/g;
	$toclean =~ s/<\*> degrees centigrade <\/\*>/°C/g;

	$toclean =~ s/<\*> mu sign <\/\*>/µ/g;
	$toclean =~ s/<\*> mu <\/\*>/µ/g;
	
	$toclean =~ s/<\*> multiplication sign <\/\*>/·/g;
	$toclean =~ s/<\*> mulltiplication sign <\/\*>/·/g;
	
	$toclean =~ s/<\*> bullet point <\/\*>/--/g;
	
	$toclean =~ s/<quote>//g;
	$toclean =~ s/<\/quote>//g;
	
	$toclean =~ s/<singing>//g;
	$toclean =~ s/<\/singing>//g;
	
	$toclean =~ s/<music>//g;
	$toclean =~ s/<\/music>//g;
	
	$toclean =~ s/<whispers>//g;
	$toclean =~ s/<\/whispers>//g;
	
	$toclean =~ s/<unclear> 2 sylls <unclear>//;
	$toclean =~ s/<unclear> several sylls <unclear>//;
	$toclean =~ s/<unclear> several sylls <\/&>//;
	$toclean =~ s/<unclear> 2 syllables //;
	$toclean =~ s/<unclear> 6 sylls <unclear>//;
	$toclean =~ s/<unclear> 3 sylls <unclear>//;

	$toclean =~ s/<laughs>//g;
	$toclean =~ s/<sigh>//g;
	$toclean =~ s/<ii>/\(ii\)/;
	
	$toclean =~ s/<P>//g;
	
	return $toclean;
}