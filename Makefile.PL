use inc::Module::Install;

name         'Egg-Plugin-Cache';
author       'Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>';
all_from     'lib/Egg/Plugin/Cache.pm';
version_from 'lib/Egg/Plugin/Cache.pm';
license      'perl';

requires 'Egg::Release' => 1.09;
requires 'Cache::Cache' => 1.05;
requires 'File::Find';

build_requires 'Test::More';
build_requires 'Test::Pod';

use_test_base;
auto_include;
WriteAll;
