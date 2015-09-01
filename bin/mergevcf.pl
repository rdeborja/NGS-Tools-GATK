#!/usr/bin/env perl

### mergevcf.pl ##############################################################################
# Merge VCF files for a given sample into a single VCF file.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2015-09-01      rdeborja            initial development

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::GATK;
use File::Find::Rule qw(find);
use Data::Dumper;
use File::ShareDir ':ALL';
use HPF::PBS;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
    dir => './',
    sample => undef,
    output => '',
    memory => 6,
    reference => '/hpf/largeprojects/adam/local/reference/homosapiens/ucsc/hs37d5/fasta/hs37d5.fa',
    java => '/hpf/tools/centos6/java/1.7.0/bin/java',
    gatk => '/hpf/tools/centos6/gatk/2.8.1/GenomeAnalysisTK.jar'
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
        "dir|d:s",
        "sample|s=s",
        "output|o:s",
        "memory|m:i",
        "reference|r:s",
        "java:s",
        "gatk:s"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument $arg\n";
            pod2usage(128);
            }
        }

    # create a default output filename if one is not passed as an argument
    my $output;
    if ('' eq $opts{'output'}) {
        $output = join('.',
            $opts{'sample'},
            'vcf'
            );
        }
    else {
        $output = $opts{'output'};
        }

    # get the list of VCF files in a given diretory, search recursively
    my @vcf_files = File::Find::Rule->file()->name('*.vcf')->in($opts{'dir'});
    my $gatk = NGS::Tools::GATK->new();
    my $gatk_combine_vcf_run = $gatk->combine_variants(
        vcf => \@vcf_files,
        output => $output,
        sample => $opts{'sample'},
        reference => $opts{'reference'},
        memory => $opts{'memory'},
        java => $opts{'java'},
        gatk => $opts{'gatk'}
        );

    my $pbs = HPF::PBS->new();
    my $template = 'submit_to_pbs.template';
    my $template_dir = join('/',
        dist_dir('HPF'),
        'templates'
        );
    my @hold_for = ();
    my $pbs_run = $pbs->create_cluster_shell_script(
        command => $gatk_combine_vcf_run->{'cmd'},
        jobname => join('_', $opts{'sample'}, 'gatk', 'combinevariants'),
        template_dir => $template_dir,
        template => $template,
        memory => $opts{'memory'},
        submit => 'false'
        );
    return 0;
    }


__END__


=head1 NAME

mergevcf.pl

=head1 SYNOPSIS

B<mergevcf.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --dir           directory containing VCF files (default: ./)
    --

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--dir>

Name of directory containing VCF files to search for (default: ./).

=back

=head1 DESCRIPTION

B<mergevcf.pl> Merge VCF files for a given sample into a single VCF file.

=head1 EXAMPLE

mergevcf.pl --dir /data/vcf

=head1 AUTHOR

Richard de Borja <richard.deborja@sickkids.ca> -- The Hospital for Sick Children

=head1 ACKNOWLEDGEMENTS

Dr. Adam Shlien -- The Hospital for Sick Children

=cut

