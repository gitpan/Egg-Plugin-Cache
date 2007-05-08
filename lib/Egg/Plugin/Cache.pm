package Egg::Plugin::Cache;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Cache.pm 109 2007-05-08 01:11:58Z lushe $
#

=head1 NAME

Egg::Plugin::Cache - cache for Egg plugin.

=head1 SYNOPSIS

  use Egg qw/ Cache /;

  package MyApp::Cache::MyCache;
  
  __PACKAGE__->include('Cache::FileCache');
  
  __PACKAGE__->config(
    namespace          => 'TestTest',
    cache_root         => '/path/to/MyApp/cache',
    cache_depth        => 3,
    default_expires_in => 3600,
    );

  # The cashe object is acquired.
  my $cache= $e->cache('MyCache');
  
  # The data that has been cached is acquired.
  my $data = $cache->get('cache_key');
  
  # Data is set in the cache.
  $cache->set( cache_key => $data );

=head1 DESCRIPTION

It is a plugin to treat cashe.

An arbitrary cashe module can be used as a cashe driver.

A special cashe controller is necessary in each cashe driver that uses it. 

The cashe controller is generable by the use of L<Egg::Helper::Plugin::Cache>.

  % perl MyApp/bin/myapp_helper.pl Plugin:Cache [NEW_CACHE_NAME]

Default driver of generated cashe controller L<Cache::FileCache>.
Please change this when you want to load other cashe modules.

HASH set in config is passed by the reference as it is by the constructor of
the cashe module.

Please refer to the document of the module used for the method of setting config.

=cut
use strict;
use warnings;
use UNIVERSAL::require;
use File::Find;
use Carp qw/croak/;

our $VERSION= '2.00';

sub _setup {
	my($e)= @_;
	my $pname = $e->namespace;
	my $dirregix= my $libdir= $e->config->{dir}{lib};
	   $dirregix=~s{\\} [\\\\]g;
	my $comps = $e->global->{PLUGIN_CACHE}= {};
	my $wanted= sub {
		$File::Find::name=~m{^$dirregix/($pname/Cache/.+?)\.pm$};
		my $pkg= my $cname= $1 || return;
		$pkg  =~s{\/} [::]g;
		$cname=~s{\/} [_]g;
		$comps->{$pkg}= $cname;
	  };
	no strict 'refs';  ## no critic
	no warnings 'redefine';
	File::Find::find($wanted, $libdir);
	while (my($pkg, $cname)= each %$comps) {
		push @{"${pkg}::ISA"}, 'Egg::Plugin::Cache::handler';
		$pkg->require or die $@;
		*{"${pkg}::__cache_$cname"}=
		   Egg::Plugin::Cache::handler->__create_cache($pkg);
	}
	if ($e->debug) {
		$e->debug_out("# + $e->{namespace} - plugin_cache: "
		. join(', ', map{ ($comps->{$_}=~m{([^_]+)$})[0] }keys %$comps) );
	}
	$e->next::method;
}

=head1 METHODS

=head2 cache ( [CACHE_NAME] )

The handler object of CACHE_NAME is returned.

CACHE_NAME is cashe controller's name.

  my $cache= $e->cache('CacheControllerName');

=cut
sub cache {
	my $e  = shift;
	my $pkg= shift || croak q{ I want Cache name. };
	$e->{"plugin_cache_$pkg"} ||= "$e->{namespace}::Cache::$pkg"->new($e);
}

package Egg::Plugin::Cache::handler;
use strict;
use base qw/Egg::Base/;

=head1 HANDLER METHODS

=head2 cache

The object of the cashe module read as a driver is returned.

It calls it through this method if there is a peculiar method to the cashe module.

  $e->cache('CacheName')->cache;

=cut
__PACKAGE__->mk_accessors(qw/ cache /);

=head2 new

Constructor who returns handler object.

=cut
sub new {
	my($class, $e)= @_;
	my $cname= $e->global->{PLUGIN_CACHE}{$class}
	   || die qq{ Cache of '$class' is not setup. };
	   $cname= "__cache_$cname";
	bless { e=> $e, cache=> $class->$cname }, $class;
}

=head2 get, set, clear, remove, purge

It is an accessor to the cashe driver.

If it is a method not being supported by the cashe driver, the exception is generated.

  my $data= $e->cache('CacheName')->get('cache_key');

=cut
sub get    { shift->cache->get(@_)    }
sub set    { shift->cache->set(@_)    }
sub clear  { shift->cache->clear(@_)  }
sub remove { shift->cache->remove(@_) }
sub purge  { shift->cache->purge(@_)  }

sub __create_cache {
	my($class, $pkg)= @_;
	my $driver= $pkg->include_packages->[0]
	   || die q{ I want Cashe driver in include. };
	my $config= $pkg->config
	   || die q{ I want setup of config. };
	my $cache;
	sub { $cache ||= $driver->new($config) };
}

=head1 SEE ALSO

L<Cache::FileCache>,
L<Egg::Helper::Plugin::Cache>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
