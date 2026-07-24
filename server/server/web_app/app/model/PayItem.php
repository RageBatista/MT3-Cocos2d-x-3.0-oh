<?php
namespace app\model;
use think\Model;

class PayItem extends Model{
	
	protected $table = 'main_pay_item';
	
	
    public function getPayItemList($status,$type)
	{
		$sortOrder = isset($post['sortOrder'])?$post['sortOrder']:'asc';
		$sort = isset($post['sort'])?$post['sort']:'id';
		$condition = []; 
		$condition[] = ["status",'=',$status];
		//$condition[] = ["type",'=',$type];
		$item = PayItem::where($condition)->order($sort ,$sortOrder)->select();
		$data = $item->toArray();
		return $data;
    }
    public function getPayItemById($id)
	{
		$payitem = PayItem::where('id', $id)->find();
		return $payitem;
		
    }
	
}

?>