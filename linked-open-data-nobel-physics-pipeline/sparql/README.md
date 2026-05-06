# SPARQL queries

Catalogue of every query written for the practice. The **main** query is the deliverable that feeds the OpenRefine pipeline; the **warm-up** and **ASK** queries are smaller learning steps that build the mental model needed to write the main one.

All queries target the public DBpedia endpoint at <https://dbpedia.org/sparql>. Paste the file contents into the editor, set *Results Format → CSV* (or *HTML* for inspection), and hit **Run**.

---

## Files

| Stage | File | Purpose |
| :--- | :--- | :--- |
| Main | [`main-nobel-laureates-physics.sparql`](main-nobel-laureates-physics.sparql) | The deliverable. Returns one row per Nobel-laureate-in-Physics with English label, abstract, birth date, birth place and country. The first stage of the OpenRefine pipeline. |
| Warm-up | [`warmup-01-gmail-info.sparql`](warmup-01-gmail-info.sparql) | First triple-pattern query: author and supported languages of `dbr:Gmail`. Introduces `dbo:` vs `dbp:`. |
| Warm-up | [`warmup-02-discover-resource-by-homepage.sparql`](warmup-02-discover-resource-by-homepage.sparql) | "From known to unknown" pattern: anchor on a homepage URL via `foaf:homepage`, recover the resource. |
| Warm-up | [`warmup-03-products-by-google.sparql`](warmup-03-products-by-google.sparql) | Direction-of-arrows pattern: `?x dbo:author dbr:Google` vs the reverse. |
| Warm-up | [`warmup-04-creators-with-pagination.sparql`](warmup-04-creators-with-pagination.sparql) | `LIMIT` + `OFFSET` for paginating through large result sets without hitting the endpoint's row cap. |
| ASK | [`ask-01-paris-as-un-country.sparql`](ask-01-paris-as-un-country.sparql) | `ASK` for boolean existence: is Paris a UN-member country? (no). |
| ASK | [`ask-02-bombay-vs-ny-population.sparql`](ask-02-bombay-vs-ny-population.sparql) | `ASK` with `FILTER` numeric comparison across two resources. |

---

## DBpedia prefix cheatsheet

| Prefix | URI | Used for |
| :--- | :--- | :--- |
| `dbr:` | `http://dbpedia.org/resource/` | A *resource*, i.e. a node (e.g. `dbr:Albert_Einstein`). |
| `dbo:` | `http://dbpedia.org/ontology/` | An *ontology property* — mapped, typed (e.g. `dbo:birthDate`). |
| `dbp:` | `http://dbpedia.org/property/` | A *raw property* — straight from the infobox, no mapping (e.g. `dbp:language`). |
| `dbc:` | `http://dbpedia.org/resource/Category:` | A category resource (e.g. `dbc:Nobel_laureates_in_Physics`). |
| `dct:` | `http://purl.org/dc/terms/` | Dublin Core Terms (e.g. `dct:subject` to attach a resource to a category). |
| `rdfs:` | `http://www.w3.org/2000/01/rdf-schema#` | RDFS (e.g. `rdfs:label` for human-readable names). |
| `foaf:` | `http://xmlns.com/foaf/0.1/` | Friend Of A Friend (e.g. `foaf:homepage`). |

`dbo:` is the right reach for a stable, typed property. `dbp:` is the fallback when no ontology mapping exists yet — same data, different layer.

## Reading triples

A SPARQL triple `subject predicate object` is a directed edge in the RDF graph: the *subject* node has an outgoing edge labelled *predicate* whose head points at the *object* node (which itself can be a resource or a literal value). Variables (`?x`) match any node. The query engine's job is to find every binding of the variables that makes the whole pattern hold simultaneously.

`OPTIONAL { ... }` is the SPARQL equivalent of a SQL `LEFT JOIN`: include the inner pattern's binding if it matches, otherwise leave the variable unbound and keep the outer row.
