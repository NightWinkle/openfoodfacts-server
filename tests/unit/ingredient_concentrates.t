use ProductOpener::PerlStandards;
use Test2::V0;
use ProductOpener::Tags qw(canonicalize_taxonomy_tag is_a);

for my $fruit ('apple', 'orange', 'blueberry', 'pomegranate') {
	for my $name ("$fruit juice concentrate", "$fruit juice concentrates") {
		is(
			canonicalize_taxonomy_tag('en', 'ingredients', $name),
			"en:concentrated-$fruit-juice",
			"$name is a concentrate, not a reconstituted juice"
		);
	}
	is(
		canonicalize_taxonomy_tag('en', 'ingredients', "$fruit juice from concentrate"),
		"en:$fruit-juice-from-concentrate",
		'from concentrate retains its own identity'
	);
}
ok(is_a('ingredients', 'en:concentrated-pomegranate-juice', 'en:pomegranate-juice'),
	'pomegranate concentrate retains the juice hierarchy');

done_testing;
