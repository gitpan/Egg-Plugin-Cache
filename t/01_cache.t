
use Test::More tests=> 5;
use Egg::Helper;

my $t= Egg::Helper->run('O:Test');

my $file= $t->yaml_load( join '', <DATA> );

$t->prepare(
  controller=> { egg=> [qw{ Cache }] },
  create_files=> [$file],
  );

my $e1= $t->egg_virtual;
my $e2= $t->egg_virtual;

ok( $e1 ne $e2 );
ok( my $cache1= $e1->cache('TestCache') );
ok( my $cache2= $e2->cache('TestCache') );
$cache1->set('test' => 1 );
is $cache2->get('test'), 1;
$cache2->set('test' => 2 );
is $cache1->get('test'), 2;


__DATA__
filename: lib/<# project_name #>/Cache/TestCache.pm
value: |
 package <# project_name #>::Cache::TestCache;
 use strict;
 use warnings;
 
 __PACKAGE__->include('Cache::FileCache');
 
 __PACKAGE__->config(
   namespace  => 'TestTest',
   cache_root => '<# project_root #>/tmp',
   );
 
 1;
