use strict;
use Test::More tests => 13;
use lib 't/lib';

eval "package Foo; use inherit Versioned => 0.4; 1";
is( $@, '', "pass decimal version check");

eval "package Foo; use inherit Versioned => 0.6; 1";
like( $@, qr/this is only/, "fail decimal version check");

eval "package Foo; use inherit DotVersioned => 1; 1";
is( $@, '', "pass integer version check");

eval "package Foo; use inherit DotVersioned => 2; 1";
like( $@, qr/this is only/, "fail integer version check");

eval "package Foo; use inherit DotVersioned => v1.0.0; 1";
is( $@, '', "pass v-string version check");

eval "package Foo; use inherit DotVersioned => v1.1; 1";
like( $@, qr/this is only/, "fail v-string version check");

eval "package Foo; use inherit DotVersioned => 'v1.0.0'; 1";
is( $@, '', "pass string v-string version check");

eval "package Foo; use inherit DotVersioned =>'v1.1'; 1";
like( $@, qr/this is only/, "fail string v-string version check");

eval "package Foo; use inherit 'Dummy', Versioned => 0.4, 'Dummy::Outside'; 1";
is( $@, '', "versioned inherit between unversioned");

eval "package Foo; use inherit UnVersioned => 0; 1";
is( $@, '', "requiring 0 doesn't fail on undef \$VERSION");

eval "package Foo; use inherit UnVersioned => 1; 1";
like( $@, qr/failed/, "requiring 1 does fail on undef \$VERSION");

eval "package Foo; use inherit DotVersioned => 'v1.0_0'; 1";
is( $@, '', "pass string alpha v-string version check");

eval "package Foo; use inherit DotVersioned =>'v1.0_1'; 1";
like( $@, qr/this is only/, "fail string alpha v-string version check");


