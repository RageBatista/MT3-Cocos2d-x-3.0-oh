<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\UserLog as UL;
use app\model\GameLoginLog;
use think\Response;

class Log extends BaseController
{
    /**
     * 玩家登录日志页面
     */
    public function playerLogin()
    {
        $filter = $this->buildPlayerLoginFilter($this->request->get());

        return view('player_login', ['filter' => $filter]);
    }

    /**
     * 获取玩家登录日志列表（AJAX）
     */
    public function playerLoginList()
    {
        $post = $this->request->param();
        $filter = $this->buildPlayerLoginFilter($post) ?? [];

        $page = isset($post['page']) ? intval($post['page']) : 1;
        $limit = isset($post['limit']) ? intval($post['limit']) : 10;

        // 获取合并后的登录日志
        $result = GameLoginLog::getMergedLoginLogs($filter, $page, $limit);

        return json($result);
    }

    public function userLog()
    {
		$type = $this->request->param('type',1);
        return view('log',['type'=>$type]);
    }
    public function list_table()
    {
		$type = $this->request->param('type',1);
		$post = $this->request->param();
		$table_log = $this->buildUserLogFilters($post);
		$log = new UL();
		$getLogList = $log->getLogList($post,$type,$table_log);
        return json($getLogList);
    }

	private function buildPlayerLoginFilter(array $data)
	{
		$filter = [];

		foreach (['role_id', 'role_name', 'account', 'ip', 'start_date', 'end_date'] as $key) {
			$value = isset($data[$key]) ? trim((string)$data[$key]) : '';
			if ($value !== '') {
				$filter[$key] = $this->validateInput($value);
			}
		}

		return $filter ?: null;
	}

	private function buildUserLogFilters(array $data)
	{
		$filters = [];

		$username = isset($data['username']) ? trim((string)$data['username']) : '';
		if ($username !== '') {
			$filters[] = ['username', 'like', '%' . $this->validateInput($username) . '%'];
		}

		$info = isset($data['info']) ? trim((string)$data['info']) : '';
		if ($info !== '') {
			$filters[] = ['info', 'like', '%' . $this->validateInput($info) . '%'];
		}

		$date = isset($data['date']) ? trim((string)$data['date']) : '';
		if ($date !== '') {
			$filters[] = ['date', 'like', '%' . $this->validateInput($date) . '%'];
		}

		return $filters ?: null;
	}
	
}
