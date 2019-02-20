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

package Bio::EnsEMBL::Tark::TagConfig;

use Moose;
with 'MooseX::Log::Log4perl';

use Config::Simple;


has 'config' => (
  is  => 'rw',
  isa => 'HashRef',
);

has 'blocks' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  lazy => 1,
  builder => '_init_blocks',
);


=head2 load_config_file
  Arg [1]    : $file_name : string
  Description: Parse the config file and extract the config parameters for each
               block
  Returntype : undef
  Exceptions : none
  Caller     : general

=cut

sub load_config_file {
  my ( $self, $file_name ) = @_;

  my $cfg = Config::Simple->new( filename => $file_name );

  my %config;
  foreach my $block_var ( $cfg->param() ) {
    my ($block, $var) = split /\./ , $block_var;

    if ( !defined $config{ $block } ) {
      $config{ $block } = {};
    }
    $config{ $block }{ $var } = $cfg->param($block_var);
  }

  $self->config( \%config );

  return;
} ## end sub load_config_file


=head2 _init_blocks
  Description: Return a list of the tags within the loaded config file
  Returntype : ArrayRef
  Exceptions : none
  Caller     : general

=cut

sub _init_blocks {
  my ( $self ) = @_;

  return [ keys %{ $self->config } ];
} ## end sub _init_blocks


=head2 set_id
  Description: Set the id value for the tag
  Returntype : undef
  Exceptions : none
  Caller     : general

=cut

sub set_id {
  my ( $self, $block, $id ) = @_;
  $self->config->{ $block }->{'id'} = $id;
  return;
} ## end sub set_id

1;
