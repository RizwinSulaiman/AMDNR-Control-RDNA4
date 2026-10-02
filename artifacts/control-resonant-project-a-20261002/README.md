# Control Resonant Project A staging

This folder stages the native-Windows d4r/RDNA4 path separately from the AMDNR/OptiScaler Project B path. Nothing here targets the live Control Resonant directory until `Select-ProjectA.ps1` is explicitly invoked with that game's executable. If the pinned public d4r archive is absent, the selector downloads that exact prerelease and verifies its SHA256 before extraction.

Pinned inputs:

- Project A base: `exp/control-rdna4` at `e858a56`.
- Integration branch: `integration/control-20261002-a`.
- d4r release tag: `v0.1.4`, commit `c522101341d019d1ce0379e5932cd80f780349ee`.
- Native Windows prerelease: `windows-rdna4-dev-20261002-a346d76`, source `a346d76`, ZLUDA `a1c506f`.
- Archive: `d4r-windows-rdna4-20261002.zip`, SHA256 `5b9a47e9d0c9a042567c2096eb8eaafb0a28473614b656865d794a39f5165d8e`.
- AMDNR upstream observed: `f58604d`, release `0.3.5.1`; TheAutomatic observed: `f7edf1e` / `v1.9.9.1`.

Project A and Project B both own an OptiScaler/proxy slot beside the game executable, so they are kept selector-based. The d4r runner has its own guarded install/restore backup and refuses to restore over files that changed after installation.

After the replacement game archive is fully extracted, activate Project A with locally supplied NVIDIA NGX/DLSS DLLs:

```powershell
.\Select-ProjectA.ps1 -Action install -GameExe 'C:\path\to\game.exe' -NgxCore 'C:\path\to\_nvngx.dll' -DlssDll 'C:\path\to\nvngx_dlss.dll' -Preset 11 -AsyncInterop
```

Preset 11 is K. Preset 13 is M. The current Windows package keeps the validated FP16-equivalent M baseline. `-AsyncInterop` is the current opt-in K scheduling path that passed the queued-frame/recreation regression and the five-minute RX 9070 XT run described by d4r.

Restore Project A before activating the separate Project B pipeline:

```powershell
.\Select-ProjectA.ps1 -Action restore -GameExe 'C:\path\to\game.exe'
```

The public d4r package excludes NVIDIA proprietary DLLs and private texture kernels. The optional locally generated K output-store optimization therefore remains outside this artifact.
