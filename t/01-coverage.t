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
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::DepthOfCoverage');

# instantiate the test class based on the given role
my $gatk;
lives_ok
	{
		$gatk = $test_class->new();
		}
	'Class instantiated';

my $bam = "$Bin/data/01-test.bam";
my $ref = "$Bin/data/01-test.fa";
my $gatk_jar = "/usr/local/sw/gatk/GenomeAnalysisTK.jar";
my $gatk_coverage = $gatk->generate_depth_of_coverage(
	bam => $bam,
	ref => $ref,
	gatk => $gatk_jar
	);
my $expected_cmd = join(' ',
	'java -Xmx8g -jar',
	'/usr/local/sw/gatk/GenomeAnalysisTK.jar',
	'-T DepthOfCoverage',
	'-o 01-test.gatk.depthofcoverage',
	"-I $bam",
	"-R $ref"
	);

is($gatk_coverage->{'cmd'}, $expected_cmd, "GATK DepthOfCoverage command matches expected");
