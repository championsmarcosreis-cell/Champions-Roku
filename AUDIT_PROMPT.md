# Champions Roku: Live HLS A/V Desync Audit Prompt

You are auditing a Roku SceneGraph/BrightScript app repo (`Champions-Roku`) for a persistent **Live TV audio/video desynchronization** problem on Roku devices.

## Scope / Constraints

- Do **not** redesign UI/layout/banners. Focus only on **player stability**.
- Goal:
  - **Live TV:** stable playback + volume. No trickplay required (no FF/RW).
  - **VOD:** must support **captions** + **multiple audio tracks** (via Roku's native `*` menu if possible).
- Assume the HLS source is good (plays in other devices/players). The issue is **Roku-specific**.
- Do not introduce or request secrets in code. Any `.secrets/*` is local-only and gitignored.

## Environment (Observed)

- Roku device: SEMP Roku TV `50RK8600` (model `G153X`)
- Roku OS: `15.1.4` build `3334`
- Roku dev mode device IP: `192.168.0.39`
- Gateway VM used by the app (LAN): `http://192.168.0.35:3000`
- Live HLS origin (LAN): `http://192.168.0.35:8089/hls/index.m3u8`

## Problem

- **Live TV on Roku** has audible A/V desync (user reports "same as before" after attempted fixes).
- Other devices/players (HLS on "eixo player") play the same Live HLS without issues.

## What Was Changed / Attempted (and did NOT fix desync)

### Roku app: player behavior changes

File: `components/MainScene.brs`

- Removed/avoided **seek-based "snap to live edge"** logic during Live playback.
  - Rationale: seeking into HLS windows can land between segment boundaries and cause A/V drift on Roku.
- Set Live metadata on the `ContentNode`:
  - `Live=true`
  - `PlayStart=-12` (start slightly behind live edge without explicit seeks)
- Allow Roku native playback menu during playback:
  - When video is playing, `*` (options) is passed through (`onKeyEvent` returns `false`) so Roku can show captions/audio track UI for VOD.
- Added periodic `/sign` renewal for Live (gateway signed URLs expire by default around 20 minutes):
  - Timer (`m.sigCheckTimer`) checks remaining `exp` and triggers a new sign call before expiry.
  - Added logic to ignore a transient `stopped` state when switching the stream mid-playback.
  - Also cancels any in-flight sign job when the user exits playback to avoid "late sign response restarts video".
- Removed `ContentNode.Bitrate` hint because it caused Roku error **"no valid bitrates"** on a single-variant playlist.

### LAN live origin: HLS packaging changes

File: `scripts/setup-live-hls.ps1` (writes systemd units on gateway VM)

The gateway origin service (`champions-live-hls.service`) was updated to:

- Use `-hls_time 4` and `-hls_list_size 60`
- Add:
  - `-hls_start_number_source epoch`
  - `-hls_flags delete_segments+program_date_time+temp_file`
- Try to reduce timestamp drift by re-encoding audio:
  - `-c:a aac -b:a 128k -ar 48000 -af aresample=async=1`
  - Video stays copy: `-c:v copy`

This did not fix the perceived A/V desync on Roku.

## Observations That Might Matter

- Old LAN HLS (2s segments, `-c copy`) showed per-segment audio duration often ~80-100ms shorter than video (measured via `ffprobe`), and audio start PTS slightly offset.
- After switching to 4s + audio transcode/async resample, segments still sometimes showed audio duration slightly different than video (not perfectly constant).
- US/EU VPS HLS services exist (SRT ingest -> HLS) using 4s segments and `program_date_time`. These may behave better, but the user still reports Roku issue.

## Repo Areas Likely Relevant

- Player + UX integration: `components/MainScene.brs`, `components/MainScene.xml`
- Signing / gateway calls: `components/GatewayTask.*`, `source/gateway.brs`
- LAN Live HLS setup helper: `scripts/setup-live-hls.ps1`
- Gateway server (not in this repo; VM `/srv/champions-gateway/server.js`) signs URLs and rewrites HLS playlists with `exp`/`sig`.

## What We Need From You (Auditor)

1. Identify the most plausible Roku-specific causes of Live A/V desync for HLS MPEG-TS.
2. Propose concrete changes, prioritized:
   - HLS packaging (ffmpeg flags, timestamp strategy, discontinuity handling, AAC encoder params, mux settings).
   - Roku Video node configuration (fields that influence live buffering, clocking, sync).
   - Any gateway playlist rewrite pitfalls specific to Roku.
3. Recommend a minimal set of experiments to isolate whether the root cause is:
   - segment timestamp drift (PTS/DTS),
   - AAC framing / encoder delay,
   - Roku buffering strategy on Live streams,
   - playlist window size/targetduration mismatches,
   - lack of `EXT-X-DISCONTINUITY`/`EXT-X-PROGRAM-DATE-TIME`,
   - Roku handling of TS vs CMAF (fMP4 HLS).

Keep guidance implementation-focused (commands + code edits). Avoid generic troubleshooting.

