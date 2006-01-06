use Test::More;
eval "use Test::Prereq::Build";
plan skip_all => "Test::Prereq::Build required to test dependencies" if $@;
my $name = $0;
($name =~ m#/#) or chdir("../");
prereq_ok();
