use strict;
use warnings;
use Test::More;

use Net::NicoVideo::URL;

my $pairs = {
'http://nico.ms/sm9'        => 'http://www.nicovideo.jp/watch/sm9',
'http://nico.ms/nm2522142'  => 'http://www.nicovideo.jp/watch/nm2522142',
'http://nico.ms/im826267'   => 'http://seiga.nicovideo.jp/seiga/im826267?ref=nicoms',
'http://nico.ms/sg1'        => 'http://seiga.nicovideo.jp/watch/sg1?ref=nicoms',
'http://nico.ms/mg10940'    => 'http://seiga.nicovideo.jp/watch/mg10940?ref=nicoms',
'http://nico.ms/bk1'        => 'http://seiga.nicovideo.jp/watch/bk1',
'http://nico.ms/lv10'       => 'http://live.nicovideo.jp/watch/lv10',
'http://nico.ms/l/co1'      => 'http://live.nicovideo.jp/watch/co1',
'http://nico.ms/co1'        => 'http://com.nicovideo.jp/community/co1',
'http://nico.ms/ch1'        => 'http://ch.nicovideo.jp/channel/ch1',
'http://nico.ms/ar2760'     => 'http://ch.nicovideo.jp/article/ar2760',
'http://nico.ms/nd1'        => 'http://chokuhan.nicovideo.jp/products/detail/1',
'http://nico.ms/azB000YGIP66'             => 'http://ichiba.nicovideo.jp/item/azB000YGIP66',
'http://nico.ms/ysamiami_MED-CD2-00562'   => 'http://ichiba.nicovideo.jp/item/ysamiami_MED-CD2-00562',
'http://nico.ms/ggbo-09090979'            => 'http://ichiba.nicovideo.jp/item/ggbo-09090979',
'http://nico.ms/ndsupplier_027'           => 'http://ichiba.nicovideo.jp/item/ndsupplier_027',
'http://nico.ms/dw1'                      => 'http://ichiba.nicovideo.jp/item/dw1',
'http://nico.ms/it2334005982'             => 'http://ichiba.nicovideo.jp/item/it2334005982',
'http://nico.ms/ap11'       => 'http://app.nicovideo.jp/app/ap11',
'http://nico.ms/jk1'        => 'http://jk.nicovideo.jp/watch/jk1',
'http://nico.ms/nc1'        => 'http://www.niconicommons.jp/material/nc1',
'http://nico.ms/nw1'        => 'http://news.nicovideo.jp/watch/nw1',
'http://nico.ms/dic/1'      => 'http://dic.nicovideo.jp/id/1',
'http://nico.ms/user/1'     => 'http://www.nicovideo.jp/user/1',
'http://nico.ms/mylist/26'  => 'http://www.nicovideo.jp/mylist/26',
};

for my $s ( sort keys %$pairs ){
    my $l = $pairs->{$s};
    
    is( shorten($l), $s, "shorten $l");
    is( unshorten($s), $l, "unshorten $s");
}


done_testing();
1;
__END__
