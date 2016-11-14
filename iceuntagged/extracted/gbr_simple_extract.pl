#!C:\Perl64\bin\perl.exe -w

use strict;
use utf8;

my ($path, $ext, $output) = @ARGV;
opendir(SUBDIR, "$path") or die $!;

my $num_files = 0;
open(LOG, ">gbr-log.txt");
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
			if (defined($line) && $line ne '')
			{
				$line = 'ICE-GBR:' . $line;
				$line =~ s/^ICE-GBR:s1a-/ICE-GBR:S1A-/;
				$line =~ s/^ICE-GBR:s2a-/ICE-GBR:S2A-/;
				$line =~ s/^ICE-GBR:s1b-/ICE-GBR:S1B-/;
				$line =~ s/^ICE-GBR:s2b-/ICE-GBR:S2B-/;

				$line =~ s/^ICE-GBR:w1a-/ICE-GBR:W1A-/;
				$line =~ s/^ICE-GBR:w2a-/ICE-GBR:W2A-/;
				$line =~ s/^ICE-GBR:w1b-/ICE-GBR:W1B-/;
				$line =~ s/^ICE-GBR:w2b-/ICE-GBR:W2B-/;
				$line =~ s/^ICE-GBR:w1c-/ICE-GBR:W1C-/;
				$line =~ s/^ICE-GBR:w2c-/ICE-GBR:W2C-/;
				$line =~ s/^ICE-GBR:w1d-/ICE-GBR:W1D-/;
				$line =~ s/^ICE-GBR:w2d-/ICE-GBR:W2D-/;
				$line =~ s/^ICE-GBR:w1e-/ICE-GBR:W1E-/;
				$line =~ s/^ICE-GBR:w2e-/ICE-GBR:W2E-/;
				$line =~ s/^ICE-GBR:w1f-/ICE-GBR:W1F-/;
				$line =~ s/^ICE-GBR:w2f-/ICE-GBR:W2F-/;

				push(@newcontent, $line);
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
	print OUT "$sentence\n";
}
close(OUT);
close(LOG);
print "Check log fila, log.txt\n";
exit;

sub cleanUp
{
	my $toclean = shift(@_);

	$toclean =~ s/([[:alpha:]]{1}) 's /$1's /g;
	$toclean =~ s/([[:alpha:]]{1}) 's$/$1's/g;
	
	$toclean =~ s/([[:alpha:]]{1})#l-#/$1-/g;

	$toclean =~ s/#unclear-words#/#\.\.\.#/g;
	$toclean =~ s/#unclear-syllables#/#\.\.\.#/g;
	$toclean =~ s/#unclear-word#/#\.\.#/g;
	$toclean =~ s/#unclear-syllable#/#\.\.#/g;
	$toclean =~ s/#unclear-characters#/#\.\.\.#/g;
	$toclean =~ s/#unclear-character#/#\.\.#/g;
	$toclean =~ s/#unclear-sentence#/#\.\.\.#/g;
	$toclean =~ s/#unclear-discussion#/#\.\.\.#/g;
	$toclean =~ s/#unclear#/#\.\.\.#/g;
	
#Special
	$toclean =~ s/· //;
	$toclean =~ s/‹/</;
	$toclean =~ s/\&pound-sign;/£/g;
	$toclean =~ s/\&amp;/\&/g;
	$toclean =~ s/\&ccedille;/ç/g;
	$toclean =~ s/\&bullet;/--/g;
	$toclean =~ s/\&right-arrow;/->/g;
	$toclean =~ s/\&degree;/°/g;
	$toclean =~ s/\&less-than;/</g;
	$toclean =~ s/\&smaller-than;/</g;
	$toclean =~ s/\&mu;/μ/g;
	$toclean =~ s/\&BETA;/Β/g;
	$toclean =~ s/\&omega;/ω/g;
	$toclean =~ s/\&Omega;/Ω/g;
	$toclean =~ s/\&plus-or-minus;/±/g;
	$toclean =~ s/\&long-dash;/--/g;
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
	$toclean =~ s/\&Delta;/Δ/g;
	$toclean =~ s/\&eumlaut;/ë/g;
	$toclean =~ s/\&uumlaut;/ü/g;
	$toclean =~ s/\&AEligature;/Æ/g;
	$toclean =~ s/\&double-arrow;/>>/g;
	$toclean =~ s/\&Beta;/Β/g;
	$toclean =~ s/\&dot;/·/g;
	$toclean =~ s/\&black-square;/--/g;
	$toclean =~ s/\&dagger;/†/g;
	$toclean =~ s/\&caret;/^/g;
	$toclean =~ s/\&approximate-sign;/≈/g;
	$toclean =~ s/\&female;/♀/g;
	$toclean =~ s/\&arrow;/->/g;
	$toclean =~ s/\&oumlaut;/ö/g;
	$toclean =~ s/\&star;/\*/g;
	$toclean =~ s/\&beta;/β/g;
	$toclean =~ s/\&oeligature;/œ/g;
	$toclean =~ s/\&down-arrow;/↓/g;
	$toclean =~ s/\&Angstrom;/Å/g;
	$toclean =~ s/\&larger-than;/>/g;
	$toclean =~ s/\&because-symbol;/>/g;
	$toclean =~ s/\&delta;/δ/g;
	
	$toclean =~ s/ $//;
	
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