<?php
namespace app\model;
use think\Model;
use think\facade\Db;

class Role extends Model{

	protected $table = 'role';
	protected $pk = 'roleid';

    /**
     * 获取角色列表（分页 + 搜索）
     */
    public function getList($filter = [], $page = 1, $size = 20)
    {
        $query = Db::name('role')->alias('r')
            ->leftJoin('user_account u', 'r.userid = u.id')
            ->field('r.roleid, r.name, r.avatar, r.level, r.userid, r.profession, r.createtime, r.lastlogintime, u.username');

        if (!empty($filter['roleid'])) {
            $query->where('r.roleid', intval($filter['roleid']));
        }
        if (!empty($filter['name'])) {
            $query->whereLike('r.name', '%' . $filter['name'] . '%');
        }
        if (!empty($filter['username'])) {
            $query->whereLike('u.username', '%' . $filter['username'] . '%');
        }
        if (!empty($filter['level_min'])) {
            $query->where('r.level', '>=', intval($filter['level_min']));
        }
        if (!empty($filter['level_max'])) {
            $query->where('r.level', '<=', intval($filter['level_max']));
        }

        $total = $query->count();
        $list = $query->order('r.roleid', 'desc')
            ->page($page, $size)
            ->select()
            ->toArray();

        return ['list' => $list, 'total' => $total];
    }

    /**
     * AJAX表格数据接口
     */
    public function getListForTable($filter = [], $offset = 0, $limit = 20)
    {
        $query = Db::name('role')->alias('r')
            ->leftJoin('user_account u', 'r.userid = u.id')
            ->field('r.roleid, r.name, r.avatar, r.level, r.userid, r.profession, r.createtime, r.lastlogintime, u.username');

        if (!empty($filter['roleid'])) {
            $query->where('r.roleid', intval($filter['roleid']));
        }
        if (!empty($filter['name'])) {
            $query->whereLike('r.name', '%' . $filter['name'] . '%');
        }
        if (!empty($filter['username'])) {
            $query->whereLike('u.username', '%' . $filter['username'] . '%');
        }

        $total = $query->count();
        $list = $query->order('r.roleid', 'desc')
            ->limit($offset, $limit)
            ->select()
            ->toArray();

        return ['rows' => $list, 'total' => $total];
    }

    /**
     * 按角色ID查询
     */
    public function getByRoleId($roleid)
    {
        return Db::name('role')->where('roleid', intval($roleid))->find();
    }

    /**
     * 按用户ID查询所有角色
     */
    public function getByUserId($userid)
    {
        return Db::name('role')->where('userid', intval($userid))->select()->toArray();
    }

    /**
     * 角色总数
     */
    public function getRoleCount()
    {
        return Db::name('role')->count();
    }
}
