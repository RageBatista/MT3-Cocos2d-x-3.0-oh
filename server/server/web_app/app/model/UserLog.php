<?php
namespace app\model;
use think\Model;

class UserLog extends Model{

	protected $table = 'user_log';

	// 日志类型常量
	const TYPE_GM = 'GM操作';
	const TYPE_PLAYER = '玩家管理';
	const TYPE_AGENT = '代理管理';
	const TYPE_ORDER = '订单管理';
	const TYPE_SERVER = '服务器操作';
	const TYPE_MAIL = '邮件操作';
	const TYPE_SYSTEM = '系统操作';

	/**
	 * 格式化日志信息（新增结构化日志方法）
	 * @param string $type 操作类型
	 * @param string $action 操作动作
	 * @param array $data 操作数据
	 * @return string 格式化后的日志信息
	 */
	public static function formatLogInfo($type, $action, $data = [])
	{
		$info = $type . ' - ' . $action;
		if (!empty($data)) {
			$details = [];
			foreach ($data as $key => $value) {
				if (is_array($value)) {
					$value = json_encode($value, JSON_UNESCAPED_UNICODE);
				}
				$details[] = $key . ':' . $value;
			}
			$info .= ', ' . implode(', ', $details);
		}
		return $info;
	}

	/**
	 * 添加GM操作日志（结构化格式）
	 */
	public static function addGmLog($username, $action, $data = [], $genericVariable = [])
	{
		$user = new UserLog();
		$user->username = $username;
		$user->info = self::formatLogInfo(self::TYPE_GM, $action, $data);
		$user->date = $genericVariable['date'] ?? date('Y-m-d');
		$user->time = $genericVariable['time'] ?? date('H:i:s');
		$user->ip = $genericVariable['ip'] ?? '127.0.0.1';
		$user->city = $genericVariable['city'] ?? '本机';
		$user->lv = 3; // 管理员日志
		$user->save();
		return $user;
	}

	/**
	 * 添加玩家操作日志（结构化格式）
	 */
	public static function addPlayerLog($username, $action, $data = [], $genericVariable = [])
	{
		$user = new UserLog();
		$user->username = $username;
		$user->info = self::formatLogInfo(self::TYPE_PLAYER, $action, $data);
		$user->date = $genericVariable['date'] ?? date('Y-m-d');
		$user->time = $genericVariable['time'] ?? date('H:i:s');
		$user->ip = $genericVariable['ip'] ?? '127.0.0.1';
		$user->city = $genericVariable['city'] ?? '本机';
		$user->lv = 3;
		$user->save();
		return $user;
	}

	/**
	 * 添加代理操作日志（结构化格式）
	 */
	public static function addAgentOpLog($username, $action, $data = [], $genericVariable = [])
	{
		$user = new UserLog();
		$user->username = $username;
		$user->info = self::formatLogInfo(self::TYPE_AGENT, $action, $data);
		$user->date = $genericVariable['date'] ?? date('Y-m-d');
		$user->time = $genericVariable['time'] ?? date('H:i:s');
		$user->ip = $genericVariable['ip'] ?? '127.0.0.1';
		$user->city = $genericVariable['city'] ?? '本机';
		$user->lv = 3;
		$user->save();
		return $user;
	}

    public function addUserLog($username,$info,$genericVariable)
	{
		$user = new UserLog();
		$user->username     = $username;
		$user->info    = $info;
		$user->date    = $genericVariable['date'];
		$user->time    = $genericVariable['time'];
		$user->ip    = $genericVariable['ip'];
		$user->city    = $genericVariable['city'];
		// $user->ip    = '127.0.0.1';
		// $user->city    = '本机';
		$user->lv    = 1;
		$user->save();
    }
    public function addAgentLog($username,$info,$genericVariable)
	{
		$user = new UserLog();
		$user->username     = $username;
		$user->info    = $info;
		$user->date    = $genericVariable['date'];
		$user->time    = $genericVariable['time'];
		$user->ip    = $genericVariable['ip'];
		$user->city    = $genericVariable['city'];
		$user->lv    = 2;
		$user->save();
    }
    public function addAdminLog($username,$info,$genericVariable)
	{
		$user = new UserLog();
		$user->username     = $username;
		$user->info    = $info;
		$user->date    = $genericVariable['date'];
		$user->time    = $genericVariable['time'];
		$user->ip    = $genericVariable['ip'];
		$user->city    = $genericVariable['city'];
		$user->lv    = 3;
		$user->save();
    }
    public function getLogList($post=null,$lv=1,$table=null)
	{
		$page = isset($post['page'])?$post['page']:1;
		$limit = isset($post['limit'])?$post['limit']:10;
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'id';
		$condition = [];
		if($table!=null){
			foreach($table as $val){
				$condition[] = [$val[0],$val[1],$val[2]];
			}
		}
		$condition[] = ['lv','=',$lv];
		$agent = UserLog::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		$total = UserLog::where($condition)->count();
		$data = $agent->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }

    /**
     * 统计指定用户的日志数量（用于数据清理）
     */
    public function countByUserId($userid)
    {
        // username字段存储的是玩家账号的用户名，不是userid
        // 需要通过User表获取username
        $userModel = new \app\model\User();
        $user = $userModel->getById($userid);
        if ($user) {
            return UserLog::where('username', $user['username'])->count();
        }
        return 0;
    }

    /**
     * 删除指定用户的所有日志（用于数据清理）
     */
    public function deleteByUserId($userid)
    {
        $userModel = new \app\model\User();
        $user = $userModel->getById($userid);
        if ($user) {
            return UserLog::where('username', $user['username'])->delete();
        }
        return 0;
    }


}
?>