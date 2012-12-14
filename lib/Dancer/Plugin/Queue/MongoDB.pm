use 5.008001;
use strict;
use warnings;

package Dancer::Plugin::Queue::MongoDB;
# ABSTRACT: No abstract given for Dancer::Plugin::Queue::MongoDB
# VERSION

# Dependencies
use Moose;
use MongoDB;
use MongoDBx::Queue;

with 'Dancer::Plugin::Queue::Role::Queue';

=attr db_name

Name of the database to hold the queue collection. Required.

=cut

has db_name => (
  is       => 'ro',
  isa      => 'Str',
  required => 1,
);

=attr queue_name

Name of the collection that defines the queue. Defaults to 'queue'.

=cut

has queue_name => (
  is      => 'ro',
  isa     => 'Str',
  default => 'queue',
);

=attr connection_options

MongoDB::Connection options hash to create the connection to the database
holding the queue.  Empty by default, which means connecting to localhost
on the default port.

=cut

has connection_options => (
  is      => 'ro',
  isa     => 'HashRef',
  default => sub { {} },
);

=attr queue

The MongoDBX::Queue object that manages the queue.  Built on demand from
other attributes.

=cut

has queue => (
  is           => 'ro',
  isa          => 'MongoDBx::Queue',
  lazy_builder => 1,
);

sub _build_queue {
  my ($self) = @_;
  return MongoDBx::Queue->new(
    db   => $self->_mongodb_conn->get_database( $self->db_name ),
    name => $self->queue_name,
  );
}

has _mongodb_conn => (
  is         => 'ro',
  isa        => 'MongoDB::Connection',
  lazy_build => 1,
);

sub _build__mongodb_conn {
  my ($self) = @_;
  return MongoDB::Connection->new( $self->connection );
}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  # in config.yml

  plugins:
    Queue:
      default:
        class: MongoDB
        options:
          db_name: dancer_test
          queue_name: msg_queue
          connection_options:
            host: mongodb://localhost:27017

  # in Dancer app

  use Dancer::Plugin::Queue::MongoDB;

  get '/' => sub {
    queue->add_msg( $data );
  };

=head1 DESCRIPTION

This module implements a L<Dancer::Plugin::Queue> using L<MongoDBx::Queue>.

=head1 USAGE

See documentation for L<Dancer::Plugin::Queue>.

=head1 SEE ALSO

=for :list
* L<Dancer::Plugin::Queue>
* L<MongoDBx::Queue>
* L<MongoDB::Connection>

=cut

# vim: ts=2 sts=2 sw=2 et: