<?php
declare(strict_types=1);

namespace app\player\controller;

use app\BaseController;
use app\model\Fankui as FeedbackModel;

/**
 * Feedback控制器 - 反馈控制器
 * 处理玩家反馈提交和查看
 */
class Feedback extends BaseController
{
    /**
     * 反馈列表
     */
    public function index()
    {
        $player = $this->ensurePlayer();
        if (!$player) {
            return redirect('/player/auth/login');
        }

        $page = $this->request->param('page', 1, 'intval');
        $limit = $this->request->param('limit', 20, 'intval');

        $roles = $this->resolvePlayerRoles($player);
        $playerIds = array_values(array_filter(array_map('intval', array_column($roles, 'playerid'))));

        $list = [];
        $total = 0;
        if (!empty($playerIds)) {
            $feedbackModel = new FeedbackModel();
            $list = $feedbackModel->whereIn('role', $playerIds)
                ->order('id', 'desc')
                ->page($page, $limit)
                ->select();

            $total = $feedbackModel->whereIn('role', $playerIds)->count();
        }

        return view('feedback/index', [
            'feedbacks' => $list,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'pages' => $total > 0 ? ceil($total / $limit) : 0,
            'player' => $player,
            'roles' => $roles,
            'csrf_token' => $this->request->csrf_token ?? generateCsrfToken()
        ]);
    }

    /**
     * 提交反馈
     */
    public function submit()
    {
        $post = $this->request->post();

        $csrfToken = $post['csrf_token'] ?? '';
        if (!verifyCsrfToken($csrfToken)) {
            return notify(0, 'CSRF验证失败');
        }

        $player = $this->ensurePlayer();
        if (!$player) {
            return notify(0, '请先登录');
        }

        $content = trim($post['content'] ?? '');
        $roleId = intval($post['role'] ?? 0);

        if ($content === '') {
            return notify(0, '反馈内容不能为空');
        }
        if (mb_strlen($content) < 10) {
            return notify(0, '反馈内容至少需要10个字符');
        }
        if (mb_strlen($content) > 500) {
            return notify(0, '反馈内容不能超过500个字符');
        }
        if ($roleId <= 0) {
            return notify(0, '请选择角色');
        }

        $roles = $this->resolvePlayerRoles($player);
        $allowedRoleIds = array_values(array_filter(array_map('intval', array_column($roles, 'playerid'))));
        if (!in_array($roleId, $allowedRoleIds, true)) {
            return notify(0, '角色不存在');
        }

        $feedbackData = [
            'role' => $roleId,
            'info' => $content,
            'time' => date('Y-m-d H:i:s')
        ];

        try {
            $feedbackModel = new FeedbackModel();
            $feedbackModel->insFankui($feedbackData);
        } catch (\Exception $e) {
            return notify(0, '反馈提交失败');
        }

        if (function_exists('logPlayerAction')) {
            logPlayerAction($player['id'], 'submit_feedback', '提交反馈', [
                'role' => $roleId,
                'content_length' => mb_strlen($content)
            ]);
        }

        return notify(1, '反馈提交成功，我们会尽快处理');
    }

    /**
     * 转换为视图可直接使用的角色结构
     */
    private function resolvePlayerRoles(array $player): array
    {
        $roles = $this->resolveAccessibleRoles($player);
        $result = [];
        foreach ($roles as $role) {
            $playerId = intval($role['playerid'] ?? 0);
            if ($playerId <= 0) {
                continue;
            }
            $result[] = [
                'playerid' => $playerId,
                'playername' => (string)($role['playername'] ?? ('角色' . $playerId)),
                'serverid' => intval($role['serverid'] ?? 0),
            ];
        }
        return $result;
    }
}

