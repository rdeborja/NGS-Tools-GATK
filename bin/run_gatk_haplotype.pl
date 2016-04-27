#!/usr/bin/env perl

### run_gatk_haploytype.pl ########################################################################
# Run the GATK Haplotype caller algorithm.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2016-04-25      rdeborja            Initial development

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
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
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument $arg\n";
            pod2usage(128);
            }
        }

    return 0;
    }


__END__


=head1 NAME

run_gatk_haploytype.pl

=head1 SYNOPSIS

B<run_gatk_haploytype.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=back

=head1 DESCRIPTION

B<run_gatk_haploytype.pl> Run the GATK Haplotype caller algorithm.

=head1 EXAMPLE

run_gatk_haploytype.pl

=head1 AUTHOR

Richard de Borja <richard.deborja@sickkids.ca> -- The Hospital for Sick Children

=head1 ACKNOWLEDGEMENTS

Dr. Adam Shlien -- The Hospital for Sick Children

=cut

