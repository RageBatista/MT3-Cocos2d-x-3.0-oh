<?php /*a:2:{s:56:"/www/wwwroot/web_app/app/player/view/recharge/index.html";i:1772303836;s:53:"/www/wwwroot/web_app/app/player/view/layout/base.html";i:1772303836;}*/ ?>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="csrf-token" content="<?php echo $csrf_token ?? ''; ?>">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <title>充值中心 - 玩家服务中心</title>
    <link rel="stylesheet" href="/static/player/css/think-style.css">
    <link rel="stylesheet" href="/static/template/css/materialdesignicons.min.css">
    
</head>

<body>
    <!-- 侧滑遮罩 -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <!-- 侧滑抽屉导航 -->
    <div class="sidebar-drawer" id="sidebarDrawer">
        <div class="sidebar-user">
            <div class="sidebar-avatar">
                <?php if(!empty($player)): ?>
                <i class="mdi mdi-account"></i>
                <?php else: ?>
                <i class="mdi mdi-account-outline"></i>
                <?php endif; ?>
            </div>
            <?php if(!empty($player)): ?>
            <div class="sidebar-username">
                <?php echo htmlspecialchars($player['username'] ?? '玩家'); ?>
            </div>
            <div class="sidebar-uid">UID:
                <?php echo $player['display_uid'] ?? '-'; ?>
            </div>
            <?php else: ?>
            <div class="sidebar-username">未登录</div>
            <div class="sidebar-uid">请先登录账号</div>
            <?php endif; ?>
        </div>

        <ul class="sidebar-nav">
            <li><a href="/player/index" class="<?php if($controller == 'Index'): ?>active<?php endif; ?>"><i class="mdi mdi-home"></i>
                    首页</a></li>
            <?php if(empty($player)): ?>
            <li><a href="/player/auth/login" class="<?php if($controller == 'Auth'): ?>active<?php endif; ?>"><i class="mdi mdi-login"></i>
                    登录</a></li>
            <li><a href="/player/auth/register"><i class="mdi mdi-account-plus"></i> 注册</a></li>
            <?php else: ?>
            <li><a href="/player/recharge" class="<?php if($controller == 'Recharge'): ?>active<?php endif; ?>"><i
                        class="mdi mdi-cash"></i> 充值中心</a></li>
            <li><a href="/player/order" class="<?php if($controller == 'Order'): ?>active<?php endif; ?>"><i
                        class="mdi mdi-file-document"></i> 我的订单</a></li>
            <li><a href="/player/role" class="<?php if($controller == 'Role'): ?>active<?php endif; ?>"><i class="mdi mdi-account-box"></i>
                    角色管理</a></li>
            <li><a href="/player/server" class="<?php if($controller == 'Server'): ?>active<?php endif; ?>"><i class="mdi mdi-server"></i>
                    服务器</a></li>
            <li class="nav-divider"></li>
            <li><a href="/player/profile" class="<?php if($controller == 'Profile'): ?>active<?php endif; ?>"><i
                        class="mdi mdi-account-edit"></i> 个人资料</a></li>
            <li><a href="/player/transfer" class="<?php if($controller == 'Transfer'): ?>active<?php endif; ?>"><i
                        class="mdi mdi-swap-horizontal"></i> 转区申请</a></li>
            <li><a href="/player/feedback" class="<?php if($controller == 'Feedback'): ?>active<?php endif; ?>"><i
                        class="mdi mdi-message-text"></i> 意见反馈</a></li>
            <li><a href="/player/service" class="<?php if($controller == 'Service'): ?>active<?php endif; ?>"><i
                        class="mdi mdi-headset"></i> 客服中心</a></li>
            <?php endif; ?>
            <li class="nav-divider"></li>
            <li><a href="/player/cdk/index" class="<?php if($controller == 'Cdk'): ?>active<?php endif; ?>"><i class="mdi mdi-key"></i>
                    CDK授权</a></li>
        </ul>

        <?php if(!empty($player)): ?>
        <div class="sidebar-footer">
            <a href="/player/auth/logout"><i class="mdi mdi-logout"></i> 退出登录</a>
        </div>
        <?php endif; ?>
    </div>

    <div class="lyear-layout">
        <!-- 桌面端顶部导航 -->
        <nav class="lyear-navbar" id="mainNavbar">
            <div class="lyear-navbar-brand">
                <i class="mdi mdi-gamepad-variant"></i>
                玩家服务中心
            </div>
            <ul class="lyear-navbar-nav">
                <li><a href="/player/index" class="<?php if($controller == 'Index'): ?>active<?php endif; ?>"><i class="mdi mdi-home"></i>
                        首页</a></li>
                <?php if(empty($player)): ?>
                <li><a href="/player/auth/login" class="<?php if($controller == 'Auth'): ?>active<?php endif; ?>"><i
                            class="mdi mdi-login"></i> 登录</a></li>
                <li><a href="/player/auth/register"><i class="mdi mdi-account-plus"></i> 注册</a></li>
                <?php else: ?>
                <li><a href="/player/recharge" class="<?php if($controller == 'Recharge'): ?>active<?php endif; ?>"><i
                            class="mdi mdi-cash"></i> 充值</a></li>
                <li><a href="/player/order" class="<?php if($controller == 'Order'): ?>active<?php endif; ?>"><i
                            class="mdi mdi-file-document"></i> 订单</a></li>
                <li><a href="/player/role" class="<?php if($controller == 'Role'): ?>active<?php endif; ?>"><i
                            class="mdi mdi-account-box"></i> 角色</a></li>
                <li><a href="/player/transfer" class="<?php if($controller == 'Transfer'): ?>active<?php endif; ?>"><i
                            class="mdi mdi-swap-horizontal"></i> 转区</a></li>
                <li><a href="/player/profile" class="<?php if($controller == 'Profile'): ?>active<?php endif; ?>"><i
                            class="mdi mdi-account-edit"></i> 资料</a></li>
                <li><a href="/player/auth/logout"><i class="mdi mdi-logout"></i> 退出</a></li>
                <?php endif; ?>
                <li><a href="/player/cdk/index" class="<?php if($controller == 'Cdk'): ?>active<?php endif; ?>"><i class="mdi mdi-key"></i>
                        CDK</a></li>
            </ul>
        </nav>

        <!-- 移动端 Header -->
        <header class="mobile-header" id="mobileHeader">
            <button class="mobile-header-btn" id="menuOpenBtn" aria-label="打开菜单">
                <i class="mdi mdi-menu"></i>
            </button>
            <span class="mobile-header-title">充值中心</span>
            <button class="mobile-header-btn" style="visibility: hidden;">
                <i class="mdi mdi-dots-vertical"></i>
            </button>
        </header>

        <!-- 主内容区 -->
        <div class="lyear-content">
            <?php if(session('error')): ?>
            <div class="alert alert-danger">
                <i class="mdi mdi-alert-circle"></i>
                <?php echo htmlspecialchars(session('error')); ?>
            </div>
            <?php endif; if(session('success')): ?>
            <div class="alert alert-success">
                <i class="mdi mdi-check-circle"></i>
                <?php echo htmlspecialchars(session('success')); ?>
            </div>
            <?php endif; ?>

            
<!-- 选择充值金额 -->
<div class="card">
    <div class="card-header">
        <h3 class="card-title"><i class="mdi mdi-cash-multiple"></i> 选择充值金额</h3>
    </div>
    <div class="card-body">
        <div class="recharge-amounts">
            <?php if(!empty($pay_items)): foreach($pay_items as $vo): ?>
            <div class="recharge-amount-item" data-id="<?php echo (int)$vo['id']; ?>"
                data-amount="<?php echo (int)$vo['amount']; ?>"
                data-name="<?php echo htmlspecialchars($vo['name']); ?>">
                <div class="amount">¥
                    <?php echo (int)$vo['amount']; ?>
                </div>
                <div class="name">
                    <?php echo htmlspecialchars($vo['name']); ?>
                </div>
                <?php if(!empty($vo['bonus'])): ?>
                <div class="bonus">赠送
                    <?php echo htmlspecialchars($vo['bonus']); ?>
                </div>
                <?php endif; ?>
            </div>
            <?php endforeach; else: ?>
            <div class="recharge-amount-item" data-id="1" data-amount="6" data-name="6元宝">
                <div class="amount">¥6</div>
                <div class="name">6元宝</div>
            </div>
            <div class="recharge-amount-item" data-id="2" data-amount="30" data-name="30元宝">
                <div class="amount">¥30</div>
                <div class="name">30元宝</div>
                <div class="bonus">赠送5元宝</div>
            </div>
            <div class="recharge-amount-item" data-id="3" data-amount="68" data-name="68元宝">
                <div class="amount">¥68</div>
                <div class="name">68元宝</div>
                <div class="bonus">赠送15元宝</div>
            </div>
            <div class="recharge-amount-item" data-id="4" data-amount="128" data-name="128元宝">
                <div class="amount">¥128</div>
                <div class="name">128元宝</div>
                <div class="bonus">赠送30元宝</div>
            </div>
            <div class="recharge-amount-item" data-id="5" data-amount="328" data-name="328元宝">
                <div class="amount">¥328</div>
                <div class="name">328元宝</div>
                <div class="bonus">赠送80元宝</div>
            </div>
            <div class="recharge-amount-item" data-id="6" data-amount="648" data-name="648元宝">
                <div class="amount">¥648</div>
                <div class="name">648元宝</div>
                <div class="bonus">赠送200元宝</div>
            </div>
            <?php endif; ?>
        </div>

        <!-- 充值表单 -->
        <div id="rechargeForm"
            style="display: none; margin-top: 20px; padding-top: 20px; border-top: 1px solid var(--bs-border-color);">
            <h4 style="margin-bottom: 16px; font-size: 15px; font-weight: 600;">
                <i class="mdi mdi-clipboard-check"></i> 确认充值信息
            </h4>

            <div class="form-group">
                <label class="form-label"><i class="mdi mdi-server"></i> 选择服务器</label>
                <select class="form-control" name="server_id" id="serverSelect">
                    <option value="">请选择服务器</option>
                    <?php if(!empty($servers)): foreach($servers as $s): ?>
                    <option value="<?php echo (int)($s['serverid'] ?? 0); ?>">
                        <?php echo htmlspecialchars($s['name']); ?>
                    </option>
                    <?php endforeach; ?>
                    <?php endif; ?>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label"><i class="mdi mdi-account-box"></i> 选择角色</label>
                <select class="form-control" name="role_id" id="roleSelect">
                    <option value="">请先选择服务器</option>
                </select>
            </div>

            <div class="row">
                <div class="col-6">
                    <div class="form-group">
                        <label class="form-label">充值金额</label>
                        <input type="text" class="form-control" id="selectedAmount" readonly>
                    </div>
                </div>
                <div class="col-6">
                    <div class="form-group">
                        <label class="form-label">商品名称</label>
                        <input type="text" class="form-control" id="selectedName" readonly>
                    </div>
                </div>
            </div>

            <!-- 支付方式 -->
            <div class="form-group">
                <label class="form-label"><i class="mdi mdi-credit-card"></i> 支付方式</label>
                <div class="payment-methods">
                    <div class="payment-method-item wechat active" data-method="wechat">
                        <i class="mdi mdi-wechat"></i>
                        <span class="name">微信支付</span>
                    </div>
                    <div class="payment-method-item alipay" data-method="alipay">
                        <i class="mdi mdi-alpha-a-circle"></i>
                        <span class="name">支付宝</span>
                    </div>
                </div>
            </div>

            <button type="button" class="btn btn-primary btn-block btn-lg" id="submitRecharge">
                <i class="mdi mdi-check"></i> 确认充值
            </button>
        </div>
    </div>
</div>

<!-- 充值记录 -->
<div class="card">
    <div class="card-header">
        <h3 class="card-title"><i class="mdi mdi-history"></i> 充值记录</h3>
        <a href="/player/order" style="font-size: 13px; color: var(--bs-primary);">查看全部</a>
    </div>
    <div class="card-body" style="padding: 0;">
        <?php if(!empty($orders)): ?>
        <div class="order-list">
            <?php foreach($orders as $order): ?>
            <div class="order-item">
                <div class="order-info">
                    <div class="order-no">
                        <?php echo htmlspecialchars($order['order_no']); ?>
                    </div>
                    <div class="order-amount">¥
                        <?php echo htmlspecialchars($order['amount']); ?>
                    </div>
                    <div class="order-time">
                        <?php echo htmlspecialchars($order['create_time']); ?>
                    </div>
                </div>
                <?php if($order['status'] == 1): ?>
                <span class="order-status paid">已支付</span>
                <?php else: ?>
                <span class="order-status pending">待支付</span>
                <?php endif; ?>
            </div>
            <?php endforeach; ?>
        </div>
        <?php else: ?>
        <div class="empty-state">
            <i class="mdi mdi-receipt"></i>
            <h4>暂无充值记录</h4>
        </div>
        <?php endif; ?>
    </div>
</div>

        </div>

        <!-- 页脚 -->
        <footer class="lyear-footer">
            &copy; <?php echo htmlentities(''); ?> 玩家服务中心 · All rights reserved
        </footer>
    </div>

    <!-- Toast 容器 -->
    <div class="toast-container" id="toastContainer"></div>

    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"
        integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
    <script src="/static/template/js/popper.min.js"></script>
    <script src="/static/template/js/bootstrap.min.js"></script>
    <script>
        // ========== 侧滑导航 ==========
        var drawer = document.getElementById('sidebarDrawer');
        var overlay = document.getElementById('sidebarOverlay');
        var menuBtn = document.getElementById('menuOpenBtn');

        function openSidebar() {
            drawer.classList.add('active');
            overlay.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeSidebar() {
            drawer.classList.remove('active');
            overlay.classList.remove('active');
            document.body.style.overflow = '';
        }

        if (menuBtn) menuBtn.addEventListener('click', openSidebar);
        if (overlay) overlay.addEventListener('click', closeSidebar);

        // 滑动关闭
        var touchStartX = 0;
        if (drawer) {
            drawer.addEventListener('touchstart', function (e) {
                touchStartX = e.touches[0].clientX;
            }, { passive: true });
            drawer.addEventListener('touchend', function (e) {
                var dx = e.changedTouches[0].clientX - touchStartX;
                if (dx < -60) closeSidebar();
            }, { passive: true });
        }

        // ========== 导航栏滚动效果 ==========
        window.addEventListener('scroll', function () {
            var navbar = document.getElementById('mainNavbar');
            if (navbar) {
                if (window.scrollY > 10) {
                    navbar.classList.add('scrolled');
                } else {
                    navbar.classList.remove('scrolled');
                }
            }
        });

        // ========== Toast 通知函数 ==========
        function showToast(message, type) {
            type = type || 'info';
            var container = document.getElementById('toastContainer');
            var toast = document.createElement('div');
            toast.className = 'toast toast-' + type;
            var iconMap = {
                'success': 'mdi-check-circle',
                'error': 'mdi-alert-circle',
                'warning': 'mdi-alert',
                'info': 'mdi-information'
            };
            toast.innerHTML = '<i class="mdi ' + (iconMap[type] || 'mdi-information') + '"></i> ' + message;
            container.appendChild(toast);

            toast.addEventListener('click', function () {
                toast.classList.add('toast-out');
                setTimeout(function () { toast.remove(); }, 250);
            });

            setTimeout(function () {
                if (toast.parentNode) {
                    toast.classList.add('toast-out');
                    setTimeout(function () { toast.remove(); }, 250);
                }
            }, 3500);
        }

        // ========== 通用 AJAX 表单提交 ==========
        function ajaxSubmit(formSelector, options) {
            options = options || {};
            $(formSelector).on('submit', function (e) {
                e.preventDefault();
                var $form = $(this);
                var $btn = $form.find('button[type="submit"]');
                var originalText = $btn.html();
                $btn.prop('disabled', true).html('<i class="mdi mdi-loading mdi-spin"></i> 处理中...');

                $.post($form.attr('action'), $form.serialize(), function (res) {
                    if (res.code === 1) {
                        showToast(res.msg || '操作成功', 'success');
                        if (options.onSuccess) {
                            options.onSuccess(res);
                        } else if (options.redirect) {
                            setTimeout(function () {
                                window.location.href = options.redirect;
                            }, 600);
                        } else {
                            $btn.html('<i class="mdi mdi-check"></i> 成功');
                            setTimeout(function () {
                                $btn.prop('disabled', false).html(originalText);
                            }, 1500);
                        }
                    } else {
                        showToast(res.msg || '操作失败', 'error');
                        $btn.prop('disabled', false).html(originalText);
                    }
                }, 'json').fail(function () {
                    showToast('网络请求失败，请重试', 'error');
                    $btn.prop('disabled', false).html(originalText);
                });
            });
        }
    </script>
    
<script>
    // HTML 转义函数
    function escapeHtml(str) {
        var div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    var selectedItem = null;
    var selectedPayMethod = 'wechat';
    var csrfToken = $('meta[name="csrf-token"]').attr('content') || '';

    $('.recharge-amount-item').on('click', function () {
        $('.recharge-amount-item').removeClass('active');
        $(this).addClass('active');

        selectedItem = {
            id: $(this).data('id'),
            amount: $(this).data('amount'),
            name: $(this).data('name')
        };

        $('#selectedAmount').val('¥' + selectedItem.amount);
        $('#selectedName').val(selectedItem.name);
        $('#rechargeForm').slideDown(200);

        if (window.innerWidth <= 768) {
            setTimeout(function () {
                $('html, body').animate({ scrollTop: $('#rechargeForm').offset().top - 70 }, 300);
            }, 250);
        }
    });

    $('.payment-method-item').on('click', function () {
        $('.payment-method-item').removeClass('active');
        $(this).addClass('active');
        selectedPayMethod = $(this).data('method');
    });

    $('#serverSelect').on('change', function () {
        var serverId = $(this).val();
        if (!serverId) {
            $('#roleSelect').html('<option value="">请先选择服务器</option>');
            return;
        }

        $.get('/player/role/getByServer', { server_id: serverId }, function (res) {
            if (res.code === 1) {
                var options = '<option value="">请选择角色</option>';
                $.each(res.data, function (i, role) {
                    options += '<option value="' + escapeHtml(String(role.roleid)) + '">' + escapeHtml(role.name) + '</option>';
                });
                $('#roleSelect').html(options);
            } else {
                showToast(res.msg || '获取角色失败', 'error');
            }
        }, 'json');
    });

    $('#submitRecharge').on('click', function () {
        if (!selectedItem) { showToast('请选择充值商品', 'warning'); return; }
        var serverId = $('#serverSelect').val();
        var roleId = $('#roleSelect').val();
        if (!serverId) { showToast('请选择服务器', 'warning'); return; }
        if (!roleId) { showToast('请选择角色', 'warning'); return; }

        var $btn = $(this);
        $btn.prop('disabled', true).html('<i class="mdi mdi-loading mdi-spin"></i> 提交中...');

        $.post('/player/recharge/createOrder', {
            item_id: selectedItem.id,
            server_id: serverId,
            role_id: roleId,
            pay_channel: selectedPayMethod,
            csrf_token: csrfToken
        }, function (res) {
            if (res.code === 1) {
                showToast(res.msg || '订单创建成功', 'success');
                if (res.data && res.data.pay_url) {
                    setTimeout(function () { window.location.href = res.data.pay_url; }, 600);
                } else if (res.data && res.data.order_id) {
                    setTimeout(function () {
                        window.location.href = '/player/order/detail?id=' + encodeURIComponent(String(res.data.order_id));
                    }, 600);
                } else {
                    $btn.prop('disabled', false).html('<i class="mdi mdi-check"></i> 确认充值');
                }
            } else {
                showToast(res.msg || '操作失败', 'error');
                $btn.prop('disabled', false).html('<i class="mdi mdi-check"></i> 确认充值');
            }
        }, 'json').fail(function () {
            showToast('网络请求失败，请重试', 'error');
            $btn.prop('disabled', false).html('<i class="mdi mdi-check"></i> 确认充值');
        });
    });
</script>

</body>

</html>
