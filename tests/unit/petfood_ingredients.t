use ProductOpener::PerlStandards;
use Test2::V0;
use Cwd qw(abs_path);
use ProductOpener::Paths qw(get_files_for_taxonomy get_path_for_taxonomy_file);
use ProductOpener::Tags qw(canonicalize_taxonomy_tag display_taxonomy_tag exists_taxonomy_tag
	get_inherited_property is_a);

is(
	[map {abs_path(get_path_for_taxonomy_file($_))} get_files_for_taxonomy('ingredients', 'petfood')],
	[map {abs_path(get_path_for_taxonomy_file($_))} get_files_for_taxonomy('ingredients', 'food')],
	'food and petfood select the same ingredient sources'
);

for my $case (
	['poulet', 'en:chicken'],
	['dinde', 'en:turkey'],
	['poisson', 'en:fish'],
	['viande et sous-produits animaux', 'en:meat-and-animal-derivatives'],
	['viandes et sous-produits animaux', 'en:meat-and-animal-derivatives'],
	['sous-produits animaux', 'en:animal-derivatives'],
	['sous-produits de poissons', 'en:fish-derivatives'],
	['poissons et sous-produits de poissons', 'en:fish-and-fish-derivatives'],
	["sous-produits d'origine végétale", 'en:derivatives-of-vegetable-origin'],
	['huile de saumon', 'en:salmon-fish-oil'],
	)
{
	is(canonicalize_taxonomy_tag('fr', 'ingredients', $case->[0]), $case->[1], "$case->[0] has a shared identity");
}
is(canonicalize_taxonomy_tag('en', 'ingredients', 'en:salmon-oil'),
	'en:salmon-fish-oil', 'the old salmon oil spelling canonicalizes to the existing food entry');
is(canonicalize_taxonomy_tag('de', 'ingredients', 'Lachsöl'),
	'en:salmon-fish-oil', 'petfood translations enrich the existing salmon oil entry');
is(
	lc(display_taxonomy_tag('fr', 'ingredients', 'en:salmon-fish-oil')),
	'huile de saumon',
	'shared salmon oil has a French display name'
);
ok(!exists_taxonomy_tag('ingredients', 'en:salmon-oil'), 'salmon oil does not have a duplicate canonical entry');
ok(is_a('ingredients', 'en:krill', 'en:crustacean'), 'krill inherits the crustacean hierarchy');
for my $id (
	'en:animal-derivatives', 'en:fish-derivatives',
	'en:meat-and-animal-derivatives',
	'en:fish-and-fish-derivatives'
	)
{
	is(get_inherited_property('ingredients', $id, 'vegan:en'), 'no', "$id is not vegan");
	is(get_inherited_property('ingredients', $id, 'vegetarian:en'), 'no', "$id is not vegetarian");
}
for my $phrase ('', 'et', 'dont') {
	my $exists;
	canonicalize_taxonomy_tag('fr', 'ingredients', $phrase, \$exists);
	is($exists, 0, "stopword-only expression is not an ingredient: $phrase");
}

done_testing;
