#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use FindBin qw($Bin);               # get path
use lib "$Bin";    # add path to modules!
use File::Find;
use Data::Dumper;
use DateTime;
use YAML qw(LoadFile);
use File::Path qw(make_path);

## Main script run
my $cfgs = parseCommandLine();
mainProgram ($cfgs);

## The following subroutine are executed depending on a "regular expression"
## match of the string in the dumper dictonary element.
print (Dumper($cfgs))       if (lc($cfgs->{dumper}) =~ m/dump/ );


sub mainProgram {
  my $args = shift;

  if (! -e $args->{outdir}) {
    make_path($args->{outdir});
  }
  
  wrLogBan("Running with YAML file $cfgs->{yaml}");
  
  my $yamlAsHashRef = LoadFile($cfgs->{yaml}); 

  #print (Dumper($yamlAsHashRef));
  
  foreach my $area (sort {$a cmp $b} keys($yamlAsHashRef)) {
    my $htmlString = "";
    wrLogNl("L $area");
    foreach my $group (sort {$a cmp $b} keys($yamlAsHashRef->{$area})) {
      wrLogNl( " G        $group");    

      $htmlString .= "<h4>$group</h4>\n";
      if (exists ($yamlAsHashRef->{$area}{$group}{desc})) {
        if ($yamlAsHashRef->{$area}{$group}{desc} ne "") {
          $htmlString .= "$yamlAsHashRef->{$area}{$group}{desc}\n";
        }
      }
      $htmlString .= "<table width=\"100%\"  style=\'font-size:80%\'>\n";
      $htmlString .= "<thead></thead>\n";
      $htmlString .= "<tr>\n";
      $htmlString .= "<th width=\"30%\">Link</th>\n";
      $htmlString .= "<th width=\"70%\">Description</th>\n";
      $htmlString .= "</tr>\n";
      $htmlString .= "</thead>\n";
      $htmlString .= "<tbody>\n";
      
      foreach my $element (sort {$a cmp $b} keys($yamlAsHashRef->{$area}{$group}{links})) {
        wrLogNl( "  E            $element");    

        my $link = "";
        my $text = "";

        my $href = $yamlAsHashRef->{$area}{$group}{links}{$element};

        ## How we build up the Link
        if (exists ($href->{web})) {
          if ($href->{web} =~ m/^www/) {
            $href->{web} = "https://$href->{web}";
          }
          $link .= "<a href=\"$href->{web}\">$element</a>";
        } else {
          $link .= "$element";
        }

        ## How we build up the text
        if (exists ($href->{desc})) {
          $text .= "$href->{desc}";
        }

        if (exists ($href->{tel})) {
          my $telNo = "$href->{tel}"; # Make a string
          $telNo =~ s/^0/\+44/;
          $text .= "<br><a href=\"tel:${telNo}\">${telNo}</a>";
        }

        ## Write the Table Row
        $htmlString .= "<tr>\n";
        $htmlString .= "<td width=\"30%\">${link}</td>\n";
        $htmlString .= "<td width=\"70%\">${text}</td>\n";
        $htmlString .= "</tr>\n";

      }

      $htmlString .= "</tbody>\n";
      $htmlString .= "</table>\n\n\n";

    }

    # print($htmlString);
    my $filename = "$args->{outdir}/${area}.html.txt";
    $filename =~ s/\s+/_/;
    writeToFile ($filename, $htmlString);

  }


## <h3>Programming</h3>
## 
## <table border="1" width="100%"  style='font-size:80%'>
## <thead></thead>
## <tbody>
## <tr>
## <td width="30%"><a href="http://sonic-pi.net">Sonic PI</a></td>
## <td width="70%">This is a fun way to get coding by making music. Download for Windows10, Mac, Raspberry PI. It really is awesome and you can make some crazy noises.</td>
## </tr>
## </tbody>
## </table>



  return 0;
}


#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
sub writeToFile {
  my ( $fileName, $string ) = @_;
  if ( $fileName ne "" ) {
    open( FILE, ">$fileName" ) || die "Can't open $fileName: $!\n";
    print FILE $string;
    close(FILE);
  }
}
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
sub wrLogBan {
  wrLogNl("*"x80);
  wrLogNl(shift);
  wrLogNl("*"x80);
}
sub wrLogNl {
  wrLog(shift . "\n");
}
sub wrLog {
  my $dt = DateTime->now;
  print("[" . $dt->ymd . " " . $dt->hms . "] " . shift);
}

#------------------------------------------------------------------------------
# initialise script, process input
#------------------------------------------------------------------------------
sub parseCommandLine {
  my $helpText = "
  $0 - Use to find code methods and call points

  -yaml <string>     : For now a YAML file, the the furture a directory of YAML files
  -dumper <string>   : Debug regex (s1&s2&s3) & dump & (called)
  
  Default settings:
  ";
  my %cfgh; # declare HASH to store the config in.
  ## user config
  $cfgh{yaml}="";
  $cfgh{dumper}="";
  $cfgh{outdir}="output";
  ## internal vars

  GetOptions(
    "yaml=s"          => \$cfgh{yaml},
    "outdir=s"        => \$cfgh{outdir},
    "dumper=s"        => \$cfgh{dumper},
    "help"            => sub{ print $helpText . Dumper(\%cfgh); exit; }
  );

  return \%cfgh; # Pass back a REFERENCE to the config hash
}

