package NGS::Tools::GATK::Roles::HaplotypeCaller;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;

=head1 NAME

NGS::Tools::GATK::Roles::HaplotypeCaller

=head1 SYNOPSIS

A Perl Moose role that wraps the GATK Haplotype Caller.

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->call_haplotype()

A method that wraps the GATK HaplotypeCaller.jar program.

=head3 Arguments:

=over 2

=item * bam: an array reference containing BAM files to process (required)

=item * reference: name of reference FASTA file (required)

=item * output: name of output file (default: script will use modified input BAM filename)

=item * known_sites: an array reference containing VCF file(s) to use for known indels

=item * memory: amount of heap space to define for the Java program

=item * tmpdir: full path to the tmp directory where intemediate files will be generated

=item * gatk: full path to the GenomeAnalysisTK.jar file

=item * java: full path to the Java program (default: java)

=item * dbsnp: name of dbSNP file for annotation of mutations

=item * interval: interval to use for parallelization, in our case we use the chromosome/contig

=back

=cut

sub call_haplotype {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        bam => {
            isa         => 'ArrayRef',
            required    => 1
            },
        reference => {
          isa       => 'Str',
          required  => 1
          },
        output => {
          isa       => 'Str',
          required  => 0,
          default   => ''
          },
        known_sites => {
          isa       => 'ArrayRef',
          required  => 0,
          default   => undef
          },
        memory => {
          isa       => 'Int',
          required  => 0,
          default   => 10
          },
        tmpdir => {
          isa       => 'Str',
          required  => 0,
          default   => ''
          },
        gatk => {
          isa       => 'Str',
          required  => 0,
          default   => '${GATK}'
          },
        java => {
          isa       => 'Str',
          required  => 0,
          default   => 'java'
          },
        dbsnp => {
          isa       => 'Str',
          required  => 0,
          default   => ''
          },
        interval => {
          isa       => 'Str',
          required  => 0,
          default   => ''
          },
        min_base_quality_score => {
          isa       => 'Int',
          required  => 0,
          default   => 20
          },
        stand_call_conf => {
          isa       => 'Int',
          required  => 0,
          default   => 30
          },
        stand_emit_conf => {
          isa       => 'Int',
          required  => 0,
          default   => 10
          },
        output_mode => {
          isa       => 'Str',
          required  => 0,
          default   => 'EMIT_VARIANTS_ONLY'
          }
        );

    my $memory = join('',
        $args{'memory'}, 
        'g'
        );

    # create the BAM input file string
    my $bam_input = '';
    foreach my $bam (@{ $args{'bam'} }) {
      $bam_input = join(' ',
        $bam_input,
        '-I',
        $bam
        );
      }

    my $output;
    if ($args{'output'} eq '') {
        $output = join('.',
            basename($args{'bam'}->[0], qw(.bam)),
            'hap_snv',
            'vcf'
            );
        }
    else {
        $output = $args{'output'};
        }

    my $program = join(' ',
        $args{'java'},
        '-Xmx' . $memory
        );
    if ($args{'tmpdir'} ne '') {
        $program = join(' ',
            '-Djava.io.tmpdir=' . $args{'tmpdir'}
            );
        }
    $program = join(' ',
        $program,
        '-jar',
        $args{'gatk'}
        );

    # review the params on
    # https://www.broadinstitute.org/gatk/guide/tooldocs/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
    my $options = join(' ',
        '-T HaplotypeCaller',
        '-R', $args{'reference'},
        $bam_input,
        '-o', $output,
        '--dbsnp', $args{'dbsnp'},
        '--output_mode', $args{'output_mode'},
        '-rf BadCigar',
        '--min_base_quality_score', $args{'min_base_quality_score'},
        '--stand_call_conf', $args{'stand_call_conf'},
        '--stand_emit_conf', $args{'stand_emit_conf'}
        );

    if ($args{'interval'} ne '') {
        $options = join(' ',
            $options,
            '-L', $args{'interval'}
            );
        }
    
    # create the fully executable GATK HaploytypeCaller command
    my $cmd = join(' ',
        $program,
        $options
        );

    my %return_values = (
        cmd => $cmd,
        output => $output
        );

    return(\%return_values);
    }

=head1 AUTHOR

Richard de Borja, C<< <richard.deborja at gmail.ca> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-test at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc NGS::Tools::GATK::Roles::HaplotypeCaller

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=test-test>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/test-test>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/test-test>

=item * Search CPAN

L<http://search.cpan.org/dist/test-test/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Richard de Borja.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

no Moose::Role;

1; # End of NGS::Tools::GATK::Roles::HaplotypeCaller
