use Test::More tests => 2;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;
use HPF::PBS;
use File::ShareDir ':ALL';

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
    { class_basename => 'Test' }
    );

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::UnifiedGenotyper');

# instantiate the test class based on the given role
my $gatk;
my $bam = 'test.bam';
lives_ok
    {
        $gatk = $test_class->new(
            dbsnp => 'dbsnp.vcf',
            java => 'java',
            gatk => 'gatk',
            reference => 'hg19.fa',
            );
        }
    'Class instantiated';

my $gatk_ug_memory = 10;
my $gatk_ug = $gatk->ug(
    bam => $bam,
    interval => '22',
    memory => $gatk_ug_memory
    );

my $expected_cmd = join(' ',
    'java -Xmx10g',
    '-jar gatk',
    '-T UnifiedGenotyper',
    '-I test.bam',
    '-R hg19.fa',
    '--dbsnp dbsnp.vcf',
    '-o test.snv.vcf',
    '--output_mode EMIT_VARIANTS_ONLY',
    '-rf BadCigar',
    '--min_indel_count_for_genotyping 5',
    '--max_deletion_fraction 0.50',
    '--min_base_quality_score 20',
    '-stand_call_conf 30',
    '-stand_emit_conf 10',
    '-glm BOTH',
    '-L 22'
    );
is($gatk_ug->{'cmd'}, $expected_cmd, "GATK UnifiedGenotyper commad matches expected");
