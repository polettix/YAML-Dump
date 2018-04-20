# NAME

YAML::Dump - Dump stuff, (simplified) YAML style

# VERSION

This document describes YAML::Dump version {{\[ version \]}}.

<div>
    <a href="https://travis-ci.org/polettix/YAML-Dump">
    <img alt="Build Status" src="https://travis-ci.org/polettix/YAML-Dump.svg?branch=master">
    </a>
    <a href="https://www.perl.org/">
    <img alt="Perl Version" src="https://img.shields.io/badge/perl-5.10+-brightgreen.svg">
    </a>
    <a href="https://badge.fury.io/pl/YAML-Dump">
    <img alt="Current CPAN version" src="https://badge.fury.io/pl/YAML-Dump.svg">
    </a>
    <a href="http://cpants.cpanauthors.org/dist/YAML-Dump">
    <img alt="Kwalitee" src="http://cpants.cpanauthors.org/dist/YAML-Dump.png">
    </a>
    <a href="http://www.cpantesters.org/distro/B/YAML-Dump.html?distmat=1">
    <img alt="CPAN Testers" src="https://img.shields.io/badge/cpan-testers-blue.svg">
    </a>
    <a href="http://matrix.cpantesters.org/?dist=YAML-Dump">
    <img alt="CPAN Testers Matrix" src="https://img.shields.io/badge/matrix-@testers-blue.svg">
    </a>
</div>

# SYNOPSIS

    use YAML::Dump qw< Dump >;

    my $data = { ... };
    say Dump $data

# DESCRIPTION

This module allows you to generate a YAML representation of a data
structure, provided that:

- there are no circular references
- there are no objects or "weird" references, but see below

If you recognize most (not all) the constraints of [YAML::Tiny](https://metacpan.org/pod/YAML::Tiny) you are
totally right, because most of the code in this module is taken from
there. There are two notable differences:

- booleans are supported, see ["Booleans"](#booleans)
- you can provide your way of dumping objects by implementing
["dumper\_for\_unknown"](#dumper_for_unknown), see ["Unsupported References"](#unsupported-references).

## Booleans

Booleans are recognized and rendered as either `false` and `true`
(unquoted), depending on their truthness. The following variants are
recognized:

- a reference to a _purely integer_ scalar variable holding values `0` or
`1`. Dual-lived variables or other values will not work.
- [JSON::PP::Boolean](https://metacpan.org/pod/JSON::PP::Boolean)
- [boolean](https://metacpan.org/pod/boolean)
- [JSON::XS::Boolean](https://metacpan.org/pod/JSON::XS::Boolean)
- [Types::Serialiaser::Boolean](https://metacpan.org/pod/Types::Serialiaser::Boolean) (although it should not be needed)
- [Mojo::JSON::\_Bool](https://metacpan.org/pod/Mojo::JSON::_Bool), for [Mojolicious](https://metacpan.org/pod/Mojolicious) up to version 6.21 (it later
switched to [JSON::PP::Boolean](https://metacpan.org/pod/JSON::PP::Boolean)).

## Unsupported References

When a reference that is neither a hash nor an array reference is found,
method ["dumper\_for\_objects"](#dumper_for_objects) is called. This method first tries to figure
out if the reference is one of the allowed ["Booleans"](#booleans) representations,
then hands over to a method ["dumper\_for\_unknown"](#dumper_for_unknown) (if the class has one),
then as a last resort it complains loudly `die`ing.

If you want to provide your own dumping functions, you can either override
["dumper\_for\_objects"](#dumper_for_objects) (losing support for ["Booleans"](#booleans)), or provide your
method ["dumper\_for\_unknown"](#dumper_for_unknown). By default there is none, so you can either
derive a subclass from YAML::Dump, or monkey-patch it by implementing the
method directly:

    sub YAML::Dump::dumper_for_unknown { 
       my ($self, $element, $line, $indent, $seen) = @_;
    }

# FUNCTIONS

## **Dump**

    my $string = Dump(@data_structures);

generate a YAML representation of `@data_structures`.

## **INDENT**

    my $string = INDENT;

the indentation as space characters. This is useful if you have to
generate indentation string with ["dumper\_for\_unknown"](#dumper_for_unknown).

# METHODS

## **dumper\_for\_objects**

    my @lines = $obj->dumper_for_objects($element, $line, $indent, $seen);

This method generates a representation for booleans or, as a fallback,
calls ["dumper\_for\_unknown"](#dumper_for_unknown). If you override this you lose the
possibility of dumping booleans, you are probably looking for
["dumper\_for\_unknown"](#dumper_for_unknown).

## **dumper\_for\_unknown**

    my @stuff = $obj->dumper_for_unknown($element, $line, $indent, $seen);

This method is not really present, but is invoked if you provide one
(either in a subclass, or monkey-patching YAML::Dump, see
["Unsupported References"](#unsupported-references)). This allows you to provide your own
generating functions for your classes, should you need to do this.

The method is provided the following positional parameters:

- `$element`

    the element to dump in YAML

- `$line`

    the line where the element will be put (starting). It can be one of the
    following:

    - an empty string, in case the object is at the root level
    - a string starting with spaces and ending with a dash `-`: your element is
    part of an array
    - a string ending with a colon `:`: your element is the value of a hash

    If your dump is just on a single line, it's sufficient to pre-pend the
    string representation with a space; otherwise, decide what you want to do
    also taking into consideration `$indent` (see below) and also taking into
    consideration that it is your responsibility to output the `$line`
    anyway.

- `$indent`

    The indentation level, should you need it (e.g. for multi-line dumps). To
    generate the indentation string, use ["INDENT"](#indent):

        my $indentation_string = INDENT x $indent;

- `$seen`

    used to track circular references. Use this if your object contains other
    references with the potential for a cycle of references. This is how you
    can use it:

        sub dumper_for_unknown {
           # ...

           my $id = Scalar::Util::refaddr($some_reference);
           die \'circular references are unsupported' if $seen->{$id};

           # ...
        }

The return value from this method can be either a list of lines (with the
proper indentation, and starting with the content of `$line` above) or
a single array or hash reference, which will be transformed automatically.
This allows you to basically ignore `$line`, `$indent` (but probably not
`$seen`) and let YAML::Dump do the work for you.

## **new**

    my $obj = YAML::Dump->new(@data_for_dumping);

Generate an object. You should not need to use this, use ["Dump"](#dump) instead.

# BUGS AND LIMITATIONS

Report bugs through GitHub (patches welcome).

# SEE ALSO

[YAML::Tiny](https://metacpan.org/pod/YAML::Tiny), where most of the code was taken. But hey! There is also my
stuff!

# AUTHOR

Flavio Poletti <polettix@cpan.org>

# COPYRIGHT AND LICENSE

This is tricky. A good part of the code comes from [YAML::Tiny](https://metacpan.org/pod/YAML::Tiny), whose
copyright statement at time of copy is:

    Copyright 2006 - 2013 Adam Kennedy.

    This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.

    The full text of the license can be found in the LICENSE file included
    with this module.

Now, _under the same terms as Perl itself_ is in itself a bit ambiguous,
even though the original LICENSE has this:

    This software is copyright (c) 2006 by Adam Kennedy.

    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.

    Terms of the Perl programming language system itself

    a) the GNU General Public License as published by the Free
       Software Foundation; either version 1, or (at your option) any
       later version, or b) the "Artistic License"

Again, it's my understanding that even _the same terms as Perl
5 programming language system itself_ is a bit ambiguous. Also,
the _Artistic License_ is, in itself, ambiguous, which is why
the Perl Foundation eventually recommended the _Artistic License 2.0_.

Anyway, a hopefully compatible license can be found in file LICENSE.

Additions are copyright (C) 2018 by Flavio Poletti <polettix@cpan.org>

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
