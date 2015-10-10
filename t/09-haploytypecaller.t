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
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::HaplotypeCaller');

# instantiate the test class based on the given role
my $gatk;
my $bam = 'test.bam';
my $reference = 'reference.fa';
lives_ok
    {
        $gatk = $test_class->new();
        }
    'Class instantiated';

my $haplo_run = $gatk->call_haplotype(
    bam => $bam,
    reference => $reference,
    dbsnp => 'dbsnp.vcf'
    );
my $expected_haplo_command = join(' ',
    'java',
    '-Xmx10g',
    '-jar ${GATK}',
    '-T HaplotypeCaller',
    '-R reference.fa',
    '-I test.bam',
    '-o test.hap_snv.vcf',
    '--dbsnp dbsnp.vcf',
    '--output_mode EMIT_VARIANTS_ONLY',
    '-rf BadCigar',
    '--min_base_quality_score 20',
    '-stand_call_conf 30',
    'stand_emit_conf 10'
    );
is($haplo_run->{'cmd'}, $expected_haplo_command, 'Haplotype Caller command matches expected')
;