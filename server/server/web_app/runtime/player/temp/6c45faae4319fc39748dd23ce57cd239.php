<?php /*a:2:{s:51:"/www/wwwroot/web_app/app/player/view/role/list.html";i:1772303836;s:53:"/www/wwwroot/web_app/app/player/view/layout/base.html";i:1772303836;}*/ ?>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="csrf-token" content="<?php echo $csrf_token ?? ''; ?>">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <title>角色管理 - 玩家服务中心</title>
    <link rel="stylesheet" href="/static/player/css/think-style.css">
    <link rel="stylesheet" href="/static/template/css/materialdesignicons.min.css">
    
<style>
    @media (max-width: 767px) {
        .attr-item {
            padding: 10px 8px !important;
        }

        .attr-item>div:first-child {
            font-size: 18px !important;
        }
    }
</style>

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
            <span class="mobile-header-title">角色管理</span>
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
            <?php endif; if(!(empty($roles) || (($roles instanceof \think\Collection || $roles instanceof \think\Paginator ) && $roles->isEmpty()))): if(is_array($roles) || $roles instanceof \think\Collection || $roles instanceof \think\Paginator): $i = 0; $__LIST__ = $roles;if( count($__LIST__)==0 ) : echo "" ;else: foreach($__LIST__ as $key=>$role): $mod = ($i % 2 );++$i;?>
<!-- 角色卡片 -->
<div class="card">
    <div class="card-body">
        <div class="role-card" style="margin: 0; background: transparent; padding: 0;">
            <!-- 角色头像和基本信息 -->
            <div style="display: flex; align-items: center; gap: 16px;">
                <div class="role-avatar" style="width: 64px; height: 64px; font-size: 28px;">
                    <i class="mdi mdi-account"></i>
                </div>
                <div class="role-info" style="flex: 1;">
                    <div class="role-name" style="font-size: 18px;">
                        <?php echo htmlentities(htmlspecialchars((isset($role['playername']) && ($role['playername'] !== '')?$role['playername']:'未知角色'))); ?>
                    </div>
                    <div class="role-detail">
                        <i class="mdi mdi-server"></i> 服务器ID: <?php echo htmlentities(htmlspecialchars((isset($role['serverid']) && ($role['serverid'] !== '')?$role['serverid']:'-'))); if(!(empty($role['charge']) || (($role['charge'] instanceof \think\Collection || $role['charge'] instanceof \think\Paginator ) && $role['charge']->isEmpty()))): ?>
                        <span style="margin: 0 8px; color: var(--bs-border-color);">|</span>
                        <span style="color: var(--bs-success); font-weight: 500;">充值:
                            ¥<?php echo htmlentities(htmlspecialchars($role['charge'])); ?></span>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <!-- 角色属性数据 -->
            <?php if(!(empty($role['charge']) || (($role['charge'] instanceof \think\Collection || $role['charge'] instanceof \think\Paginator ) && $role['charge']->isEmpty()))): ?>
            <div style="margin-top: 16px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px;">
                <div class="attr-item"
                    style="text-align: center; padding: 12px; background: #f8f9fa; border-radius: 8px;">
                    <div style="font-size: 20px; font-weight: 700; color: var(--bs-primary);">
                        <?php echo htmlentities(htmlspecialchars((isset($role['playerid']) && ($role['playerid'] !== '')?$role['playerid']:'--'))); ?>
                    </div>
                    <div style="font-size: 12px; color: var(--bs-muted-color);">角色ID</div>
                </div>
                <div class="attr-item"
                    style="text-align: center; padding: 12px; background: #f8f9fa; border-radius: 8px;">
                    <div style="font-size: 20px; font-weight: 700; color: var(--bs-success);">
                        ¥<?php echo htmlentities(htmlspecialchars((isset($role['charge']) && ($role['charge'] !== '')?$role['charge']:'0'))); ?>
                    </div>
                    <div style="font-size: 12px; color: var(--bs-muted-color);">充值</div>
                </div>
                <div class="attr-item"
                    style="text-align: center; padding: 12px; background: #f8f9fa; border-radius: 8px;">
                    <?php if(!(empty($role['zhuanqu']) || (($role['zhuanqu'] instanceof \think\Collection || $role['zhuanqu'] instanceof \think\Paginator ) && $role['zhuanqu']->isEmpty()))): ?>
                    <div class="zhuanqu-status" style="font-size: 20px; font-weight: 700; color: var(--bs-warning);">
                        已转区
                    </div>
                    <?php else: ?>
                    <div class="zhuanqu-status"
                        style="font-size: 20px; font-weight: 700; color: var(--bs-muted-color);">
                        未转区
                    </div>
                    <?php endif; ?>
                    <div style="font-size: 12px; color: var(--bs-muted-color);">转区状态</div>
                </div>
            </div>
            <?php endif; ?>

            <!-- 操作按钮 -->
            <div
                style="margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--bs-border-color); display: flex; justify-content: space-between; align-items: center;">
                <span style="font-size: 12px; color: var(--bs-muted-color);">
                    <i class="mdi mdi-identifier"></i> ID: <?php echo htmlentities(htmlspecialchars($role['playerid'])); ?>
                </span>
                <div style="display: flex; gap: 8px;">
                    <a href="/player/role/detail?id=<?php echo htmlentities($role['playerid']); ?>" class="btn btn-sm btn-outline-primary">
                        <i class="mdi mdi-eye"></i> 详情
                    </a>
                    <a href="/player/recharge?role_id=<?php echo htmlentities($role['playerid']); ?>" class="btn btn-sm btn-primary">
                        <i class="mdi mdi-cash"></i> 充值
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
<?php endforeach; endif; else: echo "" ;endif; else: ?>
<!-- 空状态 -->
<div class="card">
    <div class="card-body">
        <div class="empty-state">
            <i class="mdi mdi-account-group"></i>
            <h4>暂无角色信息</h4>
            <p>请先登录游戏创建角色</p>
            <div style="margin-top: 20px; padding: 20px; background: #f8f9fa; border-radius: 12px; text-align: left;">
                <h5 style="margin: 0 0 12px; font-size: 14px; font-weight: 600;">
                    <i class="mdi mdi-lightbulb" style="color: var(--bs-warning);"></i> 如何创建角色？
                </h5>
                <ol
                    style="margin: 0; padding-left: 20px; font-size: 13px; color: var(--bs-muted-color); line-height: 1.8;">
                    <li>下载并安装游戏客户端</li>
                    <li>使用您的账号登录游戏</li>
                    <li>选择服务器并创建角色</li>
                    <li>返回此处查看角色信息</li>
                </ol>
            </div>
        </div>
    </div>
</div>
<?php endif; ?>

<!-- 角色统计 -->
<?php if(!(empty($roles) || (($roles instanceof \think\Collection || $roles instanceof \think\Paginator ) && $roles->isEmpty()))): ?>
<div class="card">
    <div class="card-header">
        <h3 class="card-title"><i class="mdi mdi-chart-bar"></i> 角色统计</h3>
    </div>
    <div class="card-body">
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">角色数量</div>
                <div class="info-value"><?php echo htmlentities(count($roles)); ?></div>
            </div>
            <div class="info-item">
                <div class="info-label">总充值额</div>
                <div class="info-value text-success">
                    ¥<?php echo htmlentities(htmlspecialchars((isset($totalCharge) && ($totalCharge !== '')?$totalCharge:'0'))); ?>
                </div>
            </div>
        </div>
    </div>
</div>
<?php endif; ?>

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
    
</body>

</html>
