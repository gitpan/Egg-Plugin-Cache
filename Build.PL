use Module::Build;

my $builder = Module::Build->new(

  module_name       => 'Egg::Plugin::Cache',
  dist_version_from => 'lib/Egg/Plugin/Cache.pm',
  dist_author       => 'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>',
  license           => 'perl',

  requires => {
    'Egg::Release'=> 1.09,
    'Cache::Cache'=> 1.05,
    'File::Find'  => 0,
    'Test::More'  => 0,
    'Test::Pod'   => 0,
    },

  );

$builder->create_build_script();
