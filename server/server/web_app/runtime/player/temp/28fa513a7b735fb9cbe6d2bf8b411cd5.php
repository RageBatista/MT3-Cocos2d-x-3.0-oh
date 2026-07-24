<?php /*a:2:{s:55:"/www/wwwroot/web_app/app/player/view/profile/index.html";i:1772303836;s:53:"/www/wwwroot/web_app/app/player/view/layout/base.html";i:1772303836;}*/ ?>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="csrf-token" content="<?php echo $csrf_token ?? ''; ?>">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <title>个人资料 - 玩家服务中心</title>
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
            <span class="mobile-header-title">个人资料</span>
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

            
<!-- 基本信息 -->
<div class="card">
    <div class="card-header">
        <h3 class="card-title"><i class="mdi mdi-account-edit"></i> 基本信息</h3>
    </div>
    <div class="card-body">
        <form id="profileForm" method="post" action="/player/profile/update">
            <input type="hidden" name="csrf_token" value="<?php echo htmlentities($csrf_token); ?>">

            <div class="form-group">
                <label class="form-label">账号</label>
                <input type="text" class="form-control" value="<?php echo htmlentities((isset($player['username']) && ($player['username'] !== '')?$player['username']:'')); ?>" disabled>
            </div>

            <div class="form-group">
                <label class="form-label">邮箱</label>
                <input type="email" class="form-control" name="email" value="<?php echo htmlentities((isset($player['email']) && ($player['email'] !== '')?$player['email']:'')); ?>"
                    placeholder="请输入邮箱">
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label class="form-label">昵称</label>
                        <input type="text" class="form-control" name="nickname"
                            value="<?php echo htmlentities((isset($player['profile']['nickname']) && ($player['profile']['nickname'] !== '')?$player['profile']['nickname']:'')); ?>" placeholder="请输入昵称">
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group">
                        <label class="form-label">手机号</label>
                        <input type="text" class="form-control" name="phone" value="<?php echo htmlentities((isset($player['profile']['phone']) && ($player['profile']['phone'] !== '')?$player['profile']['phone']:'')); ?>"
                            placeholder="请输入手机号">
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">真实姓名</label>
                <input type="text" class="form-control" name="real_name" value="<?php echo htmlentities((isset($player['profile']['real_name']) && ($player['profile']['real_name'] !== '')?$player['profile']['real_name']:'')); ?>"
                    placeholder="请输入真实姓名（可选）">
            </div>

            <button type="submit" class="btn btn-primary btn-block">
                <i class="mdi mdi-content-save"></i> 保存修改
            </button>
        </form>
    </div>
</div>

<!-- 安全与设置 -->
<div class="card">
    <div class="card-header">
        <h3 class="card-title"><i class="mdi mdi-shield-lock"></i> 安全与设置</h3>
    </div>
    <div class="card-body" style="padding: 0;">
        <ul class="settings-list">
            <li>
                <a href="/player/profile/password" class="settings-item">
                    <div class="settings-left"><i class="mdi mdi-lock"></i> <span>修改密码</span></div>
                    <div class="settings-right">
                        <span>定期修改提高安全性</span>
                        <i class="mdi mdi-chevron-right"></i>
                    </div>
                </a>
            </li>
            <li>
                <a href="/player/profile/avatar" class="settings-item">
                    <div class="settings-left"><i class="mdi mdi-camera"></i> <span>更换头像</span></div>
                    <div class="settings-right">
                        <i class="mdi mdi-chevron-right"></i>
                    </div>
                </a>
            </li>
            <li>
                <div class="settings-item" style="cursor: not-allowed; opacity: 0.6;">
                    <div class="settings-left"><i class="mdi mdi-cellphone"></i> <span>绑定手机</span></div>
                    <div class="settings-right">
                        <span style="color: var(--bs-warning); font-size: 12px;">即将开放</span>
                        <i class="mdi mdi-chevron-right"></i>
                    </div>
                </div>
            </li>
        </ul>
    </div>
</div>

<!-- 退出登录 -->
<div style="padding: 0 0 20px;">
    <a href="/player/auth/logout" class="btn btn-outline-danger btn-block">
        <i class="mdi mdi-logout"></i> 退出登录
    </a>
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
    ajaxSubmit('#profileForm', {
        onSuccess: function (res) {
            setTimeout(function () { location.reload(); }, 800);
        }
    });
</script>

</body>

</html>
