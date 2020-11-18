#! /usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my $PlancheName;
my $SampleName;
my $TabCSV;
my $help;
my $map;
my $outPrefix;
my $Rscript = "CreateMapsPanel.R";
my $TexTemplate = "TagTemplate-v1.tex";

my $usage = "Usage: $0 -i <CSV formated tab> -p <Planche name> \n\n";
$usage .= "Description:  Create fancy Tag from information stored in a Tab delimited tabular. It's based on 'Planche', which could abrit several samples.\n\n";
$usage .= "Requirement:  Need LaTeX, and R, as well as some R packages installed (see below). Requires also a properly configured internet connexion.\n";
$usage .= "              R dependencies: optparse, ggmap, magick. Folder should contain the TeX template (path or template could be changed throught -t option)\n\n";
$usage .= "Arguments:    -i   <CSV formated tab> Input db formated as CSV (tab delimited)\n";
$usage .= "              -p   <Planche> Name of the object to process\n";
$usage .= "Options:      -o   <Output prefix> for the Tag file (pdf), default is <Sample name>\n";
$usage .= "              -r   <R script> default: [$Rscript]\n";
$usage .= "              -t   <Tex template file> default: [$TexTemplate]\n";
$usage .= "              -m   option to skip map creation if already generated\n";
$usage .= "              -h   Displays this help and exit\n\n";



GetOptions(
           'i=s'	  => \$TabCSV,
           'p=s'	  => \$PlancheName,
           'o=s'         => \$outPrefix,
           'r=s'         => \$Rscript,
           't=s'         => \$TexTemplate,
           'h'        => \$help,
           'm!' => \$map
          );

if( $help ){
    print $usage;
    exit 0;
}
unless( $PlancheName && $TabCSV ){
	print "\nERROR Input tabular ($TabCSV) is missing !\n\n";
    print STDERR $usage;
    exit 1;
}

unless( -f $TabCSV ){
	print "\nERROR Input tabular ($TabCSV) is missing !\n\n";
    print STDERR $usage;
    exit 1;
}
unless( -f $TexTemplate ){
	print "\nERROR Latex Template ($TexTemplate) is missing !\n\n";
    print STDERR $usage;
    exit 1;
}
unless( -f $TexTemplate ){
	print "\nERROR Latex Template ($TexTemplate) is missing !\n\n";
    print STDERR $usage;
    exit 1;
}
unless( -f $Rscript ){
	print "\nERROR R script ($Rscript) is missing !\n\n";
    print STDERR $usage;
    exit 1;
}

#########################################################################
### i. Opening TabCSV
### 	-> Storing information for Sample Name 
### ii. Calling R, creating maps
### iii. Preparing Latex
### iv. Calling LaTeX
### v. Cleaning Working Directory



### i. Opening TabCSV
###-------------------
open ( my $IN , "<$TabCSV" ) or die "Unable to open $TabCSV !\n " ;

my %SampleInformation ;
while (my $i = <$IN> ){
	chomp $i;
	my @words = split "\t", $i ;
	unless($words[0] eq $PlancheName ){next ;}
	$SampleInformation{'Planche'} = $words[0] ;
	$SampleInformation{'SampleName'} = $words[1] ;
	$SampleInformation{'Date'} =  $words[2] ;
#	print $words[2], " ", $words[2], "\n";
	$SampleInformation{'Lat'} = $words[3] ;
	$SampleInformation{'Lat'} =~ s/,/\./ ;
	$SampleInformation{'Lon'} = $words[4] ;
	$SampleInformation{'Lon'} =~ s/,/\./ ;
	$SampleInformation{'Altitude'} = $words[5] ;
	$SampleInformation{'Adresse'} = $words[6] ;
	$SampleInformation{'Ville'} = $words[7] ;
	$SampleInformation{'CodePostal'} = $words[8] ;
	$SampleInformation{'Pays'} = $words[9] ;
	$SampleInformation{'Collecteur'} = $words[10] ;
	$SampleInformation{'Identificateur'} = $words[11] ;
	$SampleInformation{'Famille'} = $words[12] ;
	$SampleInformation{'Espece'} = $words[13] ;
	$SampleInformation{'Descripteur'} = $words[14] ;
	$SampleInformation{'NomCommuns'} = $words[15] ;
	$SampleInformation{'Description'} = $words[16] ;
	$SampleInformation{'Notes'} = $words[17] ;
}
close $IN ;

### ii. Calling R
###---------------
print "\./$Rscript -a $SampleInformation{'Lat'} -o $SampleInformation{'Lon'} -s $PlancheName\n";
system("\./$Rscript -a $SampleInformation{'Lat'} -o $SampleInformation{'Lon'} -s $PlancheName") ;

### iii. Preparing LaTeX
###----------------------

#Preparing TexTemplate
my $SpecificTexTemplate = $TexTemplate ;
print $SpecificTexTemplate , "\n" ;
$SpecificTexTemplate =~ s/\.tex$// ;
$SpecificTexTemplate = ${SpecificTexTemplate}.'.'.${PlancheName}.'.tex' ;
print $SpecificTexTemplate , "\n" ;

open ( $IN , "<$TexTemplate" ) or die "Unable to open $TexTemplate !\n " ;
open (my $OUT , ">$SpecificTexTemplate" ) or die "Unable to open $SpecificTexTemplate !\n " ;
while (my $i = <$IN> ){
	chomp $i;
	if($i =~ /SampleInformations/ ){ $i =~ s/SampleInformations/${PlancheName}\.Infos\.tex/ }
	print $OUT "${i}\n" ;
}
close $IN ;
close $OUT ;

#Preparing TexInformation
open ($OUT , ">${PlancheName}.Infos.tex" ) or die "Unable to open ${PlancheName}.Infos.tex !\n " ;
print $OUT '\def\Planche{'.${PlancheName}.'}'."\n" ;
print $OUT '\def\FamilleBotanique{'.$SampleInformation{'Famille'}.'}'."\n"  ;
print $OUT '\def\LinneanName{'.$SampleInformation{'Espece'}.'}'."\n" ;
print $OUT '\def\Descripteur{'.$SampleInformation{'Descripteur'}.'}'."\n" ;
print $OUT '\def\NomCommuns{'.$SampleInformation{'NomCommuns'}.'}'."\n" ;
print $OUT '\def\DateRecolte{'.$SampleInformation{'Date'}.'}'."\n" ;
print $OUT '\def\NumRecolte{'.$SampleInformation{'SampleName'}.'}'."\n" ;
print $OUT '\def\AdresseRecolte{'.$SampleInformation{'Adresse'}.',  '.$SampleInformation{'Ville'}.', '.$SampleInformation{'Pays'}.'}'."\n" ;
print $OUT '\def\coordDD{'.$SampleInformation{'Lon'}.' / '.$SampleInformation{'Lat'}.'}'."\n" ;
print $OUT '\def\Altitude{'.$SampleInformation{'Altitude'}.'m}'."\n" ;
print $OUT '\def\DescriptionMilieu{'.$SampleInformation{'Description'}.'}'."\n" ;
print $OUT '\def\Notes{'.$SampleInformation{'Notes'}.'}'."\n" ;
print $OUT '\def\Collecteurs{'.$SampleInformation{'Collecteur'}.'}'."\n" ;
print $OUT '\def\Identification{'.$SampleInformation{'Identificateur'}.'}'."\n" ;
if($map){print $OUT '\def\MajCarte{true}'."\n" ; }else{print $OUT '\def\MajCarte{true}'."\n" ;}
print $OUT '\def\sampleMapsPanel{'.${PlancheName}.'_panel.png}'."\n" ;
close $OUT ;

#Preparing Calling LaTex
system("pdflatex $SpecificTexTemplate");
system("pdflatex $SpecificTexTemplate");

### v. Cleaning Working Directory (Work in progress)
#opendir(DIR, $dir) or die $!;

#while (my $file = readdir(DIR)) {
#	next if ($file ~ m/^\./);
#	print "$file\n";
#}
#closedir(DIR);

