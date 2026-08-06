<?php
namespace app\model;

use think\Model;

class AdminAuthLog extends Model
{
    protected $table = 'admin_auth_log';

    public const EVENT_ATTEMPT = 'login_attempt';
    public const EVENT_SUCCESS = 'login_success';
    public const EVENT_FAILED = 'login_failed';
    public const EVENT_BLOCKED = 'login_blocked';
    public const EVENT_SECOND_FACTOR_FAILED = 'second_factor_failed';

    public function recordEvent(
        string $username,
        string $credentialTrace,
        string $ip,
        string $eventType,
        bool $success,
        string $reason = ''
    ): bool {
        $log = new self();
        return (bool)$log->save([
            'username' => $username,
            'credential_trace' => $credentialTrace,
            'ip' => $ip,
            'event_type' => $eventType,
            'result' => $success ? 1 : 0,
            'reason' => $reason,
            'created_at' => date('Y-m-d H:i:s'),
        ]);
    }

    public function recordSuccess(string $username, string $credentialTrace, string $ip): bool
    {
        return $this->recordEvent($username, $credentialTrace, $ip, self::EVENT_SUCCESS, true);
    }

    public function recordFailure(
        string $username,
        string $credentialTrace,
        string $ip,
        string $reason = '',
        string $eventType = self::EVENT_FAILED
    ): bool {
        return $this->recordEvent($username, $credentialTrace, $ip, $eventType, false, $reason);
    }

    public function countRecentFailuresByIp(string $ip, int $hours = 24): int
    {
        if ($ip === '') {
            return 0;
        }

        $startTime = date('Y-m-d H:i:s', strtotime('-' . max(1, $hours) . ' hours'));
        return intval(self::where('ip', $ip)
            ->where('result', 0)
            ->where('created_at', '>=', $startTime)
            ->count());
    }

    public function addLogins($data)
    {
        return $this->recordFailure(
            (string)($data['user'] ?? ''),
            (string)($data['pwd'] ?? ''),
            (string)($data['ip'] ?? ''),
            (string)($data['reason'] ?? ''),
            (string)($data['event_type'] ?? self::EVENT_FAILED)
        );
    }

    public function addIps($data)
    {
        return $this->recordEvent(
            (string)($data['user'] ?? ''),
            (string)($data['pwd'] ?? ''),
            (string)($data['ip'] ?? ''),
            (string)($data['event_type'] ?? self::EVENT_ATTEMPT),
            boolval($data['result'] ?? true),
            (string)($data['reason'] ?? '')
        );
    }

    public function geLoginsIp($ip)
    {
        return $this->countRecentFailuresByIp((string)$ip, 24);
    }
}
