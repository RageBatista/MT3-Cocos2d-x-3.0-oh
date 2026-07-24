<?php
namespace app\model;
use think\Model;

class Item extends Model{
	
	protected $table = 'main_item';
	
    public function getItemList($post=null,$table=null)
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
			$itme = Item::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
			$data = $itme->toArray();
			$total = Item::where($condition)->count();
		}else{
			$itme = Item::limit($limit)->page($page)->order($sort ,$sortOrder)->select();
			$data = $itme->toArray();
			$total = Item::count();
		}
		$data=[
			'total'=>$total,
			'rows'=>$data
		];
	
		return $data;
    }
	
    public function getItemByType($type)
	{
		$itme = Item::where('type',$type)->select();
		$data = $itme->toArray();
		return $data;
    }
    public function drop($type)
	{
		$drop = $this->where('type',$type)->delete();
		return $drop;
    }

    public function dropAll()
	{
		$drop = $this->where('id', '>', 0)->delete();
		return $drop;
    }

    public function save_all($list)
	{
		$save_all = $this->saveAll($list);
		return $save_all;
    }
	
	
	
}

?>
