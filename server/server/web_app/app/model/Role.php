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
            // 绑定关系优先于 role.userid（user_bind 是权威绑定源）
            ->leftJoin('user_bind b', 'b.playerid = r.roleid AND b.id = (SELECT MIN(bb.id) FROM user_bind bb WHERE bb.playerid = r.roleid)')
            ->leftJoin('user_account ur', 'ur.id = r.userid')
            ->leftJoin('user_account ub', 'ub.id = b.userid')
            ->field('CAST(r.roleid AS CHAR) AS roleid, r.name, r.avatar, r.level, COALESCE(b.userid, ur.id, r.userid) AS userid, r.profession, r.createtime, r.lastlogintime, COALESCE(ub.username, ur.username) AS username');

        if (!empty($filter['roleid'])) {
            $query->where('r.roleid', intval($filter['roleid']));
        }
        if (!empty($filter['name'])) {
            $query->whereLike('r.name', '%' . $filter['name'] . '%');
        }
        if (!empty($filter['username'])) {
            $query->whereRaw('COALESCE(ub.username, ur.username) LIKE :username', [
                'username' => '%' . $filter['username'] . '%'
            ]);
        }
        if (!empty($filter['level_min'])) {
            $query->where('r.level', '>=', intval($filter['level_min']));
        }
        if (!empty($filter['level_max'])) {
            $query->where('r.level', '<=', intval($filter['level_max']));
        }

        $total = (clone $query)->count();
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
            // 绑定关系优先于 role.userid（user_bind 是权威绑定源）
            ->leftJoin('user_bind b', 'b.playerid = r.roleid AND b.id = (SELECT MIN(bb.id) FROM user_bind bb WHERE bb.playerid = r.roleid)')
            ->leftJoin('user_account ur', 'ur.id = r.userid')
            ->leftJoin('user_account ub', 'ub.id = b.userid')
            ->field('CAST(r.roleid AS CHAR) AS roleid, r.name, r.avatar, r.level, COALESCE(b.userid, ur.id, r.userid) AS userid, r.profession, r.createtime, r.lastlogintime, COALESCE(ub.username, ur.username) AS username');

        if (!empty($filter['roleid'])) {
            $query->where('r.roleid', intval($filter['roleid']));
        }
        if (!empty($filter['name'])) {
            $query->whereLike('r.name', '%' . $filter['name'] . '%');
        }
        if (!empty($filter['username'])) {
            $query->whereRaw('COALESCE(ub.username, ur.username) LIKE :username', [
                'username' => '%' . $filter['username'] . '%'
            ]);
        }

        $total = (clone $query)->count();
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
