# Synthetic import fixtures

All committed identities are synthetic. `generate.mjs` consults no export at runtime; reference export supplied input shape and target counts only. It generates deterministic source JSON, normalized golden records and ZIP inputs.

Run from repository root:

```sh
node fixtures/generate.mjs
```

`manifest.json` reports single-snapshot set counts: 810 following, 783 followers, 747 mutual, 36 follower-only and 63 following-only. `goldens.json` contains sorted normalized records with `identity`, `display`, `profileUrl`, and `sourceTimestamp`. Timestamp values remain source Unix seconds; absent or invalid values normalize to null. Case folding and duplicate handling are parser behavior to test, not an assertion that source records are distinct.

`baseline.zip` holds split follower parts and following JSON. Other ZIP files are adversarial parser inputs:

| File | Condition |
| --- | --- |
| `traversal.zip` | `../` archive path |
| `casefoldDuplicate.zip` | Names differing only by case |
| `symlink.zip` | Unix symlink file type in external attributes |
| `encrypted.zip` | General-purpose encryption flag |
| `nestedArchive.zip` | ZIP stored as an entry |
| `ratioLimit.zip` | Deflated JSON with expansion ratio above 200:1 |
| `sizeLimit.zip` | Deflated JSON entry above 20 MiB uncompressed |
| `metadataDeception.zip` | Local-header CRC and size disagree with central directory |

Large expansion fixtures are built in bounded generator memory (roughly 22 MiB payload) and committed compressed. They are synthetic repeated padding, not social data.
