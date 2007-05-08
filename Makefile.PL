use inc::Module::Install;

name         'Egg-Plugin-Cache';
author       'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>';
all_from     'lib/Egg/Plugin/Cache.pm';
version_from 'lib/Egg/Plugin/Cache.pm';
license      'perl';

requires 'Egg::Release' => 2.00;
requires 'Cache::Cache' => 1.05;

build_requires 'Test::Simple';
build_requires 'Test::Pod';
build_requires 'Test::Perl::Critic';
build_requires 'Test::Pod::Coverage';

use_test_base;
auto_include;
WriteAll;
