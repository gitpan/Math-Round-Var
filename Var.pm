package Math::Round::Var;

use 5.006;
use strict;
use warnings;
use Carp;

our $VERSION = '0.01';

=head1 NAME

Math::Round::Var - Variations on rounding.

=head1 SYNOPSIS

  use Math::Round::Var;
  my $rnd = Math::Round::Var->new($scheme);
  $num = $rnd->round($num);

=head1 DESCRIPTION

This module gives you the ability to round numbers to either decimal or
fractional precision.

=head1 AUTHOR

  Eric L. Wilhelm
  ewilhelm at sbcglobal dot net
  http://pages.sbcglobal.net/mycroft/

=head1 COPYRIGHT

This module is copyright (C) 2003 by Eric L. Wilhelm.

=head1 LICENSE

This module is distributed under the same terms as Perl.  See the Perl
source package for details.

You may use this software under one of the following licenses:

  (1) GNU General Public License
    (found at http://www.gnu.org/copyleft/gpl.html)
  (2) Artistic License
    (found at http://www.perl.com/pub/language/misc/Artistic.html)

=head1 CHANGES

  0.01 First public release 

=cut
########################################################################

=head1 Front-End Constructor

The Math::Round::Var::new() function only decides between the two
sub-packages based on the format of your precision argument.

This is the extent of the purpose of the Math::Round::Var class.

=cut

=head2 new

  Math::Round::Var->new($precision);

=cut
sub new {
	my $caller = shift;
	my $precision = shift;
	# decide which to use
	my ($type, $count) = format_of($precision);
	if($type eq "fraction") {
		return(Math::Round::Var::Fraction->new(round_to => $precision));
	}
	elsif($type eq "decimal") {
		return(Math::Round::Var::Float->new(precision => $count));
	}
	else {
		die("$type is not a valid rounding type");
	}
} # end subroutine new definition
########################################################################

=head2 format_of

Returns "decimal" or "fraction" for $type based on the format of
$precision.  If $type is "decimal", then $count will be the number of
digits to use.

  my ($type, $count) = format_of($precision);

Valid formats should be any of the number formats which are used by
Perl.  Basically, the 'fraction' methods will work for anything (as long
as Perl can divide by it), but we would be wasting time if we only want
to round to a certain decimal place.

=item Fractional Formats:

  0.125
  0.00007
  2
  2.885

=item Decimal Formats:

  0.0000001
  1.0e-10

=cut
sub format_of {
	my ($prec) = @_;
	my $frac = "fraction";
	my $dec = "decimal";
	# we may want to round off like %0.0f
	unless($prec) {
		defined($prec) or carp("assuming round-to-integer");
		return($dec, 0);
	}
	# if we want to round by numbers which are larger than 1, we must
	# use the fractional methods:
	if($prec >= 1) {
		return($frac, $prec);
	}
	# seems that the easiest way is to divide by a big number so that it
	# is guaranteed to be in exponential notation, then we simply have
	# to look at what comes before the 'e'
	my $num = $prec;
	# assumption is that this accomplishes the transform:
	$num /= 1e+4;
	if($num =~ m/^(.*?)e-(\d+)$/) {
		my ($n, $d) = ($1, $2);
		# print "number: $n\n", "digits: $d\n";
		if($n == 1) {
			return($dec, $d - 4);
		}
		else {
			return($frac, 0);
		}
	}
	else {
		croak("$prec tricks me ($num)");
	}

} # end subroutine format_of definition
########################################################################

=head1 Decimal-based rounding

=cut

package Math::Round::Var::Float;

=head2 new

Creates a new decimal-based rounding object.

  Math::Round::Var::Float->new(precision => 7);

The argument to precision is the number of digits to use in rounding.
This is used  as part of a sprintf() format.

=cut
sub new {
	my $caller = shift;
	my $class = ref($caller) || $caller;
	my $self = {@_};
	my $p = $self->{precision};
	defined($p) or croak("must define 'precision'");
	($p =~ m/^\d+$/) or croak("precision must be an integer");
	bless($self, $class);
	return($self);
} # end subroutine new definition
########################################################################

=head2 round

  $number = $rounder->round($number);

=cut
sub round {
	my $self = shift;
	my $rnd = $self->{precision};
	my $number = shift;
	return(sprintf("%0.${rnd}f", $number));
} # end subroutine round definition
########################################################################

=head1 Fraction-based rounding.

=cut

package Math::Round::Var::Fraction;

=head2 new

  Math::Round::Var::Fraction->new();

=cut
sub new {
	my $caller = shift;
	my $class = ref($caller) || $caller;
	my $self = {@_};
	my $r = $self->{round_to};
	defined($r) or croak("must define 'round_to'");
	bless($self, $class);
	return($self);
} # end subroutine new definition
########################################################################

=head2 round

  $number = $rounder->round($number);

=cut
sub round {
	my $self = shift;
	my $rnd = $self->{round_to};
	my $number = shift;
	return(sprintf("%0.0f", $number / $rnd) * $rnd);
} # end subroutine round definition
########################################################################
1;

