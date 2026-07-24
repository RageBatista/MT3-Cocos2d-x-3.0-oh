<?php
namespace app\player\model;

use think\Model;

/**
 * PlayerProfile模型 - 玩家个人资料模型
 * 存储玩家个人资料
 */
class PlayerProfile extends Model
{
    protected $table = 'player_profile';
    
    protected $autoWriteTimestamp = 'datetime';
    
    protected $createTime = 'created_at';
    protected $updateTime = 'updated_at';
    
    /**
     * 获取个人资料
     * @param int $userId 用户ID
     * @return array|null 个人资料
     */
    public function getProfile($userId)
    {
        if (empty($userId) || $userId <= 0) {
            return null;
        }
        
        $profile = $this->where('user_id', $userId)->find();
        
        if ($profile) {
            return $profile->toArray();
        }
        
        return null;
    }
    
    /**
     * 更新个人资料
     * @param int $userId 用户ID
     * @param array $data 更新数据
     * @return bool 更新结果
     */
    public function updateProfile($userId, $data)
    {
        if (empty($userId) || $userId <= 0) {
            return false;
        }
        
        // 查找是否存在个人资料
        $profile = $this->where('user_id', $userId)->find();
        
        if (!$profile) {
            // 不存在则创建
            $profile = new PlayerProfile();
            $profile->user_id = $userId;
        }
        
        // 允许更新的字段
        $allowedFields = [
            'nickname', 'real_name', 'gender', 'birthday',
            'phone', 'email', 'qq', 'wechat', 'avatar',
            'province', 'city', 'address', 'remark'
        ];
        
        foreach ($allowedFields as $field) {
            if (isset($data[$field])) {
                $profile->$field = $data[$field];
            }
        }
        
        return $profile->save();
    }
    
    /**
     * 创建个人资料
     * @param int $userId 用户ID
     * @param array $data 初始数据
     * @return bool 创建结果
     */
    public function createProfile($userId, $data = [])
    {
        if (empty($userId) || $userId <= 0) {
            return false;
        }
        
        // 检查是否已存在
        $existing = $this->where('user_id', $userId)->find();
        if ($existing) {
            return false;
        }
        
        $profile = new PlayerProfile();
        $profile->user_id = $userId;
        
        // 设置初始数据
        if (isset($data['nickname'])) {
            $profile->nickname = $data['nickname'];
        }
        
        return $profile->save();
    }
    
    /**
     * 更新头像
     * @param int $userId 用户ID
     * @param string $avatar 头像URL
     * @return bool 更新结果
     */
    public function updateAvatar($userId, $avatar)
    {
        if (empty($userId) || $userId <= 0) {
            return false;
        }
        
        $profile = $this->where('user_id', $userId)->find();
        
        if (!$profile) {
            // 不存在则创建
            $profile = new PlayerProfile();
            $profile->user_id = $userId;
        }
        
        $profile->avatar = $avatar;
        
        return $profile->save();
    }
    
    /**
     * 获取玩家昵称
     * @param int $userId 用户ID
     * @return string 昵称
     */
    public function getNickname($userId)
    {
        if (empty($userId) || $userId <= 0) {
            return '';
        }
        
        $profile = $this->where('user_id', $userId)->find();
        
        if ($profile && !empty($profile->nickname)) {
            return $profile->nickname;
        }
        
        // 如果没有昵称，返回用户名
        $userModel = new \app\model\User();
        $user = $userModel->getById($userId);
        
        return $user ? $user['username'] : '';
    }
    
    /**
     * 搜索玩家
     * @param string $keyword 关键词
     * @param int $page 页码
     * @param int $limit 每页数量
     * @return array 搜索结果
     */
    public function searchPlayers($keyword, $page = 1, $limit = 20)
    {
        if (empty($keyword)) {
            return [];
        }
        
        $query = $this->alias('p')
            ->join('user_account u', 'p.user_id = u.id')
            ->where(function($q) use ($keyword) {
                $q->whereLike('p.nickname', '%' . $keyword . '%')
                  ->whereOr('u.username', 'like', '%' . $keyword . '%')
                  ->whereOr('p.real_name', 'like', '%' . $keyword . '%')
                  ->whereOr('p.phone', 'like', '%' . $keyword . '%');
            });
        
        $list = $query->field('p.*,u.username')
            ->order('p.updated_at', 'desc')
            ->page($page, $limit)
            ->select();
        
        $total = $query->count();
        
        return [
            'list' => $list,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'pages' => ceil($total / $limit)
        ];
    }
}
