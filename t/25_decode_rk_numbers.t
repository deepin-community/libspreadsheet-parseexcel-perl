#!/usr/bin/perl -w

###############################################################################
#
# A test for Spreadsheet::ParseExcel.
#
# Tests for RK number decoding.
#
# reverse('?'), August 2009, John McNamara, jmcnamara@cpan.org
#

use strict;

use Spreadsheet::ParseExcel;
use Test::More tests => 184;

###############################################################################
#
# The RK numbers and decoded values were extracted from Excel workboooks.
#
my @testcases = (


    # RK Number   Decoded number

    # Test cases from examples in the MS docs.
    [ 0x3FF00000,            1 ],
    [ 0x405EC001,         1.23 ],
    [ 0x02F1853A,     12345678 ],
    [ 0x02F1853B,    123456.78 ],
    [ 0xBFF00000,           -1 ],
    [ 0xC05EC001,        -1.23 ],
    [ 0xFD0E7ACA,    -12345678 ],
    [ 0xFD0E7ACB,   -123456.78 ],

    # Some simple user generated cases.
    [ 0x3FF00000,            1 ],
    [ 0x40000000,            2 ],
    [ 0x40080000,            3 ],
    [ 0x40100000,            4 ],
    [ 0x40140000,            5 ],
    [ 0x40180000,            6 ],
    [ 0x401C0000,            7 ],
    [ 0x40200000,            8 ],
    [ 0x40220000,            9 ],
    [ 0x40240001,          0.1 ],
    [ 0x40340001,          0.2 ],
    [ 0x403E0001,          0.3 ],
    [ 0x40440001,          0.4 ],
    [ 0x3FE00000,          0.5 ],
    [ 0x404E0001,          0.6 ],
    [ 0x40518001,          0.7 ],
    [ 0x40540001,          0.8 ],
    [ 0x40568001,          0.9 ],
    [ 0x3FF00001,         0.01 ],
    [ 0x40000001,         0.02 ],
    [ 0x40080001,         0.03 ],
    [ 0x40100001,         0.04 ],
    [ 0x40140001,         0.05 ],
    [ 0x40180001,         0.06 ],
    [ 0x401C0001,         0.07 ],
    [ 0x40200001,         0.08 ],
    [ 0x40220001,         0.09 ],
    [ 0x3FE00001,        0.005 ],
    [ 0xBFF00000,           -1 ],
    [ 0xC0000000,           -2 ],
    [ 0xC0080000,           -3 ],
    [ 0xC0100000,           -4 ],
    [ 0xC0140000,           -5 ],
    [ 0xC0180000,           -6 ],
    [ 0xC01C0000,           -7 ],
    [ 0xC0200000,           -8 ],
    [ 0xC0220000,           -9 ],
    [ 0xC0240001,         -0.1 ],
    [ 0xC0340001,         -0.2 ],
    [ 0xC03E0001,         -0.3 ],
    [ 0xC0440001,         -0.4 ],
    [ 0xBFE00000,         -0.5 ],
    [ 0xC04E0001,         -0.6 ],
    [ 0xC0518001,         -0.7 ],
    [ 0xC0540001,         -0.8 ],
    [ 0xC0568001,         -0.9 ],
    [ 0xBFF00001,        -0.01 ],
    [ 0xC0000001,        -0.02 ],
    [ 0xC0080001,        -0.03 ],
    [ 0xC0100001,        -0.04 ],
    [ 0xC0140001,        -0.05 ],
    [ 0xC0180001,        -0.06 ],
    [ 0xC01C0001,        -0.07 ],
    [ 0xC0200001,        -0.08 ],
    [ 0xC0220001,        -0.09 ],
    [ 0xBFE00001,       -0.005 ],

    # Testcases generated from single bit RK numbers.
    [ 0x3FF00001,         0.01 ],
    [ 0x40000001,         0.02 ],
    [ 0x40100001,         0.04 ],
    [ 0x40200001,         0.08 ],
    [ 0x40300001,         0.16 ],
    [ 0x40400001,         0.32 ],
    [ 0x40500001,         0.64 ],
    [ 0x3FF00000,            1 ],
    [ 0x40600001,         1.28 ],
    [ 0x40000000,            2 ],
    [ 0x40700001,         2.56 ],
    [ 0x40100000,            4 ],
    [ 0x40800001,         5.12 ],
    [ 0x40200000,            8 ],
    [ 0x40900001,        10.24 ],
    [ 0x40300000,           16 ],
    [ 0x40A00001,        20.48 ],
    [ 0x40400000,           32 ],
    [ 0x40B00001,        40.96 ],
    [ 0x40500000,           64 ],
    [ 0x40C00001,        81.92 ],
    [ 0x40600000,          128 ],
    [ 0x40D00001,       163.84 ],
    [ 0x40700000,          256 ],
    [ 0x40E00001,       327.68 ],
    [ 0x40800000,          512 ],
    [ 0x40F00001,       655.36 ],
    [ 0x40900000,         1024 ],
    [ 0x41000001,      1310.72 ],
    [ 0x40A00000,         2048 ],
    [ 0x41100001,      2621.44 ],
    [ 0x40B00000,         4096 ],
    [ 0x41200001,      5242.88 ],
    [ 0x40C00000,         8192 ],
    [ 0x41300001,     10485.76 ],
    [ 0x40D00000,        16384 ],
    [ 0x41400001,     20971.52 ],
    [ 0x40E00000,        32768 ],
    [ 0x41500001,     41943.04 ],
    [ 0x40F00000,        65536 ],
    [ 0x41600001,     83886.08 ],
    [ 0x41000000,       131072 ],
    [ 0x41700001,    167772.16 ],
    [ 0x41100000,       262144 ],
    [ 0x41800001,    335544.32 ],
    [ 0x41200000,       524288 ],
    [ 0x41900001,    671088.64 ],
    [ 0x41300000,      1048576 ],
    [ 0x41A00001,   1342177.28 ],
    [ 0x41400000,      2097152 ],
    [ 0x41B00001,   2684354.56 ],
    [ 0x41500000,      4194304 ],
    [ 0x41600000,      8388608 ],
    [ 0x41700000,     16777216 ],
    [ 0x41800000,     33554432 ],
    [ 0x41900000,     67108864 ],
    [ 0x41A00000,    134217728 ],
    [ 0x41B00000,    268435456 ],
    [ 0xC0000001,        -0.02 ],
    [ 0xC0000000,           -2 ],
    [ 0xC1B00001,  -2684354.56 ],
    [ 0xC1B80001,  -4026531.84 ],
    [ 0xC1BC0001,  -4697620.48 ],
    [ 0xC1BE0001,   -5033164.8 ],
    [ 0xC1BF0001,  -5200936.96 ],
    [ 0xC1BF8001,  -5284823.04 ],
    [ 0xC1BFC001,  -5326766.08 ],
    [ 0xC1BFE001,   -5347737.6 ],
    [ 0xC1BFF001,  -5358223.36 ],
    [ 0xC1BFF801,  -5363466.24 ],
    [ 0xC1BFFC01,  -5366087.68 ],
    [ 0xC1BFFE01,   -5367398.4 ],
    [ 0xC1BFFF01,  -5368053.76 ],
    [ 0xC1BFFF81,  -5368381.44 ],
    [ 0xC1BFFFC1,  -5368545.28 ],
    [ 0xC1BFFFE1,   -5368627.2 ],
    [ 0xC1BFFFF1,  -5368668.16 ],
    [ 0xC1BFFFF9,  -5368688.64 ],
    [ 0xC1BFFFFD,  -5368698.88 ],
    [ 0xC1547AE0,     -5368704 ],
    [ 0x80000403,  -5368706.56 ],
    [ 0x80000203,  -5368707.84 ],
    [ 0x80000103,  -5368708.48 ],
    [ 0x80000083,   -5368708.8 ],
    [ 0x80000043,  -5368708.96 ],
    [ 0x80000023,  -5368709.04 ],
    [ 0x80000013,  -5368709.08 ],
    [ 0x8000000B,   -5368709.1 ],
    [ 0x80000007,  -5368709.11 ],
    [ 0xC1B00000,   -268435456 ],
    [ 0xC1B80000,   -402653184 ],
    [ 0xC1BC0000,   -469762048 ],
    [ 0xC1BE0000,   -503316480 ],
    [ 0xC1BF0000,   -520093696 ],
    [ 0xC1BF8000,   -528482304 ],
    [ 0xC1BFC000,   -532676608 ],
    [ 0xC1BFE000,   -534773760 ],
    [ 0xC1BFF000,   -535822336 ],
    [ 0xC1BFF800,   -536346624 ],
    [ 0xC1BFFC00,   -536608768 ],
    [ 0xC1BFFE00,   -536739840 ],
    [ 0xC1BFFF00,   -536805376 ],
    [ 0xC1BFFF80,   -536838144 ],
    [ 0xC1BFFFC0,   -536854528 ],
    [ 0xC1BFFFE0,   -536862720 ],
    [ 0xC1BFFFF0,   -536866816 ],
    [ 0xC1BFFFF8,   -536868864 ],
    [ 0xC1BFFFFC,   -536869888 ],
    [ 0x80000802,   -536870400 ],
    [ 0x80000402,   -536870656 ],
    [ 0x80000202,   -536870784 ],
    [ 0x80000102,   -536870848 ],
    [ 0x80000082,   -536870880 ],
    [ 0x80000042,   -536870896 ],
    [ 0x80000022,   -536870904 ],
    [ 0x80000012,   -536870908 ],
    [ 0x8000000A,   -536870910 ],
    [ 0x80000006,   -536870911 ],

    # Some Max RK type 2 ints.
    [ 0x7FFFFFFE,    536870911 ],
    [ 0x80000006,   -536870911 ],

);

###############################################################################
#
# Run tests.
#

my $parser   = Spreadsheet::ParseExcel->new();

for my $test_ref (@testcases) {

    my $rk_number   = $test_ref->[0];
    my $expected    = $test_ref->[1];
    my $got         = Spreadsheet::ParseExcel::_decode_rk_number($rk_number);

    is( $got, $expected);
}



__END__
