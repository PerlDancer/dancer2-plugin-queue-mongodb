use 5.006;
use strict;
use warnings;
use Test::More 0.96 import => ['!pass'];

use MongoDB 0.45;
use MongoDBx::Queue;

my $conn = eval { MongoDB::Connection->new; };
plan skip_all => "No MongoDB on localhost" unless $conn;

{

  use Dancer;
  use Dancer::Plugin::Queue;

  set show_errors => 1;

  set plugins => {
    Queue => {
      default => {
        class   => 'MongoDB',
        options => { db_name => 'dpqm_test' },
      },
    }
  };

  get '/add' => sub {
    queue->add_msg( params->{msg} );
    my ( $msg, $body ) = queue->get_msg;
    queue->remove_msg($msg);
    return $body;
  };
}

use Dancer::Test;

route_exists [ GET => '/add' ], 'GET /add handled';

response_content_like [ GET => '/add?msg=Hello%20World' ], qr/Hello World/i,
  "sent and received message";

done_testing;
