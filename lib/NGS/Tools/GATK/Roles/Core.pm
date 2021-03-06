package NGS::Tools::GATK::Roles::Core;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;

=head1 NAME

NGS::Tools::GATK::Roles::Core

=head1 SYNOPSIS

A set of Perl Moose attributes that are used amongst all GATK programs.

=head1 ATTRIBUTES AND DELEGATES

=head2 $obj->reference

Reference genome in FASTA format.

=cut

has 'reference' => (
    is          => 'rw',
    isa         => 'Str',
    required	=> 0,
    default		=> '',
    reader		=> 'get_reference',
    writer		=> 'set_reference'
    );

=head2 $obj->dbsnp

dbSNP file in VCF format.

=cut

has 'dbsnp' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 0,
    default     => '',
    reader      => 'get_dbsnp',
    writer      => 'set_dbsnp'
    );

=head2 $obj->known_sites

A list of known indel sites.

=cut

has 'known_sites' => (
    is          => 'rw',
    isa         => 'ArrayRef[Str]',
    required    => 0,
    default     => sub { return [] },
    reader		=> 'get_known_sites',
    writer		=> 'set_known_sites'
    );

=head2 $obj->gatk

Full path to the GenomeAnalysisTK.jar file.

=cut

has 'gatk' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 0,
    default     => '${GATK}',
    reader      => 'get_gatk',
    writer      => 'set_gatk'
    );

=head2 $obj->java

Full path to the Java program.

=cut

has 'java' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 0,
    default     => 'java',
    reader      => 'get_java',
    writer      => 'set_java'
    );

=head2 $obj->tmpdir

Full path to the temporary directory

=cut

has 'tmpdir' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 0,
    default     => '',
    reader      => 'get_tmpdir',
    writer      => 'set_tmpdir'
    );

=head2 $obj->validate_interval_file()

Validate the interval file.  The file must have an extension of interval_list and
should contain a BED like list of regions.

=head3 Arguments:

=over 2

=item * arg: argument

=back

=cut

sub validate_interval_file {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        arg => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            }
        );

    my %return_values = (

        );

    return(\%return_values);
    }

=head1 SUBROUTINES/METHODS

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

    perldoc NGS::Tools::GATK::Roles::Core

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

1; # End of NGS::Tools::GATK::Roles::Core
