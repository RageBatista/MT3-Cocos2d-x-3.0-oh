<?php
namespace app\model;
use think\Model;

class Fankui extends Model{
	
	protected $table = 'user_fankui';
	
    public function insFankui($data)
	{
		$fankui = new Fankui();
		$fankui->role     = $data['role'];
		$fankui->info     = $data['info'];
		$fankui->time     = $data['time'];
		$fankui->status     = 0;
		$fankui->save();
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
    public function upStatus($id)
	{
        $up = Fankui::where('id', $id)->find();
		$up->status	= 1;
		$up->save();
		return $up;
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