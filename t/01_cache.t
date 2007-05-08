
use Test::More tests => 18;
use Egg::Helper::VirtualTest;

my $t= Egg::Helper::VirtualTest->new;
$t->prepare(
  controller   => { egg_includes=> [qw/ Cache /] },
  create_files => [ $t->yaml_load( join '', <DATA> ) ],
  );
my $g= $t->global;

ok -e "$g->{project_root}/lib/$g->{project_name}/Cache/TestCache.pm";

ok my $e1= $t->egg_pcomp_context;
ok my $e2= $t->egg_pcomp_context;
ok $e1 ne $e2;

ok  my $cache1= $e1->cache('TestCache');
isa_ok $cache1, 'VirtualTest::Cache::TestCache';
isa_ok $cache1, 'Egg::Plugin::Cache::handler';
isa_ok $cache1->cache, 'Cache::FileCache';

is $cache1->config->{cache_root}, "$g->{project_root}/cache";

ok  my $cache2= $e2->cache('TestCache');
isa_ok $cache2, 'VirtualTest::Cache::TestCache';
isa_ok $cache2, 'Egg::Plugin::Cache::handler';
isa_ok $cache2->cache, 'Cache::FileCache';

$cache1->cache->set( test => 1 );
is $cache1->cache->get('test'), 1;
is $cache2->cache->get('test'), 1;

$cache1->set( test => 2 );
is $cache1->get('test'), 2;
is $cache2->get('test'), 2;

$cache2->set( test => 3 );
is $cache1->get('test'), 3;


__DATA__
filename: lib/<$e.project_name>/Cache/TestCache.pm
value: |
 package <$e.project_name>::Cache::TestCache;
 use strict;
 use warnings;
 
 __PACKAGE__->include('Cache::FileCache');
 
 __PACKAGE__->config(
   namespace  => 'TestTest',
   cache_root => '\<$e.dir.cache>',
   );
 
 1;
