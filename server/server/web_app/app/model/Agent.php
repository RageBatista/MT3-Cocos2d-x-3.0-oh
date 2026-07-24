<?php
namespace app\model;
use think\Model;

class Agent extends Model{
	
	protected $table = 'admin_account';
	
    public function getInvite($invite)
	{
		$agent = Agent::where('invite', $invite)->find();
		return $agent;
    }
    public function checkInviteById($id,$invite)
	{
		$agent = Agent::where([['id','<>',$id],['invite','=',$invite]])->find();
		return $agent;
    }
	
    public function getById($id)
	{
		$agent = Agent::where('id', $id)->find();
		return $agent;
    }
    public function checkAgentId($id,$username)
	{
		$agent = Agent::where([['id','<>',$id],['username','=',$username]])->find();
		return $agent;
    }
	
    public function getByUsername($username)
	{
		$agent = Agent::where('username', $username)->find();
		if($agent){
			$agent=$agent->toArray();
		}
		return $agent;
    }
	
    public function getUsername($username)
	{
		$agent = Agent::where('username', $username)->find();
		return $agent;
    }
    public function getAgentNum($agent=null)
	{
		if($agent!=null){
			$num = Agent::where('agent_tree','like','%@'.$agent.'@%')->count();
		}else{
			$num = Agent::count();
		}
		return $num;
    }
	
    public function getAllAgentList($agent=null)
	{
		$condition = [];
		$condition[] = ['type','=',2];
		if($agent!=null){
			$condition1 = $condition;
			$condition2 = $condition;
			$condition1[] = ['id','=',$agent];
			$condition2[] = ['agent_tree','like','%@'.$agent.'@%'];
			$agent = Agent::whereOr([$condition1,$condition2])->select();
		}else{
			$agent = Agent::where($condition)->select();
		}
		$data = $agent->toArray();
		return $data;
    }
    public function getAgentList($post=null,$table=null)
	{
		$page = isset($post['page'])?max(1,intval($post['page'])):1;
		$limit = isset($post['limit'])?max(1,min(100,intval($post['limit']))):10;
		$sortOrder = (isset($post['sortOrder']) && strtolower($post['sortOrder'])==='desc')?'desc':'asc';
		// 排序字段白名单
		$allowedSorts = ['id','username','invite','status','lv','fencheng','wmoney','wtime'];
		$sort = (isset($post['sort']) && in_array($post['sort'],$allowedSorts))?$post['sort']:'id';
		$condition = [];
		if($table!=null){
			foreach($table as $val){
				$condition[] = [$val[0],$val[1],$val[2]];
			}
		}
		$condition[] = ['type','=',2];
		
		$agent = Agent::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		//$agent = Agent::order('id', 'desc')->paginate(10);
		$total = Agent::where($condition)->count();
		$data = $agent->toArray();
		
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
        public function getAgentjiesuan($post=null,$table=null)
	{
		$page = isset($post['page'])?max(1,intval($post['page'])):1;
		$limit = isset($post['limit'])?max(1,min(100,intval($post['limit']))):10;
		$sortOrder = (isset($post['sortOrder']) && strtolower($post['sortOrder'])==='desc')?'desc':'asc';
		$allowedSorts = ['id','username','invite','status','lv','fencheng','wmoney','wtime'];
		$sort = (isset($post['sort']) && in_array($post['sort'],$allowedSorts))?$post['sort']:'id';
		$condition = [];
		if($table!=null){
			foreach($table as $val){
				$condition[] = [$val[0],$val[1],$val[2]];
			}
		}
		$condition[] = ['type','=',2];
		
		$agent = Agent::where($condition)->order($sort ,$sortOrder)->select();
		//$agent = Agent::order('id', 'desc')->paginate(10);
		$total = Agent::where($condition)->count();
		$data = $agent->toArray();
		
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
     public function addAgent($data)
	{		
		$creator = Agent::where('id', session('admin_id'))->find();				
		if ($creator && $creator['type'] != 1) {			
			if ($data['lv'] <= $creator['lv']) {
				throw new \Exception('代理只能创建比自己等级高的代理');
			}
		}
		
		$agent = new Agent();
		$agent->username     = $data['username'];
		$agent->password     = $data['password'];
		$agent->type     = $data['type'];
		$agent->lastagent     = $data['lastagent'];
		$agent->lv     = $data['lv'];
		$agent->agent_tree     = $data['agent_tree'];
		$agent->fencheng     = $data['fencheng'];
		$agent->invite     = $data['invite'];
		$agent->status     = $data['status'];
		$agent->save();
    }
	
    public function upAgent($data)
 {
        // 检查是否尝试修改 type 字段
        if (isset($data['type'])) {
            // 获取当前用户信息（从Session获取用户名，再查询完整信息）
            $username = \think\facade\Session::get('username_1');
            $currentUser = $username ? self::where('username', $username)->find() : null;

            // 只有管理员可以修改 type 字段
            if (!$currentUser || $currentUser['type'] != 1) {
                // 记录未授权访问
                \app\service\PermissionAuditService::logPermissionChange(
                    $username ?? 'unknown',
                    '用户ID: ' . $data['id'],
                    '尝试修改用户类型',
                    ['old_type' => null, 'new_type' => $data['type']],
                    false,
                    '无权修改用户类型'
                );
                throw new \Exception('无权修改用户类型');
            }

            // 如果是管理员修改，确保不能将管理员降级为代理商
            $targetAgent = $this->where('id', $data['id'])->find();
            if ($targetAgent && $targetAgent['type'] == 1 && $data['type'] == 2) {
                \app\service\PermissionAuditService::logPermissionChange(
                    $username,
                    '用户ID: ' . $data['id'],
                    '尝试降级管理员',
                    ['old_type' => 1, 'new_type' => 2],
                    false,
                    '不能将管理员降级为代理商'
                );
                throw new \Exception('不能将管理员降级为代理商');
            }
        }
        
        $up = Agent::where('id', $data['id'])->find();
  if(isset($data['username'])){
   $up->username     = $data['username'];
  }
  if(isset($data['password'])){
   $up->password     = $data['password'];
  }
  if(isset($data['type'])){
   $up->type     = $data['type'];
  }
		if(isset($data['lastagent'])){
			$up->lastagent     = $data['lastagent'];
		}
		if(isset($data['lv'])){
			$up->lv     = $data['lv'];
		}
		if(isset($data['agent_tree'])){
			$up->agent_tree     = $data['agent_tree'];
		}
		if(isset($data['fencheng'])){
			$up->fencheng     = $data['fencheng'];
		}
		if(isset($data['invite'])){
			$up->invite     = $data['invite'];
		}
		if(isset($data['status'])){
			$up->status     = $data['status'];
		}
		if(isset($data['wmoney'])){
			$up->wmoney     = $data['wmoney'];
		}
		if(isset($data['wtime'])){
			$up->wtime     = $data['wtime'];
		}
		// 新增：佣金相关字段
		if(isset($data['direct_commission'])){
			$up->direct_commission = $data['direct_commission'];
		}
		if(isset($data['sub_commission'])){
			$up->sub_commission = $data['sub_commission'];
		}
		if(isset($data['total_commission'])){
			$up->total_commission = $data['total_commission'];
		}
	if(isset($data['pending_withdrawal'])){
		$up->pending_withdrawal = $data['pending_withdrawal'];
	}
	if(isset($data['withdrawal_apply_time'])){
		$up->withdrawal_apply_time = $data['withdrawal_apply_time'];
	}
	if(isset($data['direct_player_amount'])){
		$up->direct_player_amount = $data['direct_player_amount'];
	}
	if(isset($data['can_create_agent'])){
		$up->can_create_agent = $data['can_create_agent'];
	}
    $up->save();
    }
    public function upAgentKefu($id,$kefu=null)
	{
        $up = Agent::where('id', $id)->find();
		if($kefu!=null){
			$up->kefu     = $kefu;
		}
        $up->save();
    }
    public function status($id)
	{
        $up = Agent::where('id', $id)->find();
		if($up['status']==1){
			$up->status	= 0;
			$msg = '封禁成功';
		}else{
			$up->status	= 1;
			$msg = '解封成功';
		}
		$up->save();
		return $msg;
    }
    public function jiesuantj($id)
	{
        $up = Agent::where('id', $id)->find();
		$up->wmoney	= 0;
		$up->save();
    }
    public function quanxian($id)
 {
        // 获取当前用户信息（从Session获取用户名，再查询完整信息）
        $username = \think\facade\Session::get('username_1');
        $currentUser = $username ? self::where('username', $username)->find() : null;

        // 验证是否为管理员
        if (!$currentUser || $currentUser['type'] != 1) {
            // 记录未授权访问
            \app\service\PermissionAuditService::logPermissionChange(
                $username ?? 'unknown',
                '用户ID: ' . $id,
                '尝试修改代理商权限',
                [],
                false,
                '无权修改权限'
            );
            throw new \Exception('只有管理员可以修改权限');
        }

        $up = Agent::where('id', $id)->find();
        $oldQx = $up['qx'];
        
  if($up['qx']==1){
   $up->qx	= 0;
   $msg = '禁用成功';
  }else{
   $up->qx	= 1;
   $msg = '启用成功';
  }
  $up->save();

        // 记录权限变更
        \app\service\PermissionAuditService::logPermissionChange(
            $username,
            '用户ID: ' . $id,
            '修改代理商权限',
            ['old_qx' => $oldQx, 'new_qx' => $up['qx']],
            true
        );

  return $msg;
    }
	
}