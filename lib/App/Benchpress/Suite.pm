package App::Benchpress::Suite;

use Moose;
use Moose::Exporter;

use App::Benchpress::Instance;

Moose::Exporter->setup_import_methods(
    with_meta => [ 'benchmark', 'add_env' ],
    also => 'Moose',
);

use experimental qw/
    signatures
    postderef
/;

has benchmarks => (
    is => 'ro',
    lazy => 1,
    builder => '_build_benchmarks',
    traits => [ 'Array' ],
    handles => {
        'all_benchmarks' => 'elements'
    },
);

sub _build_benchmarks {
    return [];
}

has env => (
    is => 'ro',
    builder => '_build_env',
);

sub _build_env($self) {
    return {
        suite => $self->meta->name
    };
}

use Hash::Merge qw/ merge /;

sub add_env($meta,$sub) {
   $meta->add_around_method_modifier(
       '_build_env',
       sub($orig,$self,@args) {
           return merge 
                $sub->($self),
                $orig->($self)
       }
   );
}


sub benchmark($meta,$name,$sub) {

   $meta->add_around_method_modifier(
       '_build_benchmarks',
       sub($orig,$self,@args) {

           my @b = $sub->($self);

           my @benchs;

           while( my $code = shift @b ) {
               my $env = ref $b[0] eq 'HASH' ? shift @b : {};
               push @benchs, App::Benchpress::Instance->new(
                   name => $name,
                   code => $code,
                   env => merge( $env, $self->env ),
               )->as_dumb;
           }

            return [
                $orig->($self,@args)->@*, @benchs
            ]

       }

   );
    

}



1;
