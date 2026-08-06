<?php
declare(strict_types=1);

namespace app\service;

class GmJmxcExecutorService
{
    /**
     * Execute primary command and optionally fallback to classpath mode.
     *
     * @param string $primaryCmd shell command with jar mode
     * @param string $fallbackCmd shell command with classpath mode
     * @return array{output:array<int,string>,exitCode:int,usedFallback:bool}
     */
    public function execute(string $primaryCmd, string $fallbackCmd = ''): array
    {
        $out = [];
        $ret = 0;
        exec($primaryCmd . ' 2>&1', $out, $ret);

        $usedFallback = false;
        if ($ret !== 0 && $fallbackCmd !== '' && $this->shouldFallbackToClassPath($out)) {
            $out = [];
            $ret = 0;
            exec($fallbackCmd . ' 2>&1', $out, $ret);
            $usedFallback = true;
        }

        return [
            'output' => $out,
            'exitCode' => $ret,
            'usedFallback' => $usedFallback,
        ];
    }

    private function shouldFallbackToClassPath(array $output): bool
    {
        $text = strtolower(implode("\n", $output));
        return strpos($text, 'could not find or load main class jmxc') !== false;
    }
}

