# GREL transformations

Every transformation applied to the OpenRefine projects is captured here, one file per logical step. Applied in order they reproduce the pipeline that takes the two raw datasets (DBpedia CSV + Nobel API JSON) to the merged, joined, ready-for-Wikidata-reconciliation table.

| # | File | Where | Purpose |
| :--- | :--- | :--- | :--- |
| 01 | [`01-construct-fullname.grel`](01-construct-fullname.grel) | API project | Build `fullName = givenName + " " + familyName`, surviving missing `familyName`. |
| 02 | [`02-normalize-join-key.grel`](02-normalize-join-key.grel) | Both projects | Build the `join` key — lowercase, strip parens / punctuation, keep first + last token, fingerprint. The resulting key is identical across DBpedia and the API for the same person. |
| 03 | [`03-cross-bring-birthdate.grel`](03-cross-bring-birthdate.grel) | API project | Pull `birthDate` from the DBpedia project via `cross()` on the `join` column. |
| 04 | [`04-cross-bring-birthplace.grel`](04-cross-bring-birthplace.grel) | API project | Same shape, pulls `birthPlaceLabel`. |
| 05 | [`05-cross-bring-country.grel`](05-cross-bring-country.grel) | API project | Same shape, pulls `countryLabel`. |
| 06 | [`06-cross-bring-uri-and-abstract.grel`](06-cross-bring-uri-and-abstract.grel) | API project | Pulls `person` URI and the English `abstract`. |
| 07 | [`07-cross-aggregate-multiple-matches.grel`](07-cross-aggregate-multiple-matches.grel) | API project | Variant: when DBpedia has multiple rows per person, aggregate distinct values with `"; "` instead of taking just the first. |

## OpenRefine UI mapping

In all cases the menu path is **Edit column → Add column based on this column…**, with the GREL expression pasted in. The new column lands to the right of the source column.

`cross()` requires both projects to be open in the same OpenRefine instance. The second argument is the *project name* as it appears in OpenRefine (it must match exactly, including casing). The third argument is the column in the *other* project that holds the matching key.
