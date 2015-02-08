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
my $test_class = $test_class_factory->class_for('NGS::Tools::GATK::Roles::RealignerTargetCreator');

# instantiate the test class based on the given role
my $gatk;
lives_ok
    {
        $gatk = $test_class->new(
            tmpdir => '/tmp'
            );
        }
    'Class instantiated';

my $targetcreator = $gatk->RealignerTargetCreator(
    bam => 'test.bam',
    reference => 'ref.fa'
    );
print $targetcreator->{'cmd'}, "\n";
my $expected_command = join(' ',
    'java',
    '-Xmx24g',
    '-Djava.io.tmpdir=/tmp',
    '-jar ${GATK}',
    '-T RealignerTargetCreator',
    '-I test.bam',
    '-R ref.fa',
    '-l INFO',
    '-o test.intervals'
    );
is ($targetcreator->{'cmd'}, $expected_command, 'RealignerTargetCreator command matches expected');