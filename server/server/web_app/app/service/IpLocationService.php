<?php
declare(strict_types=1);

namespace app\service;

use cznet\IpLocation;

class IpLocationService
{
    public static function locate(string $ip): array
    {
        $location = new IpLocation();
        $locationData = $location->getlocation($ip);

        $country = '未知';
        $area = '未知';
        if (is_array($locationData)) {
            $country = $locationData['country'] ?? '未知';
            $area = $locationData['area'] ?? '未知';
        }

        return [
            'ip' => $ip,
            'city' => $country . '-' . $area,
        ];
    }
}
