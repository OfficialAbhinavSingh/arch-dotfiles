// ─────────────────────────────────────────────────────────────────────────────
// Zen Browser — user.js
// Tuned for: Ryzen 7 6800H + Radeon 680M (radeonsi), 14 GiB RAM, Wayland.
//
// user.js is re-applied on every startup, so anything set here wins over what
// you change in about:config at runtime. Delete a line here if you want to
// control that pref from the UI instead.
// ─────────────────────────────────────────────────────────────────────────────

// ── AI sidebar ───────────────────────────────────────────────────────────────
// Gecko's built-in chatbot sidebar. Open it from the sidebar button, or select
// text on a page and use the shortcut popup to summarize / explain / quiz.
// Swap `provider` for another service any time:
//   https://chatgpt.com  ·  https://gemini.google.com  ·  https://chat.mistral.ai
//   https://huggingface.co/chat  ·  https://copilot.microsoft.com
user_pref("browser.ml.chat.enabled", true);
user_pref("browser.ml.chat.provider", "https://claude.ai/new");
// These two may not exist in every Gecko build; an unknown pref is inert.
user_pref("browser.ml.chat.shortcuts", true);
user_pref("browser.ml.chat.shortcuts.custom", true);
// On-device translation models (no text leaves the machine).
user_pref("browser.translations.enable", true);
user_pref("browser.translations.automaticallyPopup", false);

// ── Hardware video decode on the 680M ────────────────────────────────────────
// vainfo confirms radeonsi exposes H.264, HEVC, HEVC-10bit, VP9 and AV1 (VLD).
// force-enabled bypasses Mozilla's driver blocklist, which still trips on some
// Mesa versions and silently leaves you decoding 4K on the CPU.
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);
user_pref("media.av1.enabled", true);
// Zero-copy dmabuf path between the decoder and the compositor on Wayland.
user_pref("widget.dmabuf.force-enabled", true);
user_pref("gfx.webrender.all", true);

// ── Memory: 14 GiB total, routinely under 4 GiB free ─────────────────────────
// Default content-process cap is 8. Four still keeps tabs isolated per site
// (fission stays on — do not disable it, it is a security boundary) but cuts
// the per-process overhead that dominates at high tab counts.
user_pref("dom.ipc.processCount", 4);
// Discard background tabs before the kernel starts swapping to zram.
user_pref("browser.tabs.unloadOnLowMemory", true);
// Session file is rewritten every 15s by default; 60s is plenty and spares the
// NVMe and a wakeup.
user_pref("browser.sessionstore.interval", 60000);
// Cap the back/forward in-memory page cache (default -1 = auto, up to 8/tab).
user_pref("browser.sessionhistory.max_total_viewers", 3);
