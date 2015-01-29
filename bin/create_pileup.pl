#!/usr/bin/perl

### create_pileup.pl ##############################################################################
# Create a GATK Pileup file.

### HISTORY #######################################################################################
# Version       Date            Developer           Comments
# 0.01          2014-05-20      rdeborja            initial development

### INCLUDES ######################################################################################
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use NGS::Tools::GATK;
use File::ShareDir ':ALL';
use HPF::PBS;

### COMMAND LINE DEFAULT ARGUMENTS ################################################################
# list of arguments and default values go here as hash key/value pairs
our %opts = (
	bam => undef,
	coverage_threshold => 100000000,
    java => '/hpf/tools/centos/java/1.6.0/bin/java',
    gatk => '/hpf/tools/centos/gatk/2.8.1/GenomeAnalysisTK.jar',
    memory => 16,
    interval => '',
    reference => '/hpf/largeprojects/adam/ref_data/homosapiens/ucsc/hg19/fasta/hg19.fa',
    execute => 'shell'
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
#  exit status of program

sub main {
    # get the command line arguments
    GetOptions(
        \%opts,
        "help|?",
        "man",
        "bam|b=s",
        "coverage_threshold|c:i",
        "java|j:s",
        "gatk|g:s",
        "memory|m:i",
        "interval|i:s",
        "reference|r:s",
        "execute|e:s"
        ) or pod2usage(64);
    
    pod2usage(1) if $opts{'help'};
    pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

    while(my ($arg, $value) = each(%opts)) {
        if (!defined($value)) {
            print "ERROR: Missing argument \n";
            pod2usage(128);
            }
        }

    my $gatk = NGS::Tools::GATK->new();
    my $pileup = $gatk->Pileup(
    	bam => $opts{'bam'},
    	coverage_threshold => $opts{'coverage_threshold'},
        java => $opts{'java'},
        gatk => $opts{'gatk'},
        memory => $opts{'memory'},
        reference => $opts{'reference'},
        interval => $opts{'interval'}
    	);

    # create the grid engine executable shell script
    my $memory = $opts{'memory'} * 2;
    my $template_dir = join('/',
        dist_dir('HPF'),
        'templates'
        );
    my $template = 'submit_to_sge.template';
    my @hold_for = ();
    my $gatk_script = $gatk->create_cluster_shell_script(
        command => $pileup->{'cmd'},
        jobname => join('_', 'gatk', 'pileup'),
        template_dir => $template_dir,
        template => $template,
        memory => $memory,
        hold_for => \@hold_for
        );
    if ($opts{'execute'} eq 'shell') {
        system("bash", $gatk_script->{'output'});
        }
    elsif ($opts{'execute'} eq 'sge') {
        system("qsub", $gatk_script->{'output'});
        }
    else {
        print "Executable script can be found at $gatk_script->{'output'}\n";
        }

    return 0;
    }


__END__


=head1 NAME

create_pileup.pl

=head1 SYNOPSIS

B<create_pileup.pl> [options] [file ...]

    Options:
    --help                  brief help message
    --man                   full documentation
    --bam                   BAM file to process (required)
    --coverage_threshold    threshold for coverage (default: 100000000)
    --interval              interval file to analyze
    --java                  full path to the Java program (default: /hpf/tools/centos/java/1.6.0/bin/java)
    --gatk                  full path to the GenomeAnalysisTK.jar (default: /hpf/tools/centos/gatk/2.8.1/GenomeAnalysisTK.jar)
    --memory                memory to allocate to the Java program (default: 16)
    --reference             reference genome in FASTA format
    --execute               options for executing program

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print the manual page.

=item B<--bam>

Name of BAM file to process.

=item B<--coverage_threshold>

Maximum value for coverage (default: 100,000,000)

=item B<--interval>

Interval file containing targets to analyze.  A tab separated file prefixed with .intervals
containing targets in the format chrA:start-end

=item B<--java>

Full path to the Java program. (default: /hpf/tools/centos/java/1.6.0/bin/java)

=item B<--gatk>

Full path to the GATK jar file. (default: /hpf/tools/centos/gatk/2.8.1/GenomeAnalysisTK.jar)

=item B<--memory>

Memory to allocate to the Java program.  This amount will be double when allocating memory for the grid engine. (default: 16)

=item B<--reference>

Reference genome in FASTA format.

=back

=head1 DESCRIPTION

B<create_pileup.pl> Create a GATK Pileup file.

=head1 EXAMPLE

create_pileup.pl --bam test.bam --coverage_threshold 1000

=head1 AUTHOR

Richard de Borja -- Molecular Genetics

The Hospital for Sick Children

=head1 SEE ALSO

=cut

