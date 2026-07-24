<?php
declare(strict_types=1);

namespace app\player\service;

use think\facade\Cache;
use think\facade\Db;
use app\model\Server as ServerModel;

/**
 * ServerService - 统一服务器服务类
 * 整合玩家服务中心和梦幻授权控制台的服务器选择功能
 */
class ServerService
{
    /**
     * 缓存前缀
     */
    const CACHE_PREFIX = 'server:';
    
    /**
     * 默认缓存时间（秒）
     */
    const CACHE_TTL_DEFAULT = 300;
    
    /**
     * 高频访问缓存时间（秒）- 服务器列表等频繁访问的数据
     */
    const CACHE_TTL_HIGH_FREQ = 600;
    
    /**
     * 单个服务器信息缓存时间（秒）
     */
    const CACHE_TTL_SINGLE = 300;
    
    /**
     * 进程级缓存（请求周期内有效）
     * @var array
     */
    private static $processCache = [];
    
    /**
     * 进程级缓存命中计数器
     * @var array
     */
    private static $cacheHits = [];
    
    /**
     * 获取服务器列表
     * @param bool $enabledOnly 是否只获取启用的服务器
     * @return array 服务器列表
     */
    public function getServerList(bool $enabledOnly = true): array
    {
        $cacheKey = self::CACHE_PREFIX . 'list:' . ($enabledOnly ? 'enabled' : 'all');
        
        // 【优化】先检查进程级缓存，减少IO操作
        if (isset(self::$processCache[$cacheKey])) {
            self::$cacheHits[$cacheKey] = (self::$cacheHits[$cacheKey] ?? 0) + 1;
            return self::$processCache[$cacheKey];
        }
        
        $cached = Cache::get($cacheKey);
        if ($cached !== null) {
            // 存入进程级缓存
            self::$processCache[$cacheKey] = $cached;
            return $cached;
        }
        
        $S = new ServerModel();
        $list = $enabledOnly ? $S->makeServerList() : $S->getAllServerList();
        
        if (is_object($list) && method_exists($list, 'toArray')) {
            $list = $list->toArray();
        }
        
        if (!is_array($list)) {
            $list = [];
        }
        
        $result = [];
        foreach ($list as $row) {
            $result[] = $this->formatServerInfo($row);
        }
        
        // 【优化】服务器列表高频访问，使用更长的缓存时间
        Cache::set($cacheKey, $result, self::CACHE_TTL_HIGH_FREQ);
        // 存入进程级缓存
        self::$processCache[$cacheKey] = $result;
        
        return $result;
    }
    
    /**
     * 根据服务器ID获取服务器信息
     * @param int|string $serverId 服务器ID
     * @return array|null 服务器信息
     */
    public function getServerById($serverId): ?array
    {
        if (empty($serverId)) {
            return null;
        }
        
        $serverId = is_numeric($serverId) ? intval($serverId) : $serverId;
        
        $cacheKey = self::CACHE_PREFIX . 'id:' . $serverId;
        
        // 【优化】先检查进程级缓存
        if (isset(self::$processCache[$cacheKey])) {
            self::$cacheHits[$cacheKey] = (self::$cacheHits[$cacheKey] ?? 0) + 1;
            return self::$processCache[$cacheKey];
        }
        
        $cached = Cache::get($cacheKey);
        if ($cached !== null) {
            // 存入进程级缓存
            self::$processCache[$cacheKey] = $cached;
            return $cached;
        }
        
        $S = new ServerModel();
        $serverRow = $S->getServerId($serverId);
        
        if (!$serverRow) {
            $serverByPk = $S->getServer($serverId);
            if ($serverByPk) {
                $serverRow = $serverByPk;
            } else {
                $serverByPort = $S->where('gmport', $serverId)->find();
                if ($serverByPort) {
                    $serverRow = $serverByPort;
                }
            }
        }
        
        if (!$serverRow) {
            return null;
        }
        
        $result = $this->formatServerInfo($serverRow);
        
        // 【优化】单个服务器信息使用标准缓存时间
        Cache::set($cacheKey, $result, self::CACHE_TTL_SINGLE);
        // 存入进程级缓存
        self::$processCache[$cacheKey] = $result;
        
        return $result;
    }
    
    /**
     * 解析服务器（支持多种ID格式）
     * @param int|string|null $serverId 服务器ID
     * @return array|null 服务器信息
     */
    public function resolveServer($serverId): ?array
    {
        if ($serverId !== null && $serverId !== '') {
            return $this->getServerById($serverId);
        }
        
        $serverList = $this->getServerList(true);
        if (!empty($serverList)) {
            return $serverList[0];
        }
        
        return null;
    }
    
    /**
     * 获取服务器GM连接信息
     * @param int|string $serverId 服务器ID
     * @return array|null GM连接信息
     */
    public function getGmConnection($serverId): ?array
    {
        $server = $this->getServerById($serverId);
        
        if (!$server) {
            return null;
        }
        
        return [
            'serverip' => $server['serverip'] ?? '',
            'gmlocal' => $server['gmlocal'] ?? '',
            'gmport' => $server['gmport'] ?? 0,
            'serverid' => $server['serverid'],
            'name' => $server['name']
        ];
    }
    
    /**
     * 检查服务器是否可用
     * @param int|string $serverId 服务器ID
     * @return bool 是否可用
     */
    public function isServerAvailable($serverId): bool
    {
        $server = $this->getServerById($serverId);
        
        if (!$server) {
            return false;
        }
        
        if (isset($server['status']) && $server['status'] != 1) {
            return false;
        }
        
        return true;
    }
    
    /**
     * 获取服务器分组列表
     * @return array 分组列表
     */
    public function getServerGroups(): array
    {
        $cacheKey = self::CACHE_PREFIX . 'groups';
        
        // 【优化】先检查进程级缓存
        if (isset(self::$processCache[$cacheKey])) {
            self::$cacheHits[$cacheKey] = (self::$cacheHits[$cacheKey] ?? 0) + 1;
            return self::$processCache[$cacheKey];
        }
        
        $cached = Cache::get($cacheKey);
        if ($cached !== null) {
            // 存入进程级缓存
            self::$processCache[$cacheKey] = $cached;
            return $cached;
        }
        
        $serverList = $this->getServerList(true);
        
        $groups = [];
        foreach ($serverList as $server) {
            $groupname = $server['groupname'] ?? '默认分组';
            if (!isset($groups[$groupname])) {
                $groups[$groupname] = [];
            }
            $groups[$groupname][] = $server;
        }
        
        // 【优化】分组列表使用高频缓存时间
        Cache::set($cacheKey, $groups, self::CACHE_TTL_HIGH_FREQ);
        // 存入进程级缓存
        self::$processCache[$cacheKey] = $groups;
        
        return $groups;
    }
    
    /**
     * 清除服务器缓存
     */
    public function clearCache(): void
    {
        $keys = [
            self::CACHE_PREFIX . 'list:enabled',
            self::CACHE_PREFIX . 'list:all',
            self::CACHE_PREFIX . 'groups'
        ];
        
        foreach ($keys as $key) {
            Cache::delete($key);
        }
    }
    
    /**
     * 格式化服务器信息
     * @param array $row 服务器数据行
     * @return array 格式化后的服务器信息
     */
    private function formatServerInfo(array $row): array
    {
        return [
            'serverid' => intval($row['serverid'] ?? 0),
            'name' => $row['name'] ?? '',
            'groupname' => $row['groupname'] ?? '',
            'serverip' => $row['serverip'] ?? '',
            'gmlocal' => $row['gmlocal'] ?? '',
            'gmport' => intval($row['gmport'] ?? 0),
            'status' => intval($row['status'] ?? 1),
            'online' => intval($row['online'] ?? 0),
            'max_online' => intval($row['max_online'] ?? 0)
        ];
    }
    
    /**
     * 获取服务器状态统计
     * @return array 状态统计
     */
    public function getServerStats(): array
    {
        $serverList = $this->getServerList(false);
        
        $total = count($serverList);
        $enabled = 0;
        $disabled = 0;
        $totalOnline = 0;
        
        foreach ($serverList as $server) {
            if (($server['status'] ?? 1) == 1) {
                $enabled++;
            } else {
                $disabled++;
            }
            $totalOnline += $server['online'] ?? 0;
        }
        
        return [
            'total' => $total,
            'enabled' => $enabled,
            'disabled' => $disabled,
            'total_online' => $totalOnline
        ];
    }
}
