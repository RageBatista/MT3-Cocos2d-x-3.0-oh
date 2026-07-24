<?php
declare (strict_types = 1);

namespace app\admin\controller;

use app\BaseController;
use think\facade\Session;
use think\facade\Request;
use app\model\Transfer as TransferModel;
use app\model\Server;
use app\model\Bind;
use app\model\User;
use app\gm\Gm as Game;

/**
 * Transfer控制器 - 转区管理控制器
 * 处理管理员转区审批和管理
 */
class Transfer extends BaseController
{
    /**
     * 转区申请列表页面
     */
    public function list()
    {
        $get = $this->request->get();
        $filters = null;
        
        // 处理搜索条件
        if (isset($get['keyword']) && $get['keyword'] != '') {
            $keyword = $this->validateInput($get['keyword']);
            $filters['keyword'] = $keyword;
            Session::set('transfer_filters', $filters);
        } else {
            $filters = null;
            Session::delete('transfer_filters');
        }
        
        // 处理状态筛选
        if (isset($get['status']) && $get['status'] != '') {
            $status = intval($get['status']);
            if ($filters === null) {
                $filters = [];
            }
            $filters['status'] = $status;
            Session::set('transfer_filters', $filters);
        }
        
        // 处理服务器筛选
        if (isset($get['source_server_id']) && $get['source_server_id'] != '') {
            $sourceServerId = intval($get['source_server_id']);
            if ($filters === null) {
                $filters = [];
            }
            $filters['source_server_id'] = $sourceServerId;
            Session::set('transfer_filters', $filters);
        }
        
        if (isset($get['target_server_id']) && $get['target_server_id'] != '') {
            $targetServerId = intval($get['target_server_id']);
            if ($filters === null) {
                $filters = [];
            }
            $filters['target_server_id'] = $targetServerId;
            Session::set('transfer_filters', $filters);
        }
        
        // 获取服务器列表（用于筛选）
        $serverModel = new Server();
        $servers = $serverModel->where('status', 1)
            ->order('id', 'asc')
            ->select();
        
        return view('transfer/transferlist', [
            'servers' => $servers
        ]);
    }
    
    /**
     * 获取转区申请表格数据
     */
    public function table()
    {
        $filters = Session::get('transfer_filters');
        $post = $this->request->post();
        
        $transferModel = new TransferModel();
        $result = $transferModel->getTransferList(
            $post['page'] ?? 1,
            $post['limit'] ?? 10,
            $filters
        );
        
        return jsonp($result);
    }
    
    /**
     * 转区申请详情页面
     */
    public function detail()
    {
        $id = $this->request->get('id', 0);
        
        if ($id <= 0) {
            return notify(0, '参数错误');
        }
        
        $transferModel = new TransferModel();
        $transfer = $transferModel->getTransferDetail($id);
        
        if (!$transfer) {
            return notify(0, '转区申请不存在');
        }
        
        // 获取源服务器信息（source_server_id 存储的是 serverid，不是主键 id）
        $serverModel = new Server();
        $sourceServer = $serverModel->getServerId($transfer['source_server_id']);
        $targetServer = $serverModel->getServerId($transfer['target_server_id']);
        
        // 获取角色信息
        $bindModel = new Bind();
        $role = $bindModel->where('playerid', $transfer['role'])
            ->where('serverid', $transfer['source_server_id'])
            ->find();
        
        // 获取用户信息
        $userModel = new User();
        $user = $userModel->find($transfer['uid']);
        
        return view('transfer/detail', [
            'transfer' => $transfer,
            'sourceServer' => $sourceServer,
            'targetServer' => $targetServer,
            'role' => $role,
            'user' => $user
        ]);
    }
    
    /**
     * 审核通过
     */
    public function approve()
    {
        $id = $this->request->post('id', 0);
        $reply = trim($this->request->post('reply', ''));
        
        if ($id <= 0) {
            return notify(0, '参数错误');
        }
        
        $transferModel = new TransferModel();
        $transfer = $transferModel->getTransferDetail($id);
        
        if (!$transfer) {
            return notify(0, '转区申请不存在');
        }
        
        if ($transfer['status'] != TransferModel::STATUS_PENDING) {
            return notify(0, '该申请已处理，无法重复审核');
        }
        
        // 获取当前管理员ID（从BaseController的myAdmin中获取）
        $adminId = $this->myAdmin['id'] ?? 0;
        
        // 更新状态为审核通过
        $result = $transferModel->updateStatus(
            $id,
            TransferModel::STATUS_APPROVED,
            $adminId,
            $reply ?: '审核通过，正在准备转区'
        );
        
        if (!$result) {
            return notify(0, '审核失败');
        }
        
        return notify(1, '审核通过');
    }
    
    /**
     * 审核拒绝
     */
    public function reject()
    {
        $id = $this->request->post('id', 0);
        $reply = trim($this->request->post('reply', ''));
        
        if ($id <= 0) {
            return notify(0, '参数错误');
        }
        
        if (empty($reply)) {
            return notify(0, '请填写拒绝原因');
        }
        
        $transferModel = new TransferModel();
        $transfer = $transferModel->getTransferDetail($id);
        
        if (!$transfer) {
            return notify(0, '转区申请不存在');
        }
        
        if ($transfer['status'] != TransferModel::STATUS_PENDING) {
            return notify(0, '该申请已处理，无法重复审核');
        }
        
        // 获取当前管理员ID（从BaseController的myAdmin中获取）
        $adminId = $this->myAdmin['id'] ?? 0;
        
        // 更新状态为审核拒绝
        $result = $transferModel->updateStatus(
            $id,
            TransferModel::STATUS_REJECTED,
            $adminId,
            $reply
        );
        
        if (!$result) {
            return notify(0, '拒绝失败');
        }
        
        return notify(1, '已拒绝该转区申请');
    }
    
    /**
     * 开始处理转区
     */
    public function process()
    {
        $id = $this->request->post('id', 0);
        // 验证 CSRF Token
        if (!$this->checkToken($this->request->post('csrf_token', ''))) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        
        if ($id <= 0) {
            return notify(0, '参数错误');
        }
        
        $transferModel = new TransferModel();
        $transfer = $transferModel->getTransferDetail($id);
        
        if (!$transfer) {
            return notify(0, '转区申请不存在');
        }
        
        if ($transfer['status'] != TransferModel::STATUS_APPROVED) {
            return notify(0, '该申请未通过审核，无法处理');
        }
        
        // 获取当前管理员ID（从BaseController的myAdmin中获取）
        $adminId = $this->myAdmin['id'] ?? 0;
        
        // 更新状态为处理中
        $result = $transferModel->updateStatus(
            $id,
            TransferModel::STATUS_PROCESSING,
            $adminId,
            '开始处理转区'
        );
        
        if (!$result) {
            return notify(0, '操作失败');
        }
        
        return notify(1, '已开始处理转区');
    }
    
    /**
     * 完成转区
     */
    public function complete()
    {
        $id = $this->request->post('id', 0);
        // 验证 CSRF Token
        if (!$this->checkToken($this->request->post('csrf_token', ''))) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        
        if ($id <= 0) {
            return notify(0, '参数错误');
        }
        
        $transferModel = new TransferModel();
        $transfer = $transferModel->getTransferDetail($id);
        
        if (!$transfer) {
            return notify(0, '转区申请不存在');
        }
        
        if ($transfer['status'] != TransferModel::STATUS_PROCESSING) {
            return notify(0, '该申请未在处理中');
        }
        
        // 调用转区执行服务
        $transferService = new \app\service\TransferExecutionService();
        $result = $transferService->executeTransfer($id);
        
        if (!$result['success']) {
            return notify(0, '转区失败：' . $result['message']);
        }
        
        return notify(1, '转区成功，目标角色ID：' . $result['target_role_id']);
    }
    
    /**
     * 自动执行转区
     */
    public function autoExecute()
    {
        $id = $this->request->post('id', 0);
        // 验证 CSRF Token
        if (!$this->checkToken($this->request->post('csrf_token', ''))) {
            return notify(0, '非法请求：CSRF令牌无效');
        }
        
        if ($id <= 0) {
            return notify(0, '参数错误');
        }
        
        // 检查申请状态，必须为「处理中」才允许执行
        $transferModel = new TransferModel();
        $transfer = $transferModel->getTransferDetail($id);
        
        if (!$transfer) {
            return notify(0, '转区申请不存在');
        }
        
        if ($transfer['status'] != TransferModel::STATUS_PROCESSING) {
            return notify(0, '该申请未在处理中，无法执行自动转区');
        }
        
        $transferService = new \app\service\TransferExecutionService();
        $result = $transferService->executeTransfer($id);
        
        if ($result['success']) {
            return notify(1, '转区成功', ['target_role_id' => $result['target_role_id']]);
        } else {
            return notify(0, $result['message']);
        }
    }
}
