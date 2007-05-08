
use Test::More qw/no_plan/;
use Egg::Helper::VirtualTest;

my $t= Egg::Helper::VirtualTest->new( prepare=> {} );
my $g= $t->global;

ok $t->helper_run('Plugin:Cache', 'TestCache');

SKIP: {

unless ( -e "$g->{libdir}/$g->{module_filename}" ) {
	skip q{ Windows cannot be tested well. } if $t->is_win32;
	ok 0;
}

eval{ $t->helper_run('Plugin:Cache', 'TestCache') };
ok $@;
like $@, qr{\balready\s+exists}s;

ok -e "$g->{libdir}/$g->{module_filename}";

eval{ $t->helper_run('Plugin:Cache', 'TestCache::Test') };
ok ! -e "$g->{libdir}/$g->{project_name}/Cache/TestCache/Test.pm";

  };
