=head1 LICENSE

See the NOTICE file distributed with this work for additional information
   regarding copyright ownership.
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

=cut

package Bio::EnsEMBL::Tark::DB;

use warnings;
use strict;
use DBI;
use Carp;
use Digest::SHA1 qw(sha1);

use Config::General;
use Config::IniFiles; # FIXME normalise around one config format
use Bio::EnsEMBL::Tark::Schema;

#use MooseX::Singleton;
use Moose;
with 'MooseX::Log::Log4perl';

my $singleton;

has dsn => (
  is => 'ro',
  isa => 'Str',
);

has dbuser => (
  is => 'ro',
  isa => 'Str',
);

has dbpass => (
  is => 'ro',
  isa => 'Str',
);

has session_id => (
  is => 'rw',
  isa => 'Int',
  default => 0,
);

has schema => (
  isa => 'Bio::EnsEMBL::Tark::Schema',
  is => 'ro',
  builder => '_init_db'
);

has config => (
  isa => 'HashRef',
  is => 'rw',
);

has config_file => (
  isa => 'Str',
  is => 'rw',
  builder => '_guess_config'
);


=head2 _init_db
  Arg [1]    : HashRef of configuation parameters (driver, db, host, port, user, pass)
  Description: Initialise the core database.
  Return type: schema
  Caller     : internal

=cut

sub _init_db {
  my $self = shift;

  $self->_init_config if ! defined $self->config;
  $self->_validate_config($self->config);
  my %conf = %{ $self->config };
  my %opts;
  $opts{mysql_enable_utf8}    = 1 if ($conf{driver} eq 'mysql');
  $opts{mysql_auto_reconnect} = 1 if ($conf{driver} eq 'mysql');
  $opts{sqlite_unicode}       = 1 if($conf{driver} eq 'SQLite');
  my $dsn;
  if ($conf{driver} eq 'SQLite') {
    $dsn = sprintf 'dbi:%s:database=%s',$conf{driver},$conf{file};
    $self->now_function("date('now')");
  } else {
    $dsn = sprintf 'dbi:%s:database=%s;host=%s;port=%s', $conf{driver}, $conf{db}, $conf{host}, $conf{port};
  }

  my %deploy_opts = ();
  # Example deploy option $deploy_opts{add_drop_table} = 1;
  my $schema = Bio::EnsEMBL::Tark::Schema->connect($dsn, $conf{user}, $conf{pass}, \%opts);

  if ($conf{create} == 1 && $conf{driver} eq 'mysql') {
    my $dbh = DBI->connect(
      sprintf('DBI:%s:database=;host=%s;port=%s', $conf{driver}, $conf{host}, $conf{port}), $conf{user}, $conf{pass}, \%opts
    );

    # Remove database if already exists
    my %dbs = map {$_->[0] => 1} @{$dbh->selectall_arrayref('SHOW DATABASES')};
    my $dbname = $conf{db};
    if ($dbs{$dbname}) {
      $dbh->do( "DROP DATABASE $dbname;" );
    }

    $dbh->do("CREATE DATABASE $dbname;");

    $dbh->disconnect;
  }

  if ( $conf{create} == 1 ) {
    $schema->deploy(\%deploy_opts);
  }

  return $schema;
} ## end sub _init_db


=head2 _guess_config
  Description: Don't want production use to guess at least at the moment.
               This mainly exists so TestDB can override and replace with a
               useful default
  Return type: undef
  Caller     : internal

=cut

sub _guess_config {
  return;
} ## end sub _guess_config


=head2 _init_config
  Arg [1]    : HashRef of configuation parameters (driver, db, host, port, user, pass)
  Description: Initialisae the loading of the configuration file.
  Return type: HashRef - $self->config
  Caller     : internal

=cut

sub _init_config {
  my $self = shift;

  if (defined $self->config_file) {
    my $conf = Config::General->new($self->config_file);
    my %opts = $conf->getall();
    $self->config(\%opts);
  } else {
    confess 'No config or config_file provided to new(). Cannot execute';
  }

  return $self->config;
} ## end sub _init_config


=head2 _validate_config
  Arg [1]    : HashRef of configuation parameters (driver, db, host, port, user, pass)
  Description: Configuration file parameter validation
  Return type: DBI database handle
  Caller     : internal

=cut

sub _validate_config {
  my ($self,$config) = @_;
  my @required_keys = qw/driver/;
  if ($config->{driver} eq 'mysql') {
    push @required_keys, qw/db host port user pass/;
  } elsif ($config->{driver} eq 'SQLite') {
    push @required_keys, qw/file/;
  } else {
    confess q(TestDB config requires parameter 'driver' with value mysql or SQLite);
  }
  my @errors;
  foreach my $constraint (@required_keys) {
    if (! exists $config->{$constraint}) {
      push @errors, "Missing argument '$constraint'";
    }
  }
  if (scalar @errors > 0) {
    confess sprintf "%s \n%s",
      ($self->config_file) ? 'Missing options in '.$self->config_file. ': ' : 'Missing options in supplied config: ',
      join ';',@errors;
  }
} ## end sub _validate_config


=head2
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub dbh {
  my $self = shift;
  return $self->schema->storage->dbh;
  # return DBI->connect_cached( $self->dsn, $self->dbuser, $self->dbpass )  or
  #   $self->log()->die('Error connecting to ' . $self->dsn . ': '. $DBI::errstr);
} ## end sub dbh


=head2 checksum_array
  Description: Join an array of values with a ':' delimeter and find a sha1
               checksum of it
  Returntype : string
  Exceptions : none
  Caller     : general

=cut

sub checksum_array {
  my ($self, @values) = @_;

  return Digest::SHA1::sha1( join ':', grep { defined } @values );
} ## end sub checksum_array


=head2 start_session
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub start_session {
  my $self = shift;
  my $client_name = shift;

  my $dbh = $self->dbh();
  my $sth = $dbh->prepare( 'INSERT INTO session (client_id, status) VALUES(?, 1)' );
  $sth->execute( $client_name ) or
    $self->log->logdie("Error inserting session: $DBI::errstr");

  $self->session_id($sth->{mysql_insertid});

  $self->log->info( "Starting session $self->session_id" );

  $dbh->do( 'SET FOREIGN_KEY_CHECKS = 0' );

  return $self->session_id;
} ## end sub start_session


=head2 end_session
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub end_session {
  my $self = shift;

  if ( $self->session_id ) {
    my $dbh = $self->dbh();
    $dbh->do('UPDATE session SET status = 2 WHERE session_id = ?', undef, $self->session_id);

    $self->session_id(0);
  }
} ## end sub end_session


=head2 abort_session
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub abort_session {
  my $self = shift;

  if ( $self->session_id ) {
    my $dbh = $self->dbh();
    $dbh->do( 'UPDATE session SET status = 3 WHERE session_id = ?', undef, $self->session_id );

    $self->session_id(0);

    $dbh->do( 'SET UNIQUE_CHECKS = 1' );
    $dbh->do( 'SET FOREIGN_KEY_CHECKS = 1' );
  }
} ## end sub abort_session

1;
