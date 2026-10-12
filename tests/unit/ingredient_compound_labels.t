use ProductOpener::PerlStandards;
use Test2::V0;
use ProductOpener::Ingredients qw(parse_ingredients_text_service);

sub parse ($lc, $text) {
	my $product = {lc => $lc, ingredients_text => $text};
	parse_ingredients_text_service($product, {}, []);
	return $product->{ingredients};
}

for my $text (
	'Viandes Bio et sous-produits animaux Bio (dont poulet Bio 4%)',
	"Viandes* et sous-produits animaux* (dont poulet* 4%). (*) ingrédients issus de l'agriculture biologique.",
	)
{
	my $ingredients = parse('fr', $text);
	is(scalar @$ingredients, 1, 'organic labels do not split a declared compound');
	is($ingredients->[0]{id}, 'en:meat-and-animal-derivatives', 'the organic compound retains its identity');
	is($ingredients->[0]{labels}, 'en:organic', 'the whole compound has one organic label');
	is($ingredients->[0]{ingredients}[0]{id}, 'en:chicken', 'chicken remains a child of the compound');
	is($ingredients->[0]{ingredients}[0]{labels}, 'en:organic', 'the child retains its own organic label');
	is($ingredients->[0]{ingredients}[0]{percent}, 4, 'the child retains its percentage');
}

my $percentage = parse('fr', 'Viandes bio et sous-produits animaux bio 95% (dont poulet bio 4%)');
is(scalar @$percentage, 1, 'labels and a trailing percentage do not split the compound');
is($percentage->[0]{percent}, 95, 'the percentage belongs to the whole compound');

for my $case (
	['poulet bio et riz', ['en:chicken', 'en:rice'], ['en:organic', undef]],
	['poulet et riz bio', ['en:chicken', 'en:rice'], [undef, 'en:organic']],
	['poulet bio et xyzabc', ['en:chicken', 'fr:xyzabc'], ['en:organic', undef]],
	['poulet bio et riz et sel', ['en:chicken', 'en:rice', 'en:salt'], ['en:organic', undef, undef]],
	[
		'poulet bio et riz bio et sel bio',
		['en:chicken', 'en:rice', 'en:salt'],
		['en:organic', 'en:organic', 'en:organic']
	],
	['viandes bio et sous-produits animaux', ['en:meat', 'en:animal-derivatives'], ['en:organic', undef]],
	['viandes et sous-produits animaux bio', ['en:meat', 'en:animal-derivatives'], [undef, 'en:organic']],
	)
{
	my $ingredients = parse('fr', $case->[0]);
	is([map {$_->{id}} @$ingredients], $case->[1], "$case->[0] keeps differently labelled parts separate");
	is([map {$_->{labels}} @$ingredients], $case->[2], "$case->[0] does not spread a label to the other part");
}

my $english = parse('en', 'organic pasteurised milk and organic cream');
is(
	[map {$_->{id}} @$english],
	['en:pasteurized-milk-and-cream'],
	'label stripping preserves generated spelling synonyms'
);
is($english->[0]{labels}, 'en:organic', 'English repeated labels are deduplicated');

is(parse('fr', 'poulet bio biologique')->[0]{labels}, 'en:organic', 'repeated label synonyms are deduplicated');
is(parse('fr', 'poulet bio (bio)')->[0]{labels}, 'en:organic', 'inline and parenthetical labels are deduplicated');

my $standalone = {lc => 'en', ingredients_text => 'organic. gluten-free'};
parse_ingredients_text_service($standalone, {}, []);
is($standalone->{ingredients}, [], 'standalone labels do not become ingredients');
is($standalone->{labels_tags}, ['en:no-gluten', 'en:organic'], 'standalone labels still qualify the product');

done_testing;
