#!/usr/bin/perl

### depthofcoverage.pl ############################################################################
# Generate the GATK DepthOfCoverage files.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-04-17      rdeborja            Initial development
# 0.02          2014-04-17      rdeborja            added creation of SGE Bash script
# 0.03          2015-01-27      rdeborja            replaced HPF::SGE::Roles with HPF::PBS

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::GATK;
use File::ShareDir ':ALL';
use HPF::PBS;
use IPC::Run3;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
    bam => undef,
    ref => '',
    intervals => '/hpf/largeprojects/adam/ref_data/targets/SureSelect_All_Exon_50mb_with_annotation_HG19_BED.removeChrUn.interval',
    java => '/hpf/tools/centos6/java/1.7.0/bin/java',
    gatk => '/hpf/tools/centos6/gatk/2.8.1/GenomeAnalysisTK.jar',
    memory => 4
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
        "bam|b=s",
        "ref|r:s",
        "java:s",
        "picard:s",
        "memory:i"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }

    my $memory = $opts{'memory'} * 2;

    my $template_dir = join('/',
        dist_dir('HPF'),
        'templates'
        );
    my $template = 'submit_to_pbs.template';

    my $gatk = NGS::Tools::GATK->new();
    my $gatk_coverage_run = $gatk->generate_depth_of_coverage(
        bam => $opts{'bam'},
        ref => $opts{'ref'},
        java => $opts{'java'},
        gatk => $opts{'gatk'},
        memory => $opts{'memory'}
        );

    my $pbs = HPF::PBS->new();
    my @hold_for = ();
    my $gatk_script = $pbs->create_cluster_shell_script(
        command => $gatk_coverage_run->{'cmd'},
        jobname => join('_', 'gatk', 'coverage'),
        template_dir => $template_dir,
        template => $template,
        memory => $memory
        );

    my $submit_command = join(' ',
        'qsub',
        $gatk_script->{'output'}
        );
    my $run3_command_status = system($submit_command);

    return 0;
    }


__END__


=head1 NAME

depthofcoverage.pl

=head1 SYNOPSIS

B<depthofcoverage.pl> [options] [file ...]

    Options:
    --help          brief help message
    --man           full documentation
    --bam           name of BAM file to process (required)
    --ref           full path to reference genome used for BAM alignment (optional)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--bam>

Name of BAM file to process (required).

=item B<--ref>

Full path to the reference genome FASTA file.  Default:

/hpf/largeprojects/adam/ref_data/targets/SureSelect_All_Exon_50mb_with_annotation_HG19_BED.removeChrUn.interval

=item B<--intervals>

File containing intervals.  See http://www.broadinstitute.org/gatk/guide/article?id=1204

=back

=head1 DESCRIPTION

B<depthofcoverage.pl> Generate the GATK DepthOfCoverage files.

=head1 EXAMPLE

depthofcoverage.pl --bam test.bam --ref hg19.fa --intervals /hpf/largeprojects/adam/ref_data/targets/SureSelect_All_Exon_50mb_with_annotation_HG19_BED.removeChrUn.interval

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

