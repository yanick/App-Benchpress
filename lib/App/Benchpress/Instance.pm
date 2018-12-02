package  App::Benchpress::Instance;

use Moose;

use Dumbbench::Instance::PerlSub;

use experimental qw/
    signatures
    postderef
/;

has env => (
    is => 'ro',
    default => sub { +{} },
);

has name => (
    is => 'ro',
    required => 1,
);

has code => (
    is => 'ro',
    required => 1,
);

sub as_dumb($self) {
    my $dumb = Dumbbench::Instance::PerlSub->new(
        name => $self->name, 
        code => $self->code,
    );
    
    # BAD YANICK
    $dumb->{env} = $self->env;

    return $dumb;
}

1;

