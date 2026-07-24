<?php
namespace app\model;
use think\Model;

class Voice extends Model{
	
	protected $table = 'user_voice';
	
    public function getVoice($uuid)
	{
		$voice = Voice::where('uuid', $uuid)->find();
		return $voice;
    }
    public function insVoice($data)
	{
		$voice = new Voice();
		$voice->uuid     = $data['uuid'];
		$voice->text     = $data['text'];
		$voice->channelid     = $data['channelid'];
		$voice->time     = $data['time'];
		$voice->save();
    }
    public function getVoiceList($post=null,$table=null)
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

		$agent = Voice::where($condition)->limit($limit)->page($page)->order($sort ,$sortOrder)->select();
		//$agent = Agent::order('id', 'desc')->paginate(10);
		$total = Voice::where($condition)->count();
		$data = $agent->toArray();

		$data=[
			'total'=>$total,
			'rows'=>$data
		];
		return $data;
    }

    /**
     * 统计指定用户的语音记录数量（用于数据清理）
     */
    public function countByUserId($userid)
    {
        $userModel = new \app\model\User();
        $user = $userModel->getById($userid);
        if ($user) {
            return Voice::where('uuid', $user['username'])->count();
        }
        return 0;
    }

    /**
     * 删除指定用户的所有语音记录（用于数据清理）
     */
    public function deleteByUserId($userid)
    {
        $userModel = new \app\model\User();
        $user = $userModel->getById($userid);
        if ($user) {
            return Voice::where('uuid', $user['username'])->delete();
        }
        return 0;
    }
}
?>