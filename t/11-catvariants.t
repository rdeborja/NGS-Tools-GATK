use Test::More tests => 2;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
    { class_basename => 'Test' }
    );

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::GATKTools');

# instantiate the test class based on the given role
my $gatk;
lives_ok
    {
        $gatk = $test_class->new();
        }
    'Class instantiated';

my $reference = 'ref.fa';
my $vcf_file_array = [
    'file1.vcf',
    'file2.vcf',
    'file3.vcf'
    ];
my $gatk_catvariants = $gatk->CatVariants(
    vcf => $vcf_file_array,
    reference => $reference
    );
my $expected_cmd = join(' ',
    'java -cp ${GATKROOT}/GenomeAnalysisTK.jar',
    'org.broadinstitute.gatk.tools.CatVariants',
    '-R ref.fa',
    ' -V file1.vcf',
    '-V file2.vcf',
    '-V file3.vcf',
    '-out file1.merged.vcf',
    '-assumeSorted'
    );
is($gatk_catvariants->{'cmd'}, $expected_cmd, 'GATK CatVariants command matches expected');
