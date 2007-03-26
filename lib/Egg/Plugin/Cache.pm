package Egg::Plugin::Cache;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Cache.pm 68 2007-03-26 01:48:54Z lushe $
#
use strict;
use warnings;
use UNIVERSAL::require;
use File::Find;

our $VERSION= '0.04';

sub setup {
	my($e)= @_;
	my $pname = $e->namespace;
	my $libdir= $e->config->{lib_root};
	my $comps = $e->global->{PLUGIN_CACHE}= {};
	my $wanted= sub {
		$File::Find::name=~m{^$libdir/($pname/Cache/.+?)\.pm$};
		my $pkg= my $cname= $1 || return;
		$pkg=~s{\/} [::]g;
		$cname=~s{\/} [_]g;
		$comps->{$pkg}= $cname;
	  };
	File::Find::find($wanted, $libdir);
	no strict 'refs';  ## no critic
	while (my($pkg, $cname)= each %$comps) {
		push @{"$pkg\::ISA"}, 'Egg::Plugin::Cache::handler';
		$pkg->require or Egg::Error->throw($@);
		*{"Egg::Plugin::Cache::handler::__cache_$cname"}=
		   Egg::Plugin::Cache::handler->__create_cache($pkg);
	}
	$e->next::method;
}
sub cache {
	my $e= shift;
	my $pkg= shift || Egg::Error->throw('I want Cache name.');
	$e->{"plugin_cache_$pkg"} ||= do {
		$pkg= $e->namespace."::Cache::$pkg";
		$pkg->new($e, $pkg);
	  };
}

package Egg::Plugin::Cache::handler;
use strict;
use base qw/Egg::Base/;

__PACKAGE__->mk_accessors(qw/cache/);

sub new {
	my($class, $e)= @_;
	my $cname= $e->global->{PLUGIN_CACHE}{$class}
	   || Egg::Error->throw("Cache of '$class' is not setup.");
	   $cname= "__cache_$cname";
	my $cache= $class->$cname;
	$cache->ATTACH_CONTEXT($e) if $cache->can('ATTACH_CONTEXT');
	bless { e=> $e, cache=> $cache }, $class;
}
sub __create_cache {
	my($class, $pkg)= @_;
	my $driver= $pkg->include_packages->[0]
	   || Egg::Error->throw('I want Cashe driver in include.');
	my $config= $pkg->config
	   || Egg::Error->throw('I want setup of config.');
	my $cache;
	sub { $cache ||= $driver->new($config) };
}
sub get    { shift->cache->get(@_)    }
sub set    { shift->cache->set(@_)    }
sub clear  { shift->cache->clear(@_)  }
sub remove { shift->cache->remove(@_) }
sub purge  { shift->cache->purge(@_)  }

1;

__END__

=head1 NAME

Egg::Plugin::Cache - Cache for Egg.

=head1 SYNOPSIS

  # Generation of cash control module.
  cd /MYPROJECT/bin
  perl myproject_helper.pl P:Cache MyCache

  # /MYPROJECT/lib/MYPROJECT/Cache/MyCache.pm is edited.
  package MYPROJECT::Cache::MyCache;
  use strict;
  
  __PACKAGE__->include('Cache::FileCache');
  
  __PACKAGE__->config( ... Cache Module option );
  
  sub get_data {
    my($self)= @_;
    $self->cache->get('KEY') || do {
        my $data;
        ... Code to acquire data.
        $self->cache->set('KEY' => $data);
        $data;
      };
  }

Control file.

  use MYPROJECT;
  use strict;
  use Egg qw{ Cache };

Example of code.

  if ( my $data= $e->cache('MyCache')->get_data ) {
    print "Data : $data";
  } else {
    print "Data is not found.";
  }
  
  # If you treat data directly.
  my $data = $e->cache('MyCache')->cache->get('KEY') || do {
    my $tmp;
    ... Code to acquire data.
    $e->cache('MyCache')->cache->set('KEY' => $tmp);
    $tmp;
  }
  ...
  ......

=head1 DESCRIPTION

This plug-in is made to be able to treat the cash module conveniently and simply.

It is made to use by making the code a capsule in each kind of cash.
As a result, it comes to be able to describe the code of the main simply.

First of all, please generate the cash control module with the project helper
to use it.

  perl myproject_helper.pl P:Cache NewCache

/MYPROJECT_ROOT/lib/MYPROJECT/Cache/NewCache.pm is made from this.

Cache::FileCache is used in default, and edit it, please by the cash module used.

  __PACKAGE__->include('Cache::FileCache');

The cash module used in this part is specified.
This reads the specified module, and marks the module.

  __PACKAGE__->config( .... );

This part is an option to pass to the read cash module.
This setting is passed by the HASH reference by the constructor of the cash module.

It is only this in default. The code in which it specializes in the cash will be
added now.

  sub list_data {
    my($self)= @_;
    $self->cache->get('LIST_KEY') || do {
        my $data;
        ... Code to acquire data.
        $self->cache->set('LIST_KEY' => $data);
        $data;
      };
  }

=head1 METHODS

=head2 cache ([CACHE_NAME])

Cache controller's object is returned. 

Please give the name since MYPROJECT::Cache.

  my $cache= $e->cache('NewCache');

=head2 $cache->cache

The cash object specified by __PACKAGE__-E<gt>include is returned.

=head2 $cache->get, $cache->set, $cache->clear, $cache->remove, $cache->purge

These methods are accessors to $cache-E<gt>cache->*.

Function stripes cork in cash module to which correspondence method is not supported.

=head2 setup

It is a method for the start preparation that is called from the controller of 
the project. * Do not call it from the application.

=head1 SEE ALSO

L<Egg::Helper::P::Cache>
L<Egg::Base>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
