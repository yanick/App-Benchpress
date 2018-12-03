package App::Benchpress;
# ABSTRACT: Benchmark framework

use 5.20.0;
use warnings;

use Module::Runtime qw/ use_module /;

use MooseX::App::Simple;

use experimental qw/
    signatures
    postderef
/;

use DateTime::Functions qw/ now /;

option I => (
    is => 'ro',
    isa => 'ArrayRef',
    trigger => sub {
        my( $self, $values ) = @_;
        unshift @INC, @$values;
    },
);

has env => (
    is => 'ro',
    default => sub {
        +{
            run_at => now->iso8601,
        }
    },
);

parameter suites => (
    is => 'ro',
    isa => 'ArrayRef',
    traits => [ 'Array' ],
    required => 1,
    handles => { all_suites => 'elements' },
);

has dumbbench => (
    is => 'ro',
    lazy => 1,
    default => sub {
        use Dumbbench;

        Dumbbench->new;
    },
    handles => {
        add_benchmarks => 'add_instances',
        run_bench => 'run',
    },
);

use JSON qw/ to_json /;

sub run($self) {
    warn "starting to benchpress\n";
    $self->add_suite($_) for $self->all_suites;
    $self->run_bench;
    say to_json $_ for $self->report->@*;
}

sub add_suite($self,$suite) {
    warn "adding suite $suite\n";

    my $obj = use_module($suite)->new;

    $self->add_benchmarks( $obj->all_benchmarks);
}

sub report($self) {
    [ map { $self->report_instance($_) } 
        $self->dumbbench->instances ];
}

use Hash::Merge qw/ merge /;
use List::AllUtils qw/ reduce /;

sub report_instance($self,$instance) {
    my $result = $instance->result;

    return reduce { merge($a,$b) } 
        {
            name => $instance->name,
            results => {
                runtime => { 
                    mean => $result->raw_number,
                    sigma => $result->raw_error->[0],
                    relative_sigma => ( $result->raw_error->[0] /  $result->raw_number * 100 )
                },
                iterations => {
                    per_second => 1/$result->raw_number,
                    total =>scalar $instance->timings->@*,
                    outliers => scalar(@{$instance->timings})-$result->nsamples
                },
            },
        },
        $instance->{env},
        $self->env, 

}

1;
