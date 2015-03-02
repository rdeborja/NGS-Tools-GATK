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
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::PrintReads');

# instantiate the test class based on the given role
my $gatk;
my $bam = 'test.bam';
my $ref = 'ref.fa';
my $recal_table = 'test.recal.table';
lives_ok
    {
        $gatk = $test_class->new(
            tmpdir => "/tmp"
            );
        }
    'Class instantiated';

my $printreads = $gatk->PrintReads(
    bam => $bam,
    reference => $ref,
    bqsr => $recal_table,
    number_of_cores => 4,
    );
my $expected_cmd = join(' ',
    'java',
    '-Xmx24g',
    '-Djava.io.tmpdir=/tmp',
    '-jar ${GATK}',
    '-T PrintReads',
    '-I test.bam',
    '-R ref.fa',
    '-o test.recal.bam',
    '-nct 4',
    '-l INFO',
    '-BQSR test.recal.table'
    );
is($printreads->{'cmd'}, $expected_cmd, "Command matches expected");
