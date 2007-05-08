package Egg::Helper::Plugin::Cache;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Cache.pm 110 2007-05-08 01:12:54Z lushe $
#

=head1 NAME

Egg::Helper::Plugin::Cache - Helper for Egg::Plugin::Cache.

=head1 SYNOPSIS

  % perl MyApp/bin/myapp_helper.pl Plugin:Cache [NewCacheName]

=head1 DESCRIPTION

It is a plugin to generate the cashe controller who uses it with Egg::Plugin::Cache.

The file named lib/MyApp/Cache/NewCacheName.pm is generated to the project when
starting like the example of SYNOPSIS. This module becomes a cash controller.

Cashe driver's default L<Cache::FileCache>

If the name passed to 'include' method is changed, an arbitrary cash module can
be used.

  __PACKAGE__->include('Cache::Memcached');

Please match the setting passed to 'config' method to the use environment and
change. This setting extends to the cash module as it is.

  __PACKAGE__->config(
    servers            => ['127.0.0.1::11211'],
    debug              => 0,
    compress_threshold => 10_000,
    );

Additionally, I think it is convenient when the code that relates to cash is
added and used.

  sub get_member_data {
    my $cache= shift;
    my $uid  = shift || croak q{ I want uid. };
    $cache->get($uid) || do {
         my $member_data= $e->model->restore_member_data;
         $cache->set($uid => $member_data);
         $member_data;
      };
  }

=cut
use strict;
use warnings;

our $VERSION = '2.00';

sub _execute {
	my($self)= @_;
	my $g    = $self->global;
	my $conf = $self->load_project_config;
	$g->{libdir}= $conf->{dir}{lib}
	           || die q{ I want config ' dir -> lib '. };
	-e $g->{libdir} || die q{ ' dir -> lib ' is not found. };

	return $self->_output_help if ($g->{help} or ! $g->{any_name});

	$g->{cache_name}= $g->{any_name}=~/\:/
	   ? return $self->_output_help(qq{ Bad cashe name '$g->{any_name}'. })
	   : $g->{any_name};
	$g->{test_number}= $self->testfile_number_now;

	my $pname= $self->project_name;
	my $name = $self->mod_name_resolv($pname, "Cache:$g->{cache_name}");
	$self->_setup_module_maker( __PACKAGE__ );
	$self->_setup_module_name($name);

	-e "$g->{libdir}/$g->{module_filename}"
	   and die qq{ '$g->{libdir}/$g->{module_filename}' already exists. };

	my @files= YAML::Load( join '', <DATA> );
	$self->generate(
	  chdir        => [ $self->project_root, 1 ],
	  create_files => \@files,
#	  makemaker_ok => 1,
	  errors => { unlink=> [
	    "$g->{libdir}/$g->{module_filename}",
	    "$g->{project_root}/t/$g->{test_number}_$g->{cache_name}.t",
	    ] },
	  ) || return 0;

	print <<END_INFO;

Cache controller generate is completed.

output: $g->{libdir}/$g->{module_filename}

END_INFO
}
sub _output_help {
	my $self = shift;
	my $msg  = $_[0] ? "$_[0]\n\n": "";
	my $pname= lc($self->project_name);
	print <<END_HELP;

${msg}Usage: perl ${pname}_helper.pl Plugin:Cache [NewCache]

END_HELP
}

=head1 SEE ALSO

L<Cache::Cache>,
L<Egg::Plugin::Cache>,
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

__DATA__
---
filename: <$e.libdir>/<$e.module_filename>
value: |
  package <$e.module_distname>;
  #
  # Copyright (C) <$e.headcopy>, All Rights Reserved.
  # <$e.author>
  #
  # <$e.revision>
  #
  use strict;
  use warnings;
  
  our $VERSION= '<$e.module_version>';
  
  __PACKAGE__->include('Cache::FileCache');
  
  __PACKAGE__->config(
    namespace         => '<$e.cache_name>',
    cache_root        => '\<$e.dir.cache>',
    cache_depth       => 3,
    default_expires_in=> 360,
    );

  1;

  __END__

  #
  # Example of code.
  #
  # sub pod_list {
  #    my($self)= @_;
  #    $self->cache->get('pod_list') || do {
  #        my $podpath= '/path/to/lib';
  #        my @list;
  #        push @list, $pod for ( filefind( ... ) );
  #        $self->cache->set('pod_list' => \@list);
  #        \@list;
  #      };
  # }
  # sub pod_body {
  #    my $self= shift;
  #    my $pod = shift || return 0;
  #    $self->cache->get("pod_body_$pod") || do {
  #        my $body= $self->e->pod2html_body($pod) || return 0;
  #        $self->cache->set("pod_body_$pod" => $body);
  #        $body;
  #      };
  # }
  #
  
  <$e.document>
---
filename: t/<$e.test_number>_<$e.cache_name>.t
value: |
  
  use strict;
  use Test::More tests => 2;
  BEGIN { use_ok('Egg::Plugin::Cache') };
  
  {
    no strict 'refs';
    push @{"<$e.module_distname>::ISA"}, 'Egg::Plugin::Cache::handler';
    };
  
  require_ok( '<$e.module_distname>' );
