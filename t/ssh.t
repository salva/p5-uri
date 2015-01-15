#!perl -w

use strict;
use warnings;

use URI;
use URI::ssh;

use Test::More;
plan tests => 10;

sub ssh_test {
    my ($uri, %c) = @_;

    my $u = eval { URI->new($uri) };
    if ($c{bad}) {
        ok !defined($u), "$uri invalid";
    }
    else {
        ok defined($u), "$uri valid";
    SKIP: {
            skip "new failed", 7 unless defined $u;

            for (qw(scheme user host path password)) {
                is $u->$_, $c{$_}, "$uri $_";
            }

            is_deeply $u->c_params, $c{c_params}, "$uri c_params";

            my $as_string = delete $c{as_string};
            $as_string = $uri unless defined $as_string;
            is $u->as_string, $as_string, "$uri as_string";
        };
    }
}

ssh_test('ssh://user@host.example.com',
         scheme => 'ssh',
         user => 'user',
         host => 'host.example.com',
         port => 22,
         path => '');

ssh_test('ssh://user@host.example.com:2222',
         scheme => 'ssh',
         user => 'user',
         host => 'host.example.com',
         port => 2222,
         path => '');

ssh_test('ssh://user:6789@host.example.com:2222',
         scheme => 'ssh',
         user => 'user',
	 password => '6789',
         host => 'host.example.com',
         port => 2222,
         path => '');

ssh_test('ssh://user;fingerprint=ssh-dss-c1-b1-30-29-d7-b8-de-6c-77-10-d7-46-41-63-87@host.example.com',
         scheme => 'ssh',
         user => 'user',
         host => 'host.example.com',
         port => 2222,
         path => '',
         c_params => ['fingerprint=ssh-dss-c1-b1-30-29-d7-b8-de-6c-77-10-d7-46-41-63-87']);

ssh_test('ssh://user;key-file=id_dsa@host.example.com',
         scheme => 'ssh',
         user => 'user',
         host => 'host.example.com',
         port => 2222,
         path => '',
         c_params => ['key-file=id_dsa']);

ssh_test('ssh://user;fingerprint=ssh-dss-c1-b1-30-29-d7-b8-de-6c-77-10-d7-46-41-63-87,key-file=id_dsa@host.example.com',
         scheme => 'ssh',
         user => 'user',
         host => 'host.example.com',
         port => 2222,
         path => '',
         c_params => ['fingerprint=ssh-dss-c1-b1-30-29-d7-b8-de-6c-77-10-d7-46-41-63-87', 
                      'key-file=id_dsa']);

ssh_test('ssh://user:passwd;fingerprint=ssh-dss-c1-b1-30-29-d7-b8-de-6c-77-10-d7-46-41-63-87,key-file=id_dsa@host.example.com',
         scheme => 'ssh',
         user => 'user',
	 password => 'passwd',
         host => 'host.example.com',
         port => 2222,
         path => '',
         c_params => ['fingerprint=ssh-dss-c1-b1-30-29-d7-b8-de-6c-77-10-d7-46-41-63-87', 
                      'key-file=id_dsa']);

__END__

TODO:

Add support for scp and sftp URIs:

sftp://user@host.example.com/~/file.txt
sftp://user@host.example.com/dir/path/file.txt
sftp://user;fingerprint=ssh-dss-c1-b1-30-29-d7-b8-de-6c-97-77-10-d7-46-41-63-87@host.example.com:2222/;type=d


