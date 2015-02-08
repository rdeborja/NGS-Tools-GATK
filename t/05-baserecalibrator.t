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
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::BaseRecalibrator');

# instantiate the test class based on the given role
my $gatk;
my @knownsites = qw(dbsnp.vcf mills.vcf 1000g.vcf);
lives_ok
    {
        $gatk = $test_class->new();
        }
    'Class instantiated';

my $bam = 'test.bam';
my $reference = 'ref.fa';
my $baserecal = $gatk->BaseRecalibrator(
    bam => $bam,
    reference => $reference,
    number_of_cores => 4
    );

print $baserecal->{'cmd'}, "\n";

my $expected_cmd = join(' ',
    'java',
    '-Xmx26g',
#    '-Djava.io.tmpdir=/tmp',
    '-jar ${GATK}',
    '-T BaseRecalibrator',
    '-I test.bam',
    '-R ref.fa',
    '-o test.recal.table',
    '-l INFO',
    '-nct 4'
    );
is($baserecal->{'cmd'}, $expected_cmd, "Command matches expected");
