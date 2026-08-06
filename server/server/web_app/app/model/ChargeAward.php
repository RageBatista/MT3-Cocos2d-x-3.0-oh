<?php
namespace app\model;
use think\Model;

class ChargeAward extends Model{
	
	protected $table = 'main_charge_award';
	
	
    public function getAwardList($type,$status=1)
	{
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'id';
		$condition = []; 
		$condition[] = ["status",'=',$status];
		$condition[] = ["type",'=',$type];
		$item = ChargeAward::where($condition)->order($sort ,$sortOrder)->select();
		$data = $item->toArray();
		return $data;
    }
    public function getAwardById($id)
	{
		$award = ChargeAward::where('id', $id)->find();
		$data = $award->toArray();

		return $award;
		
    }
	
	public function getAllAwardList($post=null,$condition=null)
	{
		$page = isset($post['page'])?$post['page']:1;
		$limit = isset($post['limit'])?$post['limit']:10;
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'value';
		$item = ChargeAward::where($condition)->order($sort ,$sortOrder)->select();
		$total = ChargeAward::where($condition)->count();
		$award = $item->toArray();
		$data=[
			'total'=>$total,
			'rows'=>$award
		];
	
		return $data;
    }
}

?>
