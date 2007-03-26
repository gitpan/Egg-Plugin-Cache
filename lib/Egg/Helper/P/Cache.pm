package Egg::Helper::P::Cache;
#
# Copyright 2007 Bee Flag, Corp. All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Cache.pm 68 2007-03-26 01:48:54Z lushe $
#
use strict;
use warnings;
use base qw/Egg::Component/;

our $VERSION= '0.02';

sub new {
	my $self= shift->SUPER::new();
	my $g= $self->global;
	return $self->help_disp if ($g->{help} || ! $g->{any_name});
	my $part= $self->check_module_name
	   ($g->{any_name}, $self->project_name, 'Cache');

	$self->setup_global_rc;
	$self->setup_document_code;
	$g->{created}= __PACKAGE__. " v$VERSION";
	$g->{lib_dir}= "$g->{project_root}/lib";
	$g->{cache_name}       = join('-' , @$part);
	$g->{cache_distname}   = join('::', @$part);
	$g->{cache_filename}   = join('/' , @$part). '.pm';
	$g->{cache_namespace}  = join('_' , @{$part}[2..$#{$part}]);
	$g->{cache_new_version}= 0.01;

	-e "$g->{lib_dir}/$g->{cache_filename}"
	  and die "It already exists : $g->{lib_dir}/$g->{cache_filename}";

	$g->{number}= $self->get_testfile_new_number("$g->{project_root}/t")
	    || die 'The number of test file cannot be acquired.';

	$self->{add_info}= "";
	chdir($g->{project_root});
	eval {
		my @list= $self->parse_yaml(join '', <DATA>);
		$self->save_file($g, $_) for @list;
##		$self->distclean_execute_make;
	  };
	chdir($g->{start_dir});

	if (my $err= $@) {
		unlink("$g->{lib_dir}/$g->{cache_filename}");
		die $err;
	} else {
		print <<END_OF_INFO;
... done.$self->{add_info}

END_OF_INFO
	}
}
sub output_manifest {
	my($self)= @_;
	$self->{add_info}= <<END_OF_INFO;

----------------------------------------------------------------
  !! MANIFEST was not able to be adjusted. !!
  !! Sorry to trouble you, but please edit MANIFEST later !!
----------------------------------------------------------------
END_OF_INFO
}
sub help_disp {
	my($self)= @_;
	my $pname= lc($self->project_name);
	print <<END_OF_HELP;
# usage: perl $pname\_helper.pl P:Cache [NEW_CACHE_NAME]

END_OF_HELP
}

1;

=head1 NAME

Egg::Helper::P::Cache - Cache module is generated for Egg::Helper.

=head1 SYNOPSIS

  cd /path/to/myproject/bin

  # Help is displayed.
  ./myproject_helper.pl P:Cache -h
  
  # A new dispatch module is generated.
  ./myproject_helper.pl P:Cache NewCache

=head1 DESCRIPTION

This module generates the skeleton of the cache module and the test file.

Skeleton for 'Cache::CacheFile' is generated in default.

Please edit this according to the usage.

Please see document of L<Egg::Plugin::Cache> of edit method in detail.

MANIFEST is not renewed in OS other than UNIX system.
Please edit it sorry to trouble you, but by yourself.

=over 4

=item METHODS... new, help_disp, output_manifest,

=back

=head1 SEE ALSO

L<Egg::Plugin::Cache>
L<Egg::Helper>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno, E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

__DATA__
---
filename: lib/<# cache_filename #>
value: |
  package <# cache_distname #>;
  #
  # Copyright (C) <# headcopy #>, All Rights Reserved.
  # <# author #>
  #
  # <# revision #>
  #
  use strict;
  use warnings;
  
  our $VERSION= '<# cache_new_version #>';
  
  __PACKAGE__->include('Cache::FileCache');
  
  __PACKAGE__->config(
    namespace         => '<# cache_namespace #>',
    cache_root        => '<# project_root #>/tmp',
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
  
  <# document #>
---
filename: t/<# number #>_<# cache_name #>.t
value: |
  
  use strict;
  use Test::More tests => 2;
  BEGIN { use_ok('Egg::Plugin::Cache') };
  
  {
    no strict 'refs';
    push @{"<# cache_distname #>::ISA"}, 'Egg::Plugin::Cache::handler';
    };
  
  require_ok( '<# cache_distname #>' );


