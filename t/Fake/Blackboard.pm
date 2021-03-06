package Fake::Blackboard;

use Class::Std;

# Handle initialization of objects of this class...
sub BUILD {
    my ($self, $obj_ID, $arg_ref) = @_;
}

# Handle cleanup of objects of this class...
sub DEMOLISH {
    my ($self, $obj_ID) = @_;
}

# Handle unknown method calls...
sub AUTOMETHOD {
    my ($self, $obj_ID, @other_args) = @_;

    # Return any public data...
    if ( m/\A get_(.*)/ ) {  # Method name passed in $_
        my $get_what = $1;
        return sub {
            return $public_data{$obj_ID}{$get_what};
        }
    }

    warn "Can't call $method_name on ", ref $self, " object";

    return;   # The call is declined by not returning a sub ref
}

1;
