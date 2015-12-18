use Test::More tests => 3;
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
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::MuTect2');

# instantiate the test class based on the given role
my $mutect;
my $normal = 'normal.bam';
my $tumour = 'tumour.bam';
my $sample = 'sample';
my $cosmic = 'cosmic.vcf';
my $dbsnp = 'dbsnp.vcf';
my $reference = 'ref.fa';
lives_ok
    {
        $mutect = $test_class->new();
        }
    'Class instantiated';

my $mutect_run = $mutect->run_mutect(
    normal => $normal,
    tumour => $tumour,
    sample => $sample,
    cosmic => $cosmic,
    dbsnp => $dbsnp,
    reference => $reference,
#    intervals => ['1', '2']
    );

my $expected_1_cmd = join(' ',
    "java -Xmx4g -Djava.io.tmpdir=./tmp -jar",
    "GenomeAnalysisTK.jar -T MuTect2",
    "-R ref.fa",
    "-I:tumor tumour.bam",
    "-I:normal normal.bam",
    "--cosmic cosmic.vcf",
    "--dbsnp dbsnp.vcf",
    "--intervals 1",
    "-o sample.1.vcf"
    );
is($mutect_run->{'1'}->{'cmd'}, $expected_1_cmd, "Command 1 matches expected");
my $expected_2_cmd = join(' ',
    "java -Xmx4g -Djava.io.tmpdir=./tmp -jar",
    "GenomeAnalysisTK.jar -T MuTect2",
    "-R ref.fa",
    "-I:tumor tumour.bam",
    "-I:normal normal.bam",
    "--cosmic cosmic.vcf",
    "--dbsnp dbsnp.vcf",
    "--intervals 2",
    "-o sample.2.vcf"
    );
is($mutect_run->{'2'}->{'cmd'}, $expected_2_cmd, "Command 2 matches expected");
print Dumper($mutect_run);