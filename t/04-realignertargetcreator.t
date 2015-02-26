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
    reference => 'ref.fa',
    memory => 24
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

my $modules_to_load = [
    'gatk/2.8.1',
    'picard-tools/1.108',
    'samtools',
    'shlienlab'
    ];
my $template_dir = join('/', dist_dir('HPF'), 'templates');
my $template = 'submit_to_pbs.template';
my $pbs = HPF::PBS->new();
my $targetcreator_run = $pbs->create_cluster_shell_script(
    command => $targetcreator->{'cmd'},
    jobname => join('.', 'sample', 'targetcreator'),
    template_dir => $template_dir,
    template => $template,
    modules_to_load => $modules_to_load,
    walltime => '100:00:00',
    localhd => '100',
    memory => 32
    );
