use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Net::NicoVideo',
    'VERSION_FROM' => 'lib/Net/NicoVideo.pm', # finds $VERSION
    'PREREQ_PM' => {
    CGI::Simple => 0,
    Class::Accessor::Fast => 0,
    LWP::UserAgent => 0,
    HTTP::Cookies => 0,
    HTTP::Request::Common => 0,
    Test::More => 0.32,
    XML::TreePP => 0,
    },
);
