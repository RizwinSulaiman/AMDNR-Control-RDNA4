# lmxxf RDNA4 upstream audit

AMDNR 0.3.4 documents the bundled RDNA4 lmxxf kernels as **0.31**. The safest direct upgrade line is therefore the last upstream release that remains transitively bit-identical to 0.31: **0.35** (`ec96774dca27badee9c6429d7c55586484188911`). This branch pins that source instead of copying experimental `main` wholesale.

Upstream 0.32 through 0.35 are production releases whose accepted kernel changes are documented as bit-exact against the preceding release. They add the VRAM pool reuse/C32 wide-read work (0.32), FP8 packing (0.33), clamp/packing and PDL lifecycle fixes (0.34), and the C32 direct/vector/full-window plus ViT byte-stream work (0.35).

**0.36 is the compatibility boundary.** Most of its improvements are bit-exact, but it intentionally contracts activation multiply-adds to float FMA and explicitly establishes a new numeric baseline. 0.37 and 0.38 are bit-exact to that 0.36 baseline, not to AMDNR's 0.31 lineage. For a strict bit-exact update, do not cross this boundary.

The current upstream `main` was audited through `4c207ff404eca3e63c269cb8a990a14f8cf8c60d`. After 0.38, accepted production changes include C512 residual/load hoists, compact fused QKV, one-kernel C512 FFN, decoder low-byte tails, and half-width down/pool paths. Upstream records each as bit-exact to the 0.38 baseline. They are useful for a future opt-in "new numeric baseline" track, but inherit 0.36's rounding change.

Public non-default branches and PR refs were checked. `vit-1080-gap` and `resample-fold` are explicitly slower and not taken; `AttExp` contains approximation/reuse research and rejected experiments; PR 12 remains outside production. Current `main` also contains several default-off experiments recorded as slower, mixed, null, or not accepted. None are imported by this branch.

`pin.json` is the machine-readable ledger. `fetch-pinned.ps1` verifies/materializes one of three exact commits without touching a game install:

```powershell
.\tools\lmxxf-safe\fetch-pinned.ps1 -Track strict
.\tools\lmxxf-safe\fetch-pinned.ps1 -Track strict -Destination .\_vendor\lmxxf-0.35
```

`strict` is the recommended source pin. `latest-release` points to 0.38 and `latest-audited` to the audited `main` commit for controlled comparison only; both cross the 0.36 numeric-baseline boundary.

## Non-main refs

All public heads and fetched PR refs were compared with `main`. `720p`, `900P`, and `HIP` are already ancestors of `main`. `resample-fold` and `vit-1080-gap` are newer side branches, but their tip results explicitly say 3/3 ABBA slower and "not taken". `AttExp` contains historical preview/approximation work; its branch summary records adoption status, but no production-worthy accepted change remains uniquely stranded there after the later mainline work. No accepted-but-not-main performance win was found to import.
