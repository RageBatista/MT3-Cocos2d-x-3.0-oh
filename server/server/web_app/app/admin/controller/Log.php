<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use app\model\UserLog as UL;
use app\model\GameLoginLog;
use think\Response;
use think\facade\Session;

class Log extends BaseController
{
    /**
     * 玩家登录日志页面
     */
    public function playerLogin()
    {
        $get = $this->request->get();
        $filter = null;

        // 保存查询条件到Session
        if (isset($get['role_id']) || isset($get['role_name']) || isset($get['account']) || isset($get['ip']) || isset($get['start_date']) || isset($get['end_date'])) {
            $filter = [];
            if (!empty($get['role_id'])) {
                $filter['role_id'] = $this->validateInput($get['role_id']);
            }
            if (!empty($get['role_name'])) {
                $filter['role_name'] = $this->validateInput($get['role_name']);
            }
            if (!empty($get['account'])) {
                $filter['account'] = $this->validateInput($get['account']);
            }
            if (!empty($get['ip'])) {
                $filter['ip'] = $this->validateInput($get['ip']);
            }
            if (!empty($get['start_date'])) {
                $filter['start_date'] = $this->validateInput($get['start_date']);
            }
            if (!empty($get['end_date'])) {
                $filter['end_date'] = $this->validateInput($get['end_date']);
            }
            Session::set('player_login_filter', $filter);
        } else {
            $filter = Session::get('player_login_filter');
        }

        return view('player_login', ['filter' => $filter]);
    }

    /**
     * 获取玩家登录日志列表（AJAX）
     */
    public function playerLoginList()
    {
        $post = $this->request->post();
        $filter = Session::get('player_login_filter', []);

        $page = isset($post['page']) ? intval($post['page']) : 1;
        $limit = isset($post['limit']) ? intval($post['limit']) : 10;

        // 获取合并后的登录日志
        $result = GameLoginLog::getMergedLoginLogs($filter, $page, $limit);

        return jsonp($result);
    }

    public function userLog()
    {
		$type = $this->request->param('type',1);
		$get = $this->request->get();
		$table_log = null;
		if(isset($get['username'])&&isset($get['info'])&&isset($get['date'])){
			if($get['username']!=null){
				$username = $this->validateInput($get['username']);
				$table_log[] = ['username','like','%'.$username.'%'];
			}
			if($get['info']!=null){
				$info = $this->validateInput($get['info']);
				$table_log[] = ['info','like','%'.$info.'%'];
			}
			if($get['date']!=null){
				$date = $this->validateInput($get['date']);
				$table_log[] = ['date','like','%'.$date.'%'];
			}
			Session::set('table_log', $table_log);
		}else{
			$table_log = null;
			Session::delete('table_log');
		}
        return view('log',['type'=>$type]);
    }
    public function list_table()
    {
		$table_log = Session::get('table_log');
		$type = $this->request->param('type',1);
		$post = $this->request->post();
		$log = new UL();
		$getLogList = $log->getLogList($post,$type,$table_log);
        return jsonp($getLogList);
    }
	
}
