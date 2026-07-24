<?php /*a:1:{s:53:"/www/wwwroot/web_app/app/player/view/index/index.html";i:1772303836;}*/ ?>
<!DOCTYPE html>
<html lang="zh-CN">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
        content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="csrf-token" content="<?php echo $csrf_token ?? ''; ?>">
    <meta name="theme-color" content="#007bff">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <title>玩家服务中心</title>
    <link rel="stylesheet" href="/static/player/css/think-style.css">
    <link rel="stylesheet" href="/static/template/css/materialdesignicons.min.css">
</head>

<body class="player-index-page">
    <div class="lyear-layout">
        <!-- 侧滑导航菜单 -->
        <div class="lyear-sidebar-overlay" id="sidebarOverlay"></div>
        <aside class="lyear-sidebar" id="sidebar">
            <div class="lyear-sidebar-header">
                <div class="avatar">
                    <i class="mdi mdi-account-circle"></i>
                </div>
                <div class="username">
                    <?php echo htmlspecialchars($player['username'] ?? '游客'); ?>
                </div>
                <div class="user-info">UID:
                    <?php echo $player['display_uid'] ?? '-'; ?>
                </div>
            </div>

            <nav class="lyear-sidebar-nav">
                <div class="lyear-sidebar-nav-group">主菜单</div>
                <a href="/player/index" class="lyear-sidebar-nav-item active">
                    <i class="mdi mdi-home"></i>
                    <span>首页</span>
                </a>
                <a href="/player/recharge" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-cash"></i>
                    <span>充值中心</span>
                </a>
                <a href="/player/order" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-file-document"></i>
                    <span>订单记录</span>
                </a>
                <a href="/player/role" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-account-box"></i>
                    <span>角色管理</span>
                </a>

                <div class="lyear-sidebar-nav-group">账户</div>
                <a href="/player/profile" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-account-edit"></i>
                    <span>个人资料</span>
                </a>
                <a href="/player/server" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-server"></i>
                    <span>服务器列表</span>
                </a>
                <a href="/player/feedback" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-message-text"></i>
                    <span>问题反馈</span>
                </a>
                <a href="/player/transfer" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-swap-horizontal"></i>
                    <span>转区申请</span>
                </a>
                <a href="/player/service" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-headset"></i>
                    <span>客服中心</span>
                </a>

                <div class="lyear-sidebar-nav-group">其他</div>
                <?php if(empty($player)): ?>
                <a href="/player/auth/login" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-login"></i>
                    <span>登录</span>
                </a>
                <a href="/player/auth/register" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-account-plus"></i>
                    <span>注册</span>
                </a>
                <a href="/player/cdk/index" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-key"></i>
                    <span>CDK授权</span>
                </a>
                <?php else: ?>
                <a href="/player/auth/logout" class="lyear-sidebar-nav-item">
                    <i class="mdi mdi-logout"></i>
                    <span>退出登录</span>
                </a>
                <?php endif; ?>
            </nav>
        </aside>

        <button class="mobile-fab-menu" id="floatingMenuBtn" aria-label="打开侧边菜单">
            <i class="mdi mdi-menu"></i>
        </button>

        <!-- 顶部导航 -->
        <nav class="lyear-navbar">
            <button class="lyear-navbar-toggle" id="sidebarToggle">
                <i class="mdi mdi-menu"></i>
            </button>
            <div class="lyear-navbar-brand">
                <i class="mdi mdi-gamepad-variant"></i>
                <span>玩家服务中心</span>
            </div>
            <div class="lyear-navbar-right">
                <a href="/player/profile" style="color: var(--bs-body-color);">
                    <i class="mdi mdi-account-circle" style="font-size: 24px;"></i>
                </a>
            </div>
        </nav>

        <!-- 主内容区 -->
        <main class="lyear-content">
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
            <?php endif; if(empty($player)): ?>
            <!-- 未登录状态 -->
            <div class="card">
                <div class="card-body" style="text-align: center; padding: 30px 20px;">
                    <i class="mdi mdi-account-circle" style="font-size: 56px; color: #dee2e6;"></i>
                    <h3 style="margin: 16px 0 8px; font-size: 18px; color: #333;">您还未登录</h3>
                    <p style="color: #6c757d; margin-bottom: 20px; font-size: 14px;">请先登录或使用CDK授权进入游戏</p>
                    <div class="btn-group" style="justify-content: center;">
                        <a href="/player/auth/login" class="btn btn-primary">
                            <i class="mdi mdi-login"></i> 账号登录
                        </a>
                        <a href="/player/cdk/index" class="btn btn-success">
                            <i class="mdi mdi-key"></i> CDK授权
                        </a>
                    </div>
                    <div style="margin-top: 16px;">
                        <a href="/player/auth/register" style="color: var(--bs-primary); font-size: 14px;">
                            <i class="mdi mdi-account-plus"></i> 没有账号？立即注册
                        </a>
                    </div>
                </div>
            </div>
            <?php else: ?>
            <!-- 快捷功能 4×4 网格 -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title"><i class="mdi mdi-flash"></i> 快捷功能</h3>
                </div>
                <div class="card-body">
                    <div class="quick-grid">
                        <!-- 功能1: 立即充值 -->
                        <a href="/player/recharge" class="quick-grid-item">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #ff6b6b 0%, #ee5a5a 100%);">
                                <i class="mdi mdi-cash"></i>
                            </div>
                            <span>立即充值</span>
                        </a>
                        <!-- 功能2: 订单记录 -->
                        <a href="/player/order" class="quick-grid-item">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                                <i class="mdi mdi-file-document"></i>
                            </div>
                            <span>订单记录</span>
                        </a>
                        <!-- 功能3: 角色管理 -->
                        <a href="/player/role" class="quick-grid-item">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
                                <i class="mdi mdi-account-box"></i>
                            </div>
                            <span>角色管理</span>
                        </a>
                        <!-- 功能4: 个人资料 -->
                        <a href="/player/profile" class="quick-grid-item">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);">
                                <i class="mdi mdi-account-edit"></i>
                            </div>
                            <span>个人资料</span>
                        </a>
                        <!-- 功能5: 服务器 -->
                        <a href="/player/server" class="quick-grid-item">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%);">
                                <i class="mdi mdi-server"></i>
                            </div>
                            <span>服务器</span>
                        </a>
                        <!-- 功能6: 反馈 -->
                        <a href="/player/feedback" class="quick-grid-item">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);">
                                <i class="mdi mdi-message-text"></i>
                            </div>
                            <span>反馈</span>
                        </a>
                        <!-- 功能7: CDK -->
                        <a href="/player/cdk/index" class="quick-grid-item">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                                <i class="mdi mdi-key"></i>
                            </div>
                            <span>CDK</span>
                        </a>
                        <!-- 功能8: 转区 -->
                        <a href="/player/transfer" class="quick-grid-item">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                                <i class="mdi mdi-swap-horizontal"></i>
                            </div>
                            <span>转区</span>
                        </a>
                        <!-- 占位9 -->
                        <div class="quick-grid-item placeholder">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #5ee7df 0%, #b490ca 100%);">
                                <i class="mdi mdi-gift"></i>
                            </div>
                            <span>礼包</span>
                            <div class="coming-badge">即将开放</div>
                        </div>
                        <!-- 占位10 -->
                        <div class="quick-grid-item placeholder">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #c3cfe2 0%, #f5f7fa 100%);">
                                <i class="mdi mdi-trophy" style="color: #8e99a4;"></i>
                            </div>
                            <span>排行</span>
                            <div class="coming-badge">即将开放</div>
                        </div>
                        <!-- 占位11 -->
                        <div class="quick-grid-item placeholder">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%);">
                                <i class="mdi mdi-shopping"></i>
                            </div>
                            <span>商城</span>
                            <div class="coming-badge">即将开放</div>
                        </div>
                        <!-- 占位12 -->
                        <div class="quick-grid-item placeholder">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #fdfcfb 0%, #e2d1c3 100%);">
                                <i class="mdi mdi-calendar-star" style="color: #b8a48e;"></i>
                            </div>
                            <span>签到</span>
                            <div class="coming-badge">即将开放</div>
                        </div>
                        <!-- 占位13: 藏宝阁 -->
                        <div class="quick-grid-item placeholder">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);">
                                <i class="mdi mdi-treasure-chest"></i>
                            </div>
                            <span>藏宝阁</span>
                            <div class="coming-badge">即将开放</div>
                        </div>
                        <!-- 占位14 -->
                        <div class="quick-grid-item placeholder">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #a1c4fd 0%, #c2e9fb 100%);">
                                <i class="mdi mdi-forum" style="color: #4876a8;"></i>
                            </div>
                            <span>社区</span>
                            <div class="coming-badge">即将开放</div>
                        </div>
                        <!-- 占位15 -->
                        <div class="quick-grid-item placeholder">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #fddb92 0%, #d1fdff 100%);">
                                <i class="mdi mdi-help-circle" style="color: #a89050;"></i>
                            </div>
                            <span>帮助</span>
                            <div class="coming-badge">即将开放</div>
                        </div>
                        <!-- 占位16 -->
                        <div class="quick-grid-item placeholder">
                            <div class="quick-grid-icon"
                                style="background: linear-gradient(135deg, #e8e8e8 0%, #f5f5f5 100%);">
                                <i class="mdi mdi-dots-horizontal" style="color: #999;"></i>
                            </div>
                            <span>更多</span>
                            <div class="coming-badge">即将开放</div>
                        </div>
                    </div>
                </div>
            </div>
            <?php endif; ?>



            <!-- 公告区域 -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title"><i class="mdi mdi-bullhorn"></i> 公告</h3>
                </div>
                <div class="card-body">
                    <div class="notice-item">
                        <i class="mdi mdi-information" style="color: var(--bs-info);"></i>
                        <span>欢迎使用玩家服务中心，祝您游戏愉快！</span>
                    </div>
                </div>
            </div>
        </main>

        <!-- 移动端底部导航 -->
        <nav class="lyear-mobile-nav">
            <div class="lyear-mobile-nav-inner">
                <a href="javascript:void(0)" class="lyear-mobile-nav-item" id="mobileMenuNavBtn">
                    <i class="mdi mdi-menu"></i>
                    <span>菜单</span>
                </a>
                <a href="/player/index" class="lyear-mobile-nav-item active">
                    <i class="mdi mdi-home"></i>
                    <span>首页</span>
                </a>
                <a href="/player/recharge" class="lyear-mobile-nav-item">
                    <i class="mdi mdi-cash"></i>
                    <span>充值</span>
                </a>
                <a href="/player/order" class="lyear-mobile-nav-item">
                    <i class="mdi mdi-file-document"></i>
                    <span>订单</span>
                </a>
                <a href="/player/role" class="lyear-mobile-nav-item">
                    <i class="mdi mdi-account-box"></i>
                    <span>角色</span>
                </a>
                <a href="/player/profile" class="lyear-mobile-nav-item">
                    <i class="mdi mdi-account"></i>
                    <span>我的</span>
                </a>
            </div>
        </nav>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
    <script>
        (function () {
            var sidebar = document.getElementById('sidebar');
            var overlay = document.getElementById('sidebarOverlay');
            var toggle = document.getElementById('sidebarToggle');
            var floatingBtn = document.getElementById('floatingMenuBtn');
            var mobileMenuNavBtn = document.getElementById('mobileMenuNavBtn');

            function openSidebar() {
                if (!sidebar || !overlay) return;
                sidebar.classList.add('open');
                overlay.classList.add('show');
                document.body.style.overflow = 'hidden';
            }

            function closeSidebar() {
                if (!sidebar || !overlay) return;
                sidebar.classList.remove('open');
                overlay.classList.remove('show');
                document.body.style.overflow = '';
            }

            if (toggle) {
                toggle.addEventListener('click', function () {
                    if (sidebar.classList.contains('open')) {
                        closeSidebar();
                    } else {
                        openSidebar();
                    }
                });
            }

            if (floatingBtn) {
                floatingBtn.addEventListener('click', function () {
                    if (sidebar.classList.contains('open')) {
                        closeSidebar();
                    } else {
                        openSidebar();
                    }
                });
            }

            if (mobileMenuNavBtn) {
                mobileMenuNavBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    if (sidebar.classList.contains('open')) {
                        closeSidebar();
                    } else {
                        openSidebar();
                    }
                });
            }

            if (overlay) {
                overlay.addEventListener('click', closeSidebar);
            }

            document.addEventListener('swipeleft', function (e) {
                if (sidebar.classList.contains('open')) {
                    closeSidebar();
                }
            });

            var startX = 0;
            document.addEventListener('touchstart', function (e) {
                startX = e.touches[0].clientX;
            }, { passive: true });

            document.addEventListener('touchend', function (e) {
                var endX = e.changedTouches[0].clientX;
                var diff = endX - startX;

                if (diff > 80 && startX < 30) {
                    openSidebar();
                } else if (diff < -80 && sidebar.classList.contains('open')) {
                    closeSidebar();
                }
            }, { passive: true });
        })();
    </script>

    <style>
        /* ===== 账户信息紧凑横条 ===== */
        .account-info-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #fff;
            border-radius: var(--radius-md, 12px);
            padding: 14px 18px;
            margin-bottom: 16px;
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
        }

        .account-info-user {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .account-info-user i {
            font-size: 32px;
            color: var(--bs-primary);
        }

        .account-info-user span {
            font-weight: 600;
            font-size: 15px;
        }

        .account-info-user small {
            color: var(--bs-muted-color, #6c757d);
            font-size: 12px;
        }

        .account-info-stats {
            display: flex;
            gap: 20px;
        }

        .account-stat {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .account-stat-val {
            font-size: 16px;
            font-weight: 700;
            line-height: 1.2;
        }

        .account-stat-lbl {
            font-size: 11px;
            color: var(--bs-muted-color, #6c757d);
        }

        @media (max-width: 374px) {
            .account-info-bar {
                flex-direction: column;
                gap: 10px;
                text-align: center;
            }
        }

        .mobile-fab-menu {
            display: none;
            position: fixed;
            right: 14px;
            bottom: 68px;
            bottom: calc(68px + env(safe-area-inset-bottom));
            width: 46px;
            height: 46px;
            border: none;
            border-radius: 50%;
            background: var(--gradient-primary);
            color: #fff;
            box-shadow: 0 6px 18px rgba(0, 123, 255, 0.35);
            z-index: 1050;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        .mobile-fab-menu i {
            font-size: 24px;
            line-height: 1;
        }

        @media (max-width: 768px) {
            .mobile-fab-menu {
                display: flex !important;
            }
        }

        /* ===== 4×4 快捷功能网格 ===== */
        .quick-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 4px;
        }

        .quick-grid-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 14px 4px 10px;
            text-decoration: none;
            color: var(--bs-body-color);
            border-radius: 12px;
            transition: all 0.2s ease;
            position: relative;
            cursor: pointer;
        }

        .quick-grid-item:hover {
            background: rgba(var(--bs-primary-rgb), 0.06);
            transform: translateY(-2px);
        }

        .quick-grid-item:active {
            transform: scale(0.95);
        }

        .quick-grid-item.placeholder {
            cursor: default;
            opacity: 0.55;
        }

        .quick-grid-item.placeholder:hover {
            background: rgba(0, 0, 0, 0.02);
            transform: none;
        }

        .quick-grid-item.placeholder .quick-grid-icon {
            filter: saturate(0.4);
        }

        .quick-grid-icon {
            width: 46px;
            height: 46px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 22px;
            margin-bottom: 6px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.12);
            transition: box-shadow 0.2s ease;
        }

        .quick-grid-item:hover .quick-grid-icon {
            box-shadow: 0 5px 16px rgba(0, 0, 0, 0.18);
        }

        .quick-grid-item span {
            font-size: 12px;
            font-weight: 500;
            line-height: 1.2;
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 100%;
        }

        .coming-badge {
            position: absolute;
            top: 6px;
            right: 2px;
            font-size: 8px;
            padding: 1px 4px;
            border-radius: 6px;
            background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
            color: #fff;
            font-weight: 600;
            line-height: 1.4;
            white-space: nowrap;
            box-shadow: 0 1px 4px rgba(255, 154, 158, 0.4);
        }

        .notice-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px;
            background: #f8f9fa;
            border-radius: var(--radius-sm);
            font-size: 14px;
        }

        .notice-item i {
            font-size: 18px;
        }

        @media (max-width: 374px) {
            .quick-grid-icon {
                width: 40px;
                height: 40px;
                font-size: 19px;
                border-radius: 12px;
            }

            .quick-grid-item span {
                font-size: 11px;
            }

            .coming-badge {
                font-size: 7px;
                padding: 1px 3px;
            }
        }
    </style>
</body>

</html>
