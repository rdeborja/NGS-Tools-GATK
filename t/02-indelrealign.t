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
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::IndelRealigner');

# instantiate the test class based on the given role
my $gatk;
lives_ok
	{
		$gatk = $test_class->new(
            tmpdir => '/tmp'
            );
		}
	'Class instantiated';

my $bam = 'test.bam';
my $reference = 'test.fa';
my $target = 'target.intervals';
my $run_indelrealign = $gatk->IndelRealigner(
	bam => $bam,
	reference => $reference,
    target => $target
	);
my $expected_command = join(' ',
	"java -Xmx24g",
    '-Djava.io.tmpdir=/tmp',
    '-jar ${GATK}',
 	'-T IndelRealigner',
    '-I test.bam',
    '-R test.fa',
    '-targetIntervals target.intervals',
	'-o test.indelrealigned.bam',
    '-compress 0'
	);
is($run_indelrealign->{'cmd'}, $expected_command, "Command matches expected")
