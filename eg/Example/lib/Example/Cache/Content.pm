package Example::Cache::Content;
#
# Copyright (C) Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id$
#
use strict;
use warnings;

our $VERSION= '0.01';

__PACKAGE__->include('Cache::FileCache');

__PACKAGE__->config(
  namespace         => 'Content',
  cache_root        => '< $e.dir.cache >',
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

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Example::Cache::Content - Perl extension for ...

=head1 SYNOPSIS

  use Example::Cache::Content;

  ... tansu, ni, gon, gon.

=head1 DESCRIPTION

Stub documentation for Example::Cache::Content, created by Egg::Helper::Plugin::Cache v2.00

Blah blah blah.

=head1 SEE ALSO

L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>http://egg.bomcity.com/E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
