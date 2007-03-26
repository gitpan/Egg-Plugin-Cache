
use Test::More qw/no_plan/;
use Egg::Helper;

my $t= Egg::Helper->run('O:Test');
my $g= $t->global;

my $start_dir= $g->{start_dir};

ok( $t->prepare( extend_lib=> " $start_dir/lib $start_dir/../lib " ) );

my $pname= $t->project_name;

if (my $perl_path= $t->perl_path ) {
	my $lcname= lc($t->project_name);
	chdir($t->path_to('bin'));
	eval{ `$perl_path $lcname\_helper.pl P:Cache TestHelper` };
	ok( -e $t->path_to('lib')."/$pname/Cache/TestHelper.pm" );
	chdir($start_dir);
	ok( ! $@ );
}

