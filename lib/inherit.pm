use 5.008001;
use strict;
use warnings;

package inherit;
# ABSTRACT: Like parent, but with version checks
# VERSION

sub import {
    my $class = shift;

    my $inheritor = caller(0);

    my $no_require;
    if ( @_ and $_[0] eq '-norequire' ) {
        shift @_;
        $no_require++;
    }

    while ( @_ ) {
        my $module = shift @_;
        my $version = @_ && _is_version($_[0]) ? shift(@_) : 0;
        if ( $module eq $inheritor ) {
            warn "Class '$inheritor' tried to inherit from itself\n";
        }
        (my $file = $module) =~ s{::|'}{/}g;
        require "$file.pm" unless $no_require; # dies if the file is not found
        $module->VERSION($version) if $version; # don't check '0'
        {
            no strict 'refs';
            push @{"$inheritor\::ISA"}, $module;
        };
    }
}

# if doesn't start with a letter, or starts with 'v' but has a '.'
sub _is_version {
    my ($arg) = @_;
    return $arg !~ m{^[a-z]}i || $arg =~ m{^v[0-9]+\.};
}

1;

__END__

=for Pod::Coverage method_names_here

=encoding utf8

=head1 SYNOPSIS

    package Baz;
    use inherit qw(Foo Bar), 'Baz' => 1.23;

=head1 DESCRIPTION

Allows you to both load one or more modules, while setting up inheritance from
those modules at the same time.

If a module in the import list is followed by something that looks like a
version number, the C<VERSION> method will be called to ensure a minimum version.
Note that "v2" is a valid module name, so a version with a leading "v" must
have one or more decimal points ("v2.0.0").

The synopsis example is mostly similar in effect to

    package Baz;
    BEGIN {
        require Foo;
        require Bar;
        require Baz;
        Baz->VERSION(1.23)
        push @ISA, qw(Foo Bar Baz);
    }

You can provide anything legal for the L<VERSION> method.  If you have
Perl 5.10 or later, anything your L<version.pm> will accept is OK.

    package My::Class;
    use inherit 'Other::Class' => v1.2.3; # v-string

    package Wibble;
    use inherit 'Wobble' => 'v0.10.0';    # strings OK

    package Crazy;
    use inherit 'InProgress' => '2.00_01' # alpha version

If the first import argument is C<-norequire>, no files will be loaded
(but any versions given will still be checked).

This is helpful for the case where a package lives within the current file
or a differently named file:

  package MyHash;
  use Tie::Hash;
  use inherit -norequire, 'Tie::StdHash';

=head1 DIAGNOSTICS

=over 4

=item Class 'Foo' tried to inherit from itself

Attempting to inherit from yourself generates a warning.

    package Foo;
    use inherit 'Foo';

=back

=head1 HISTORY

This module was forked from L<parent> to add version checks.
The L<parent> module was forked from L<base> to remove the cruft
that had accumulated in it.

Authors of or contributors to predecessor modules include Rafaël Garcia-Suarez,
Bart Lateur, Max Maischein, Anno Siegel, and Michael Schwern

=cut

# vim: ts=4 sts=4 sw=4 et:
