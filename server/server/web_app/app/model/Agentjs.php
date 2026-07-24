<?php
namespace app\model;
use think\Model;

class Agentjs extends Model{
	protected $table = 'user_agentjs';
	    public function addAgentjs($data)
	{
		$agentjs = new Agentjs();
		$agentjs->uid     = $data['uid'];
		$agentjs->time     = $data['time'];
		$agentjs->money     = $data['money'];
		$agentjs->start     = $data['start'];
		$agentjs->save();
    }
    
    public function getById($id)
	{
		$agentjs = Agentjs::where('id', $id)->find();
		return $agentjs;
    }
    
    public function getAgentjsList($post=null,$table=null)
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

		$agentjs = Agentjs::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		//$agent = Agent::order('id', 'desc')->paginate(10);
		$total = Agentjs::where($condition)->count();
		$data = $agentjs->toArray();
		
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }
    
    public function tixianshenhe($id)
	{
        $up = Agentjs::where('id', $id)->find();
		if($up['start']==0){
			$up->start	= 1;
			$msg = '结算审核成功';
		}else{
			$up->start	= 0;
			$msg = '当前订单改为未审核';
		}
		$up->save();
		return $msg;
    }
	
}