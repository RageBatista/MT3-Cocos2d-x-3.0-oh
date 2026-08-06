<?php
declare (strict_types = 1);

namespace app\agent\controller;

use app\BaseController;
use app\model\User as U;
use app\model\Bind as B;
use app\model\Agent as AG;
use app\gm\Gm as Game;
use app\model\Server;
use app\model\UserLog as ULog;

class Player extends BaseController
{
    public function list()
    {
		$AG = new AG();
		$getAgentList = $AG->getAllAgentList($this->myAdmin['id']);
		
        return view('list',['getAgentList'=>$getAgentList]);
    }
    public function list_table()
    {
		$post = $this->request->param();
		$table_player = $this->buildPlayerFilters($post);
		$user = new U();
		$getPlayerList = $user->getAgentPlayerList($post,$table_player,$this->myAdmin['id']);
		$rows = $getPlayerList['rows'] ?? [];

		$agentIds = [];
		foreach ($rows as $row) {
			$agentId = intval($row['lastagent'] ?? 0);
			if ($agentId > 0) {
				$agentIds[$agentId] = $agentId;
			}
		}

		$agentNameMap = [];
		if (!empty($agentIds)) {
			$agents = AG::whereIn('id', array_values($agentIds))
				->field('id,username')
				->select()
				->toArray();
			foreach ($agents as $agent) {
				$agentNameMap[intval($agent['id'])] = $agent['username'];
			}
		}

		foreach ($rows as $key => $val) {
			$agentId = intval($val['lastagent'] ?? 0);
			$val['last_username'] = $agentNameMap[$agentId] ?? 'unknown';
			$getPlayerList['rows'][$key] = $val;
		}
        return jsonp($getPlayerList);
    }
    public function edit()
    {
		$user = new U();
		$get = $this->request->get();
		if(isset($get['id'])){
			$getById = $user->getById($get['id']);
			if(!$getById){
				 return '玩家账号不存在<br/><a href="#" onclick="history.back();return false;">返回上一页</a>';
			}
		}
        return view('edit',['getById'=>$getById]);
    }
	
    public function editSubmit()
    {
	// ===== 临时关闭改密功能 =====
	return notify(0,'系统维护中：玩家改密功能暂未开放，如需修改请联系系统管理员');
	// ===== 以下代码暂时禁用 =====
	/*
	$user = new U();
	$post = $this->request->post();
	$pattern = '/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/';
	if(isset($post['id'])&&$post['id']!=null){
		$id = $post['id'];
		$getByIdAgent = $user->getById($id);
		if(!$getByIdAgent){
			return notify(0,'玩家信息有误！');
		}
	}else{
		return notify(0,'玩家信息有误');
	}
	if(isset($post['password'])&&$post['password']!=null){
		$password = strtolower($post['password']);
		if(!preg_match($pattern, $password)){
			return notify(0,'密码必须为6-18位字母+数字');
		}
		$password = password($password);
	}else{
		$password = $getByIdAgent['password'];
	}
	$data = [
		"id"=>$id,
		"password"=>$password,
	];
	$upUser = $user->upUser($data);
	return notify(1,'修改成功');
	*/
	// ===== 改密功能暂时禁用结束 =====
    }
	
	
	public function bindList()
    {
		$selected = intval($this->request->param('selected', 0)) === 1 ? 1 : 0;
		
        return view('bind_list', ['selected' => $selected]);
    }
    public function bind_list_table()
    {
		$post = $this->request->param();
		$table_bind = $this->buildBindFilters($post);
		$table_bind_selected = intval($post['selected'] ?? 0) === 1 ? 1 : 0;
		$bind = new B();
		if($table_bind_selected==1){
			$getBindList = $bind->getBindList($post,$table_bind);
		}else{
			$getBindList = $bind->getBindList($post,$table_bind,$this->myAdmin['id']);
		}
		\think\facade\Log::info('代理绑定列表接口返回', [
			'total' => intval($getBindList['total'] ?? 0),
			'rows' => count($getBindList['rows'] ?? []),
			'selected' => $table_bind_selected,
			'agent_id' => intval($this->myAdmin['id'] ?? 0),
			'has_username' => isset($post['username']) && $this->hasSearchValue($post['username']) ? 1 : 0,
			'has_playerid' => isset($post['playerid']) && $this->hasSearchValue($post['playerid']) ? 1 : 0,
			'has_playername' => isset($post['playername']) && $this->hasSearchValue($post['playername']) ? 1 : 0,
		]);
        return jsonp($getBindList);
    }
    public function status()
    {
		if($this->myAdmin['qx']<1)return notify(0,'无此权限');
		$user = new U();
		$post = $this->request->post();
		if(isset($post['id'])){
			$getById = $user->getById($post['id']);
			if(!$getById){
				 return notify(0,'玩家账号不存在');
			}else{
				if($getById['status']==1){
					$bind = new B();
					$server = new Server();
					$Game = new Game();
					$status = $user->status($post['id']);
					$getAllBindListUID = $bind->getAllBindListUID($post['id']);
					foreach($getAllBindListUID as $key=>$val){
						$serverData = $server->getServerId($val['serverid']);
						$data = array(
							'serverip'  => $serverData['serverip'],
							'gmlocal'  => $serverData['gmlocal'],
							'gmport'  => $serverData['gmport'],
							'playerid'  => $val['playerid'],
						);
						$gameNotify = $Game->kick($data);
					}
				}else{
					$status = $user->status($post['id']);
				}
				$userLog = new ULog();
				$userLog->addAgentLog($this->myAdmin['username'],'对玩家账号【'.$getById['username'].'】执行操作：'.$status,$this->genericVariable);
				return notify(1,$status);
			}
		}else{
			return notify(0,'玩家信息有误');
		}
	}

	private function buildPlayerFilters(array $data)
	{
		$filters = [];

		$username = isset($data['username']) ? trim((string)$data['username']) : '';
		if ($username !== '') {
			$filters[] = ['u.username', 'like', '%' . $this->validateInput($username) . '%'];
		}

		$lastagent = isset($data['lastagent']) ? intval($data['lastagent']) : 0;
		if ($lastagent > 0) {
			$filters[] = ['u.lastagent', '=', $lastagent];
		}

		return $filters ?: null;
	}

	private function buildBindFilters(array $data)
	{
		$filters = [];

		$username = isset($data['username']) ? trim((string)$data['username']) : '';
		if ($this->hasSearchValue($username)) {
			$filters[] = ['u.username', 'like', '%' . $this->validateInput($username) . '%'];
		}

		$playerid = isset($data['playerid']) ? trim((string)$data['playerid']) : '';
		if ($this->hasSearchValue($playerid)) {
			$filters[] = ['b.playerid', 'like', '%' . $this->validateInput($playerid) . '%'];
		}

		$playername = isset($data['playername']) ? trim((string)$data['playername']) : '';
		if ($this->hasSearchValue($playername)) {
			$filters[] = ['b.playername', '=', $this->validateInput($playername)];
		}

		return $filters ?: null;
	}

	private function hasSearchValue($value): bool
	{
		$raw = trim((string)$value);
		if ($raw === '') {
			return false;
		}
		return trim($raw, " \t\n\r\0\x0B\"'") !== '';
	}
}
