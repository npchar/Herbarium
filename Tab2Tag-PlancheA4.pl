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
my $TexTemplate = "./" ;
my $TexTemplateBottom = "TagTemplate-v1-A4-BottomRight.tex";
my $TexTemplateDescriptions = "TagTemplate-v1-A4-Descriptions.tex";

my $usage = "Usage: $0 -i <CSV formated tab> -p <Planche name> \n\n";
$usage .= "Description:  Create fancy Tag from information stored in a Tab delimited tabular. It's based on 'Planche', which could abrit several samples.\n\n";
$usage .= "Requirement:  Need LaTeX, and R, as well as some R packages installed (see below). Requires also a properly configured internet connexion.\n";
$usage .= "              R dependencies: optparse, ggmap, magick. Folder should contain the TeX template (path or template could be changed throught -t option)\n\n";
$usage .= "Arguments:    -i   <CSV formated tab> Input db formated as CSV (tab delimited)\n";
$usage .= "              -p   <Planche> Name of the object to process\n";
$usage .= "Options:      -o   <Output prefix> for the Tag file (pdf), default is <Sample name>\n";
$usage .= "              -r   <R script> default: [$Rscript]\n";
$usage .= "              -t   <Tex template file directory> default: [$TexTemplate]\n";
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
# unless( -f ${TexTemplate}.${TexTemplateBottom} ){
# 	print "\nERROR Latex Template Bottom (${TexTemplate}${TexTemplateBottom}) is missing !\n\n";
#     print STDERR $usage;
#     exit 1;
# }
# unless( -f ${TexTemplate}.${TexTemplateDescriptions} ){
# 	print "\nERROR Latex Template Descriptions (${TexTemplate}$TexTemplateDescriptions) is missing !\n\n";
#     print STDERR $usage;
#     exit 1;
# }
unless( -f $Rscript ){
	print "\nERROR R script ($Rscript) is missing !\n\n";
    print STDERR $usage;
    exit 1;
}

#########################################################################
### i. Opening TabCSV
### 	-> Storing information for Sample Name 
### -- New directory
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
print "\./$Rscript -a $SampleInformation{'Lat'} -o $SampleInformation{'Lon'} -s Base\n";
system("Rscript $Rscript -a $SampleInformation{'Lat'} -o $SampleInformation{'Lon'} -s Base") ;

### iii. Preparing LaTeX
###----------------------

#Preparing TexTemplateBottom
#Preparing TexTemplateBottom Name File
my $SpecificTexTemplateBottom = $TexTemplateBottom ;
# print $SpecificTexTemplateBottom , "\n" ;
$SpecificTexTemplateBottom =~ s/\.tex$// ;
$SpecificTexTemplateBottom = ${SpecificTexTemplateBottom}.'Base.tex' ;
BottomRightTemplateCreation( $SpecificTexTemplateBottom ) ;

#Preparing TexTemplateDescriptions
#Preparing TexTemplateDescripiton Name File
my $SpecificTexTemplateDescriptions = $TexTemplateDescriptions ;
#print $SpecificTexTemplateDescriptions , "\n" ;
$SpecificTexTemplateDescriptions =~ s/\.tex$// ;
$SpecificTexTemplateDescriptions = ${SpecificTexTemplateDescriptions}.'Base.tex' ;
DescriptionsTemplateCreation( $SpecificTexTemplateDescriptions ) ;


#Preparing TexInformation
open (my $OUT , ">${PlancheName}.Infos.tex" ) or die "Unable to open ${PlancheName}.Infos.tex !\n " ;
print $OUT '\def\Planche{'.${PlancheName}.'}'."\n" ;
print $OUT '\def\FamilleBotanique{'.$SampleInformation{'Famille'}.'}'."\n"  ;
print $OUT '\def\LinneanName{'.$SampleInformation{'Espece'}.'}'."\n" ;
print $OUT '\def\Descripteur{'.$SampleInformation{'Descripteur'}.'}'."\n" ;
print $OUT '\def\NomCommuns{'.$SampleInformation{'NomCommuns'}.'}'."\n" ;
print $OUT '\def\DateRecolte{'.$SampleInformation{'Date'}.'}'."\n" ;
print $OUT '\def\NumRecolte{'.$SampleInformation{'SampleName'}.'}'."\n" ;
print $OUT '\def\AdresseRecolte{'.$SampleInformation{'Adresse'}.',  '.$SampleInformation{'Ville'}.', '.$SampleInformation{'Pays'}.'}'."\n" ;
print $OUT '\def\coordDD{'.$SampleInformation{'Lon'}.'/'.$SampleInformation{'Lat'}.'}'."\n" ;
print $OUT '\def\Altitude{'.$SampleInformation{'Altitude'}.'m}'."\n" ;
print $OUT '\def\DescriptionMilieu{'.$SampleInformation{'Description'}.'}'."\n" ;
print $OUT '\def\Notes{'.$SampleInformation{'Notes'}.'}'."\n" ;
print $OUT '\def\Collecteurs{'.$SampleInformation{'Collecteur'}.'}'."\n" ;
print $OUT '\def\Identification{'.$SampleInformation{'Identificateur'}.'}'."\n" ;
if($map){print $OUT '\def\MajCarte{true}'."\n" ; }else{print $OUT '\def\MajCarte{true}'."\n" ;}
print $OUT '\def\sampleMapsPanel{'.'Base'.'_panel.png}'."\n" ;
close $OUT ;

#Preparing Calling LaTex
system("pdflatex $SpecificTexTemplateBottom");
system("pdflatex $SpecificTexTemplateDescriptions");

system("mkdir $PlancheName") ;
my $pdfBottom = $SpecificTexTemplateBottom ;
$pdfBottom =~ s/\.tex$// ;
$pdfBottom = ${pdfBottom}.'.pdf' ;
my $pdfDesc = $SpecificTexTemplateDescriptions ;
$pdfDesc =~ s/\.tex$// ;
$pdfDesc = ${pdfDesc}.'.pdf' ;

#system("cp ModeleA4-V1.indd $PlancheName") ;
system("mv Base_panel.png $PlancheName");
system("mv $pdfBottom $PlancheName");
system("mv $pdfDesc $PlancheName");
system("mv ${PlancheName}.Infos.tex $PlancheName");


### v. Cleaning Working Directory (Work in progress)
#opendir(DIR, $dir) or die $!;

system ("rm ${PlancheName}.Infos.tex") ;
BottomRightTemplateDestruction( $SpecificTexTemplateBottom ) ;
DescriptionsTemplateDestruction( $SpecificTexTemplateDescriptions ) ;
system ("rm Base_[0-9].png") ;


#while (my $file = readdir(DIR)) {
#	next if ($file ~ m/^\./);
#	print "$file\n";
#}
#closedir(DIR);

##################################################
### 	SUBROUTINES
##################################################

sub BottomRightTemplateCreation {
	my $BottomRightTemplateName = shift (@_) ;
	my $BottomRightTemplateContent = '\documentclass[a4paper, 12pt]{article}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage[T1]{fontenc}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage{graphicx}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage{SIunits}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage{wasysym}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage[margin=1.5cm]{geometry}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage{array}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage{tracefnt}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage[frenchb]{babel}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage{eurosym}'."\n" ;
	$BottomRightTemplateContent .= '\usepackage{ifthen}'."\n" ;
	$BottomRightTemplateContent .= ''."\n" ;
	$BottomRightTemplateContent .= '% Where informations are stored'."\n" ;
	$BottomRightTemplateContent .= '\input{SampleInformations}'."\n" ;
	$BottomRightTemplateContent .= ''."\n" ;
	$BottomRightTemplateContent .= '\begin{document}'."\n" ;
	$BottomRightTemplateContent .= '\pagenumbering{gobble}'."\n" ;
	$BottomRightTemplateContent .= '\noindent'."\n" ;
	$BottomRightTemplateContent .= '{\huge \bf \FamilleBotanique} \\\\'."\n" ;
	$BottomRightTemplateContent .= '{\large {\it \LinneanName} (\Descripteur)}\\\\'."\n" ;
	$BottomRightTemplateContent .= '{\large \NomCommuns}\\\\'."\n" ;
	$BottomRightTemplateContent .= '{\large \bf \texttt{\Planche}}\\\\'."\n" ;
	$BottomRightTemplateContent .= ''."\n" ;
	$BottomRightTemplateContent .= ''."\n" ;
	$BottomRightTemplateContent .= '\end{document}'."\n" ;
	
	# Tuning Template to fit with SampleInformationsFile
	$BottomRightTemplateContent =~ s/SampleInformations/${PlancheName}\.Infos\.tex/ ;
	
	open (my $OUTBRT , ">$BottomRightTemplateName" ) or die "Unable to open $BottomRightTemplateName !\n " ;
	print $OUTBRT $BottomRightTemplateContent ; 
	close $OUTBRT ;
}

sub BottomRightTemplateDestruction {
	my $BottomRightTemplateName = shift (@_) ;
	my $BaseName = $BottomRightTemplateName ;
	$BaseName =~ s/\.tex$// ;
	system ("rm ${BaseName}.aux") ;
	system ("rm ${BaseName}.log") ;
	system ("rm $BottomRightTemplateName" ) ;
}

sub DescriptionsTemplateCreation {
	my $DescriptionsTemplateName = shift @_ ; 
	my $DescriptionsTemplateContent = '\documentclass[a4paper, 4pt]{article}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage[T1]{fontenc}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage{graphicx}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage{SIunits}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage{wasysym}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage[margin=1.5cm]{geometry}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage{array}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage{tracefnt}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage[frenchb]{babel}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage{eurosym}'."\n" ;
	$DescriptionsTemplateContent .= '\usepackage{ifthen}'."\n" ;
	$DescriptionsTemplateContent .= ''."\n" ;
	$DescriptionsTemplateContent .= '% Where informations are stored'."\n" ;
	$DescriptionsTemplateContent .= '\input{SampleInformations}'."\n" ;
	$DescriptionsTemplateContent .= ''."\n" ;
	$DescriptionsTemplateContent .= '\begin{document}'."\n" ;
	$DescriptionsTemplateContent .= '\pagenumbering{gobble}'."\n" ;
	$DescriptionsTemplateContent .= ''."\n" ;
	$DescriptionsTemplateContent .= '\begin{minipage}{10cm}'."\n" ;
	$DescriptionsTemplateContent .= '\noindent'."\n" ;
	$DescriptionsTemplateContent .= '{\bf Date de récolte :} \DateRecolte \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Collecte :} \Collecteurs \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Identification :} \Identification \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Famille :} \FamilleBotanique \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Nom scientifique :} {\it \LinneanName}~(\Descripteur)\\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Nom(s) vernaculaire(s) :} \NomCommuns \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Planche :} {\texttt \Planche} \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Lieux de récolte :} \AdresseRecolte \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Longitude / Latitude (DD) :} \coordDD \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Altitude :} \Altitude \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Description :} '."\n" ;
	$DescriptionsTemplateContent .= '\DescriptionMilieu \\\\ '."\n" ;
	$DescriptionsTemplateContent .= '{\bf Notes : }'."\n" ;
	$DescriptionsTemplateContent .= '\Notes'."\n" ;
	$DescriptionsTemplateContent .= '\\\\ '."\n" ;
	$DescriptionsTemplateContent .= ''."\n" ;
	$DescriptionsTemplateContent .= '\vspace{0.1cm}'."\n" ;
	$DescriptionsTemplateContent .= '\noindent'."\n" ;
	$DescriptionsTemplateContent .= ''."\n" ;
	$DescriptionsTemplateContent .= ' \end{minipage}'."\n" ;
	$DescriptionsTemplateContent .= '\end{document}'."\n" ;
	
	open (my $OUTD , ">$DescriptionsTemplateName" ) or die "Unable to open $DescriptionsTemplateName !\n " ;
	$DescriptionsTemplateContent =~ s/SampleInformations/${PlancheName}\.Infos\.tex/ ;
	print $OUTD "${DescriptionsTemplateContent}\n" ;
	close $OUTD ;
}

sub DescriptionsTemplateDestruction {
	my $DescriptionsTemplateName = shift @_ ; 
	my $BaseName = $DescriptionsTemplateName ;
	$BaseName =~ s/\.tex$// ;
	system ("rm $DescriptionsTemplateName");
	system ("rm ${BaseName}.aux") ;
	system ("rm ${BaseName}.log") ;
}