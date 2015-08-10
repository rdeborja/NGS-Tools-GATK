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
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::CombineVariants');

# instantiate the test class based on the given role
my $gatk;
my @variants = ('input1.vcf', 'input2.vcf');

lives_ok
    {
        $gatk = $test_class->new();
        }
    'Class instantiated';

my $gatk_run = $gatk->combine_variants(
    vcf => \@variants,
    sample => 'sample1',
    output => 'output.vcf',
    reference => 'reference.fasta',
    memory => 6
    );

my $expected_command = join(' ',
    'java',
    '-Xmx6g',
    '-jar $GATK',
    '-T CombineVariants',
    '-R reference.fasta',
    '-o output.vcf',
    ' --variant input1.vcf',
    '--variant input2.vcf'
    );
is($gatk_run->{'cmd'}, $expected_command, "Command matches expected");
