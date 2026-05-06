# Nobel Prize API — laureates endpoint

The second source of the pipeline is the official Nobel Prize REST API, which provides authoritative data on every Nobel laureate (year of award, motivation, affiliation at the time of the award, etc.). Unlike DBpedia, this API is curated by the Nobel Foundation directly.

## Base

| Field | Value |
| :--- | :--- |
| Provider | Nobel Foundation Rights AB |
| Documentation hub | <https://www.nobelprize.org/about/developer-zone/> |
| API spec | <https://www.nobelprize.org/about/developer-zone/openapi/2.1/> |
| Base URL | `https://api.nobelprize.org/2.1/` |

## Endpoint used

`GET /laureates` returns **one record per Nobel laureate** (person or organisation) and unifies all their prize information in a single object. The companion `/nobelPrizes` endpoint returns prizes instead, which would require a second hop to recover laureate metadata; using `/laureates` is the cheaper path for our pipeline.

```
GET https://api.nobelprize.org/2.1/laureates?nobelPrizeCategory=phy
```

The `nobelPrizeCategory=phy` query parameter narrows the result to laureates of the **Physics** prize. The supported category codes are `phy`, `che`, `med`, `lit`, `pea`, `eco`.

## Output shape (relevant fields)

```jsonc
{
  "laureates": [
    {
      "id": "1",
      "knownName":   { "en": "Wilhelm Conrad Röntgen" },
      "givenName":   { "en": "Wilhelm Conrad" },
      "familyName":  { "en": "Röntgen" },
      "fullName":    { "en": "Wilhelm Conrad Röntgen" },
      "gender": "male",
      "birth":       { "date": "1845-03-27", "place": { "city": {"en":"Lennep"}, "country": {"en":"Prussia"} } },
      "death":       { "date": "1923-02-10", "place": { ... } },
      "nobelPrizes": [
        {
          "awardYear": "1901",
          "category":     { "en": "Physics" },
          "categoryFullName": { "en": "The Nobel Prize in Physics" },
          "motivation":   { "en": "in recognition of the extraordinary services he has rendered..." },
          "affiliations": [ { "name": {"en":"Munich University"}, ... } ]
        }
      ]
    },
    ...
  ]
}
```

`fullName.en` is the field used as the source of `fullName` in the OpenRefine pipeline (with a GREL fallback that reconstructs it from `givenName.en + familyName.en` when missing).

## Why this API instead of (e.g.) Wikipedia infoboxes

- It's the **authoritative** source — published by the Nobel Foundation itself, not extracted heuristically.
- The schema is stable and **versioned** in the URL (`/2.1/`), unlike DBpedia, whose schema can drift across dumps.
- It covers fields DBpedia doesn't surface cleanly: prize motivation text in English, year of the award per laureate, affiliation at the time of the award.

In the pipeline these complement DBpedia rather than replace it: DBpedia gives the rich biographical context (place of birth, abstract, links to Wikipedia articles), the API gives the clean prize-side metadata.
