<?php
namespace app\index\controller;

use think\Request;
use think\facade\Db;
use think\facade\View;
use app\model\PayChannel as PC;
use app\api\pay\EpayCore;

class Cdk
{
    // 用户使用CDK页面
    public function index()
    {
        return View::fetch('cdk/index');
    }

    // 用户提交兑换
    public function redeem(Request $request)
    {
        $cdk = trim((string)$request->post('cdk', ''));
        $uid = (int)$request->post('uid', 0);
        $qid = (int)$request->post('qid', 0);

        if ($cdk === '') {
            return json(['code' => 0, 'msg' => '请输入有效的CDK']);
        }
        if ($uid <= 0) {
            return json(['code' => 0, 'msg' => '请输入有效的角色UID']);
        }
        if ($qid <= 0) {
            return json(['code' => 0, 'msg' => '请输入有效的区服QID']);
        }

        try {
            // 查找CDK
            $row = Db::table('cdks')->where('cdk', $cdk)->find();
            if (!$row) {
                return json(['code' => 0, 'msg' => 'CDK不存在']);
            }
            if ((int)$row['status'] === 1) {
                return json(['code' => 0, 'msg' => '该CDK已被使用']);
            }

            // 更新为已使用，并记录使用时间与绑定信息
            $affected = Db::table('cdks')
                ->where('id', (int)$row['id'])
                ->update([
                    'status'  => 1,
                    'uid'     => $uid,
                    'qid'     => $qid,
                    'used_at' => date('Y-m-d H:i:s'),
                ]);

            if ($affected === false) {
                return json(['code' => 0, 'msg' => '兑换失败，请稍后重试']);
            }

            return json([
                'code' => 1,
                'msg'  => '兑换成功',
                'data' => [
                    'id'      => (int)$row['id'],
                    'cdk'     => $row['cdk'],
                    'lv'      => (int)($row['lv'] ?? 0),
                    'uid'     => $uid,
                    'qid'     => $qid,
                    'used_at' => date('Y-m-d H:i:s'),
                ],
            ]);
        } catch (\Throwable $e) {
            return json(['code' => 0, 'msg' => '服务器异常：' . $e->getMessage()]);
        }
    }

    public function buy()
    {
        // 价格档位，与 pay() 校验保持一致
        $prices = [28];
        $siteName = config('app.app_name') ?: 'CDK授权';
        return View::fetch('cdk/buy', ['prices' => $prices, 'siteName' => $siteName]);
    }

    public function pay()
    {
        $money   = (int)request()->post('money', 0);
        $paytype = request()->post('paytype', 'alipay'); // alipay | wxpay

        if (!in_array($money, [28], true)) {
            return json(['code' => 0, 'msg' => '不支持的金额档位']);
        }
        if (!in_array($paytype, ['alipay', 'wxpay'], true)) {
            return json(['code' => 0, 'msg' => '不支持的支付方式']);
        }

        $pay = new PC();
        $channels = $pay->getAllPayList([
            ['channel', '=', 'epay'],
            [$paytype, '=', 1],
            ['status', '=', 1],
        ]);
        if (!$channels) {
            return json(['code' => 0, 'msg' => '暂无可用支付通道']);
        }
        $channel = $channels[array_rand($channels)];

        $orderid = 'cdk' . date('YmdHis') . mt_rand(10000, 99999);
        $host = input('server.REQUEST_SCHEME') . '://' . input('server.HTTP_HOST');

        // 写入 user_order（订单中心可见）
        $userArr = json_encode([
            'username'   => 'CDK购买',
            'servername' => '',
            'playername' => '',
            'playerid'   => 0,
        ], JSON_UNESCAPED_UNICODE);
        $itemArr = json_encode([
            'id'    => 0,
            'name'  => 'CDK授权',
            'price' => $money,
        ], JSON_UNESCAPED_UNICODE);

        // 注意：这里默认归属到管理员ID 1（根管理员）。如果你的管理员ID不是1，请改成“X|@X@”
        $orderdata = [
            'orderid'   => $orderid,
            'agent'     => '1|@1@',
            'ordertype' => 2, // CDK购买
            'user'      => $userArr,
            'item'      => $itemArr,
            'channel'   => $channel['id'],
            'paytype'   => $paytype,
            'realmoney' => $money,
            'date'      => date('Y-m-d'),
            'time'      => time(),
            'ip'        => request()->ip() ?: '0.0.0.0',
            'city'      => 'unknown',
            'status'    => 0,
        ];
        (new \app\model\UserOrder())->addOrder($orderdata);

        $epay_config = [
            'apiurl' => $channel['pay_api'],
            'pid'    => $channel['pay_pid'],
            'key'    => $channel['pay_key'],
        ];
        $parameter = [
            'pid'          => $epay_config['pid'],
            'type'         => $paytype,
            'notify_url'   => $host . '/index.php?s=/api/call/epayCdk',
            'return_url'   => $host . '/index.php?s=/api/notify/epayCdk',
            'out_trade_no' => $orderid,
            'name'         => 'CDK授权',
            'money'        => $money,
        ];

        $epay = new EpayCore($epay_config);
        $payUrl = $epay->getPayLink($parameter);
        if (!$payUrl) {
            return json(['code' => 0, 'msg' => '获取支付链接失败']);
        }
        // 返回订单号，便于后台和前台查询
        return json(['code' => 1, 'url' => base64_encode($payUrl), 'orderid' => $orderid]);
    }
}