use strict;
use warnings;


package Net::NicoVideo::Content::NicoAPI;
use vars qw($VERSION);
$VERSION = '0.01_18';
use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
id
mylistgroup
mylistitem
error
status
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

sub is_status_ok {
    my $self = shift;
    $self->status and $self->status eq 'ok';
}

sub error_code {
    my $self = shift;
    $self->error and $self->error->code;
}

sub error_description {
    my $self = shift;
    $self->error and $self->error->description;
}

sub is_error_noauth {
    my $self = shift;
    $self->error and $self->error->code and $self->error->code eq 'NOAUTH';
}


package Net::NicoVideo::Content::NicoAPI::Error;
use vars qw($VERSION);
$VERSION = '0.01_18';
use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
code
description
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}


package Net::NicoVideo::Content::NicoAPI::MylistGroup;
use vars qw($VERSION);
$VERSION = '0.01_18';
use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
id
user_id
name
description
public
default_sort
create_time
update_time
sort_order
icon_id
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}


package Net::NicoVideo::Content::NicoAPI::MylistItem;
use vars qw($VERSION);
$VERSION = '0.01_18';
use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
item_type
item_id
description
item_data
watch
create_time
update_time
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}


package Net::NicoVideo::Content::NicoAPI::MylistItem::ItemData;
use vars qw($VERSION);
$VERSION = '0.01_18';
use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
video_id
title
thumbnail_url
first_retrieve
update_time
view_counter
mylist_counter
num_res
group_type
length_seconds
deleted
last_res_body
watch_id
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}


1;
__END__
