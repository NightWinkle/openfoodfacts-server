# Shared ingredient taxonomy: contribution stack

The stack starts at `d44d1fae23` (local `origin/main`, 2026-10-09).
Each branch contains one commit and depends on the preceding branch.

| Branch | Parent | Change |
| --- | --- | --- |
| `fix/taxonomy-stopwords` | `origin/main` | Preload complete stopword declarations, invalidate both regexp caches on rebuild/reload, preserve declared identities, reject empty generated aliases, bump the builder cache version. |
| `fix/ingredient-conjunctions` | `fix/taxonomy-stopwords` | Preserve declared compounds and generated spelling variants, split ordinary conjunctions, preserve percentages and children, prevent parent context from replacing a precise child with its ancestor. |
| `fix/ingredient-concentrate-aliases` | `fix/ingredient-conjunctions` | Declare English juice-concentrate synonyms explicitly so they are not confused with juice made from concentrate after stopword normalization. |
| `feat/shared-petfood-ingredients` | `fix/ingredient-concentrate-aliases` | Transfer petfood definitions/translations to the food source and restore the petfood source symlink. |

## Integration decisions

Source selection uses the existing `Paths.pm` mechanism and the symlink
`taxonomies/petfood/ingredients.txt -> ../food/ingredients.txt`.
Common additives, vitamins and minerals remain included by that mechanism.
There is one ingredient taxonomy source and no runtime fallback or overlay.

The existing OFF `en:salmon-fish-oil` entry receives the OPFF translations.
`salmon oil` remains its synonym; `en:salmon-oil` is no longer a separate concept.
Stored product tags require a separately authorized migration/reanalysis.

Complete stopwords must precede canonicalization. Canonical identities are
established from declared normalized spellings, rather than relaxed matches
that remove stopwords/plurals. Otherwise vitamin A and D can collapse into
vitamin D, and juice from concentrate into concentrated juice.
English `from` remains a stopword for other expressions. Explicit concentrate
synonyms disambiguate the two juice categories without changing that behavior.

Four existing OFF declarations now retain separate IDs: `en:champignon`,
`en:dried-vegetables`, `en:mandarin-with-peel`, `en:whiskeys`.
The four mushroom children retain their cultivated-mushroom ancestry through
`en:champignon`; they are not moved to an unrelated branch.

The compiler preserves its compiled-file/API format. Both normalized and text
stopword regexp caches are cleared only for the rebuilt/reloaded taxonomy.
The parser uses the existing synonym API to check conjunction-preserving forms,
including generated spelling variants.

## Validation

- Four focused test files: 88 assertions pass for OFF/OPFF with hash seeds 0 and 17, including rebuilding and reloading a compiled taxonomy.
- Isolated full ingredient builds: 6,665 canonical entries; OFF seed 17 and OPFF seed 0 have identical compiled structures and equivalent JSON/full/extended exports. No empty generated alias is exported. JSON object serialization order is not asserted.
- The compiler adds four previously merged declared IDs. The concentrate correction adds one pomegranate concentrate entry. The OPFF transfer adds six entries and enriches the existing salmon oil translations; existing properties are preserved.
- The 13 existing parser/tag suites run 958 assertions. Their 72 failures are identical to the upstream reference in this offline environment.
- The complete unit suite runs 7,021 assertions across 100 files. Its 44 failing files also fail in the reference. Missing language/category assets and external services prevent a fully green project suite.
- Perl style/syntax checks and `git diff --check` pass.

| Replay | Products | Known ingredient nodes before / after | Changed ingredient trees | Product errors |
| --- | ---: | ---: | ---: | ---: |
| OFF | 1,000 | 12,684 / 12,686 | 24 | 0 |
| OPFF | 2,807 | 13,651 / 29,080 | 2,193 | 0 |

OPFF replay structures are identical with seeds 0 and 17 after cache loading.
Three existing expectations were updated individually: two English concentrate
identities and one declared fruit-and-vegetable concentrate compound.

## Structural cases for review

The replay also inspects IDs, hierarchy, children and allergen tags. Recognition
counts alone do not establish that every resulting tree is correct.
OFF IDs change for explicit concentrates and for parent context, including
`en:palm-oil` to the existing child `en:palm`, and `en:cucumber` to
`en:cucumber-or-gherkin`. These changes need taxonomy/parser review before rollout.

On OPFF, some previously recognized IDs disappear from 17 product trees.
This includes flattened additive headings, more specific ingredient identities,
and remaining newline/heading problems. In particular, `4047777023111` and
`0005274277490` can join ingredient/analytical sections into unknown spans.
Organic markers in `3560070260645` still split a meat-and-derivatives compound.
These cases require the separate recipe/heading/newline fixes retained on the
original branch, followed by another comparison before production reanalysis.
The origin example `3560071504397` recognizes 28 of 47 nodes; recipe headings
and some by-product fragments still require structural parsing improvements.
OPFF allergen tags change on 530 products after including food definitions;
these outputs also require review before rollout.

## Scope

This stack does not port the earlier origin/recipe/newline changes retained on
`feat/opff-ingredient-taxonomy`. Generic animal-byproduct patterns, analytical
constituent separation and recipe-heading parsing remain separate work.
No push, deployment or production product reanalysis is part of this change.
