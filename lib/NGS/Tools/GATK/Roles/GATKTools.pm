package NGS::Tools::GATK::Roles::GATKTools;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;

=head1 NAME

NGS::Tools::GATK::Roles::GATKTools

=head1 SYNOPSIS

A Perl Moose role for handling various auxillary tools within the GATK framework.

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->CatVariants()

A method that wraps GATK's CatVariants subprogram.

=head3 Arguments:

=over 2

=item * vcf: an array reference containing VCFs to concatenate

=back

=cut

sub CatVariants {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        vcf => {
            isa         => 'ArrayRef',
            required    => 1
            },
        output => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            },
        reference => {
            isa         => 'Str',
            required    => 1
            },
        java => {
            isa         => 'Str',
            required    => 0,
            default     => 'java'
            },
        gatk => {
            isa         => 'Str',
            required    => 0,
            default     => '${GATKROOT}/GenomeAnalysisTK.jar'
            }
        );

    my $output;
    if ($args{'output'} eq '') {
        $output = join('.',
            File::Basename::basename($args{'vcf'}->[0], qw(.vcf)),
            'merged',
            'vcf'
            );
        }
    else {
        $output = $args{'output'};
        }

    my $program = join(' ',
        $args{'java'},
        '-cp',
        $args{'gatk'},
        'org.broadinstitute.gatk.tools.CatVariants'
        );

    my $vcf_files = '';
    foreach my $vcf (@{ $args{'vcf'} }) {
        $vcf_files = join(' ',
            $vcf_files,
            '-V',
            $vcf
            );
        }
    my $options = join(' ',
        '-R', $args{'reference'},
        $vcf_files,
        '-out', $output,
        '-assumeSorted'
        );

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

=head2 $obj->convert_haplotype_vcf_to_annovar()

Convert the haplotype VCF file to an ANNOVAR compatible input file.

=head3 Arguments:

=over 2

=item * vcf: input VCF file to convert to ANNOVAR compatible file

=back

=cut

sub convert_haplotype_vcf_to_annovar {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        vcf => {
            isa         => 'Str',
            required    => 1
            }
        );



    my %return_values = (

        );

    return(\%return_values);
    }

=head1 AUTHOR

Richard de Borja, C<< <richard.deborja at sickkids.ca> >>

=head1 ACKNOWLEDGEMENT

Dr. Adam Shlien, PI -- The Hospital for Sick Children

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-test at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc NGS::Tools::GATK::Roles::GATKTools

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

1; # End of NGS::Tools::GATK::Roles::GATKTools
