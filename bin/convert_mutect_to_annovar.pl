#!/usr/bin/env perl

### convert_mutect_to_annovar.pl ##################################################################
# Convert the MuTect callstats.txt file to an ANNOVAR compatible input file.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2015-09-23      rdeborja            initial development

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use ShlienLab::Pipeline::SNVPostProcessing;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
    input => undef,
    output => ''
    );

### MAIN CALLER ###################################################################################
my $result = main();
exit($result);

### FUNCTIONS #####################################################################################

### main ##########################################################################################
# Description:
#   Main subroutine for program
# Input Variables:
#   %opts = command line arguments
# Output Variables:
#   N/A

sub main {
    # get the command line arguments
    GetOptions(
        \%opts,
        "help|?",
        "man",
        "input|i=s",
        "output|o:s"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument $arg\n";
            pod2usage(128);
            }
        }

    my $snv = ShlienLab::Pipeline::SNVPostProcessing->new();
    my $snv_post_run = $snv->convert_mutect_to_annovar_input(
        input => $opts{'input'},
        output => $opts{'output'}
        );

    return 0;
    }


__END__


=head1 NAME

convert_mutect_to_annovar.pl

=head1 SYNOPSIS

B<convert_mutect_to_annovar.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --input         (required) MuTect .callstats.txt file to be converted for use with ANNOVAR
    --output        (optional) name of output file (default: <input>.annovar)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.


=item B<--input>
The MuTect .callstats.txt file to be used with the

=item B<--output>


=back

=head1 DESCRIPTION

B<convert_mutect_to_annovar.pl> Convert the MuTect callstats.txt file to an ANNOVAR compatible input file.

=head1 EXAMPLE

convert_mutect_to_annovar.pl

=head1 AUTHOR

Richard de Borja <richard.deborja@sickkids.ca> -- The Hospital for Sick Children

=head1 ACKNOWLEDGEMENTS

Dr. Adam Shlien -- The Hospital for Sick Children

=cut

