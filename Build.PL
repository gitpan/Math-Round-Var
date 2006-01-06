
use strict;
use warnings;
use Module::Build;
my $build_class = 'Module::Build';
my $custom_build = 'Module::Build::Live';
eval("require $custom_build;");
unless($@) {
	warn "using custom build class:  '$custom_build'\n";
	$build_class = $custom_build;
}

my $builder = $build_class->new(
	module_name         => 'Math::Round::Var',
	license             => 'perl',
	dist_version_from   => 'lib/Math/Round/Var.pm',
	requires => {
		'Test::More'    => 0,
	},
	add_to_cleanup      => [ qw(Math-Round-Var-* META.yml)],
);

$builder->create_build_script();
