<?php
namespace app\model;
use think\Model;

class Fankui extends Model{
	
	protected $table = 'user_fankui';
	
    public function insFankui($data)
	{
		$now = date('Y-m-d H:i:s');
		$fankui = new Fankui();
		$fankui->uid      = intval($data['uid'] ?? 0);
		$fankui->username = isset($data['username']) ? (string)$data['username'] : null;
		$fankui->role     = intval($data['role'] ?? 0);
		$fankui->info     = (string)($data['info'] ?? '');
		$fankui->time     = isset($data['time']) ? (string)$data['time'] : $now;
		$fankui->status   = 0;
		$fankui->created_at = isset($data['created_at']) ? (string)$data['created_at'] : $now;
		$fankui->updated_at = isset($data['updated_at']) ? (string)$data['updated_at'] : $now;
		$fankui->save();
		return $fankui;
    }
	
    public function getFankuiId($id)
	{
		$fankui = Fankui::where('id', $id)->find();
		return $fankui;
    }
    public function getFankuiRole($role)
	{
		$fankui = Fankui::where('role',$role)->order('id desc')->select();
		return $fankui;
    }
    public function upStatus($id, $reply = null, $adminId = null)
	{
        $up = Fankui::where('id', $id)->find();
		if(!$up){
			return null;
		}
		$now = date('Y-m-d H:i:s');
		$up->status	= 1;
		if($reply !== null && $reply !== ''){
			$up->reply = (string)$reply;
		}
		if($adminId !== null && intval($adminId) > 0){
			$up->admin_id = intval($adminId);
		}
		$up->processed_at = $now;
		$up->updated_at = $now;
		$up->save();
		return $up;
    }

    public function deleteByUserId($userId)
	{
		$uid = intval($userId);
		if($uid <= 0){
			return 0;
		}
		return Fankui::where('uid', $uid)->delete();
    }
	
    public function getFankuiList($post=null,$table=null)
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
		if($condition){
			$fankui = Fankui::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
			$data = $fankui->toArray();
			$total = Fankui::where($condition)->count();
		}else{
			$fankui = Fankui::limit($limit)->page($page)->order($sort ,$sortOrder)->select();
			$data = $fankui->toArray();
			$total = Fankui::count();
		}
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
	
		return $data;
    }
	
}
?>
