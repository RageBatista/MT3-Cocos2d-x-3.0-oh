<?php /*a:1:{s:52:"/www/wwwroot/web_app/app/admin/view/index/index.html";i:1777196143;}*/ ?>
<!DOCTYPE html>
<html lang="zh">

<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
  <meta name="author" content="yinq">
  <title><?php echo htmlentities($config['name']); ?></title>
  <link rel="shortcut icon" type="image/x-icon" href="<?php echo htmlentities($config['icon']); ?>">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-touch-fullscreen" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="default">
  <link rel="stylesheet" type="text/css" href="/static/template/css/materialdesignicons.min.css">
  <link rel="stylesheet" type="text/css" href="/static/template/css/bootstrap.min.css">
  <link rel="stylesheet" type="text/css" href="/static/template/css/animate.min.css">
  <link rel="stylesheet" type="text/css" href="/static/template/js/bootstrap-multitabs/multitabs.min.css">
  <link rel="stylesheet" type="text/css" href="/static/template/css/style.min.css">
</head>

<body class="lyear-index">
  <div class="lyear-layout-web">
    <div class="lyear-layout-container">
      <!--左侧导航-->
      <aside class="lyear-layout-sidebar">

        <!-- logo -->
        <div id="logo" class="sidebar-header">
          <a href="index.html"><img src="<?php echo htmlentities($config['logo']); ?>" /></a>
        </div>
        <div class="lyear-layout-sidebar-info lyear-scroll">

          <nav class="sidebar-main">

            <ul class="nav-drawer">
              <li class="nav-item active">
                <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/index/worker" id="default-page">
                  <i class="mdi mdi-home-city-outline"></i>
                  <span>后台首页</span>
                </a>
              </li>
              <li class="nav-item nav-item-has-subnav">
                <a href="javascript:void(0)">
                  <i class="mdi mdi-television-guide"></i>
                  <span>代理中心</span>
                </a>
                <ul class="nav nav-subnav">
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/agent/list">代理列表</a> </li>
                  <li> <a class="multitabs"
                      href="/index.php?s=/<?php echo htmlentities($app); ?>/agent/list&username=&invite=&lv=<?php echo htmlentities($myAdmin['lv'] + 1); ?>">直属下级</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/agent/jiesuanlist">结算列表</a> </li>
                </ul>
              </li>
              <li class="nav-item nav-item-has-subnav">
                <a href="javascript:void(0)">
                  <i class="mdi mdi-cash-multiple"></i>
                  <span>结算功能</span>
                </a>
                <ul class="nav nav-subnav">
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/settlement/index">结算审核</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/settlement/records">结算记录</a> </li>
                </ul>
              </li>
              <li class="nav-item nav-item-has-subnav">
                <a href="javascript:void(0)">
                  <i class="mdi mdi-television-guide"></i>
                  <span>玩家中心</span>
                </a>
                <ul class="nav nav-subnav">
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/player/list">玩家列表</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/player/roleList">角色管理</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/player/bindList">绑定列表</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/player/voiceList">语音列表</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/transfer/list">转区申请</a> </li>
                </ul>
              </li>
              <li class="nav-item nav-item-has-subnav">
                <a href="javascript:void(0)">
                  <i class="mdi mdi-card-bulleted-outline"></i>
                  <span>订单中心</span>
                </a>
                <ul class="nav nav-subnav">
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/order/list/status/all">订单列表</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/order/list/status/yes">已支付</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/order/list/status/tuikuan">已退款</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/order/list/status/no">未支付</a> </li>
                </ul>
              </li>
              <li class="nav-item nav-item-has-subnav">
                <a href="javascript:void(0)">
                  <i class="mdi mdi-card-bulleted-outline"></i>
                  <span>GM工具</span>
                </a>
                <ul class="nav nav-subnav">
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/gm/player">玩家操作</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/gm/server_cmd">服务器操作</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/gm/server_mail">全服邮件</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/gm/cdk">CDK管理</a> </li>
                </ul>
              </li>
              <li class="nav-item nav-item-has-subnav">
                <a href="javascript:void(0)">
                  <i class="mdi mdi-stove"></i>
                  <span>运营管理</span>
                </a>
                <ul class="nav nav-subnav">
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/item/itemList">物品同步</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/configure/serverConfig">区服配置</a> </li>
                  <!-- ===== 支付配置：超级管理员不显示 ===== -->
                  <?php if($myAdmin['id'] != 1): ?>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/configure/payConfig">支付配置</a> </li>
                  <?php endif; ?>
                  <!-- ===== 支付配置菜单项结束 ===== -->
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/configure/sysConfig">系统配置</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/configure/noticeConfig">客户端公告</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/gm/cleanData"><span style="color: #ff6b6b;">⚠
                        清理数据</span></a> </li>
                </ul>
              </li>
              <li class="nav-item nav-item-has-subnav">
                <a href="javascript:void(0)">
                  <i class="mdi mdi-map-search-outline"></i>
                  <span>日志中心</span>
                </a>
                <ul class="nav nav-subnav">
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/log/userLog/type/3">后台日志</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/log/userLog/type/2">代理日志</a> </li>
                  <li> <a class="multitabs" href="/index.php?s=/<?php echo htmlentities($app); ?>/log/userLog/type/1">玩家日志</a> </li>
                </ul>
              </li>
            </ul>
          </nav>

          <div class="sidebar-footer">
            <p class="copyright">
              <!-- <span>Copyright &copy; 2022. </span> -->
              <!-- <a target="_blank" href="http://www.bixiaguangnian.com">笔下光年</a> -->
              <span><?php echo htmlentities($config['name']); ?></span>
            </p>
          </div>
        </div>

      </aside>
      <!--End 左侧导航-->

      <!--头部信息-->
      <header class="lyear-layout-header">

        <nav class="navbar">

          <div class="navbar-left">
            <div class="lyear-aside-toggler">
              <span class="lyear-toggler-bar"></span>
              <span class="lyear-toggler-bar"></span>
              <span class="lyear-toggler-bar"></span>
            </div>
          </div>

          <ul class="navbar-right d-flex align-items-center">
            <!--顶部消息部分-->
            <!-- <li class="dropdown dropdown-notice"> -->
            <!-- <span data-bs-toggle="dropdown" class="position-relative icon-item"> -->
            <!-- <i class="mdi mdi-bell-outline fs-5"></i> -->
            <!-- <span class="position-absolute translate-middle badge bg-danger">7</span> -->
            <!-- </span> -->
            <!-- <div class="dropdown-menu dropdown-menu-end"> -->
            <!-- <div class="lyear-notifications"> -->

            <!-- <div class="lyear-notifications-title d-flex justify-content-between" data-stopPropagation="true"> -->
            <!-- <span>你有 10 条未读消息</span> -->
            <!-- <a href="#!">查看全部</a> -->
            <!-- </div> -->
            <!-- <div class="lyear-notifications-info lyear-scroll"> -->
            <!-- <a href="#!" class="dropdown-item" -->
            <!-- title="树莓派销量猛增，疫情期间居家工作学习、医疗领域都需要它">树莓派销量猛增，疫情期间居家工作学习、医疗领域都需要它</a> -->
            <!-- <a href="#!" class="dropdown-item" -->
            <!-- title="GNOME 用户体验团队将为 GNOME Shell 提供更多改进">GNOME 用户体验团队将为 GNOME Shell -->
            <!-- 提供更多改进</a> -->
            <!-- <a href="#!" class="dropdown-item" -->
            <!-- title="Linux On iPhone 即将面世，支持 iOS 的双启动">Linux On iPhone 即将面世，支持 iOS -->
            <!-- 的双启动</a> -->
            <!-- <a href="#!" class="dropdown-item" title="GitHub 私有仓库完全免费面向团队提供">GitHub -->
            <!-- 私有仓库完全免费面向团队提供</a> -->
            <!-- <a href="#!" class="dropdown-item" -->
            <!-- title="Wasmtime 为 WebAssembly 增加 Go 语言绑定">Wasmtime 为 WebAssembly 增加 Go -->
            <!-- 语言绑定</a> -->
            <!-- <a href="#!" class="dropdown-item" -->
            <!-- title="红帽借“订阅”成开源一哥，首创者 Cormier 升任总裁">红帽借“订阅”成开源一哥，首创者 Cormier 升任总裁</a> -->
            <!-- <a href="#!" class="dropdown-item" title="Zend 宣布推出两项 PHP 新产品">Zend 宣布推出两项 -->
            <!-- PHP 新产品</a> -->
            <!-- </div> -->

            <!-- </div> -->
            <!-- </div> -->
            <!-- </li> -->
            <!--End 顶部消息部分-->
            <!--切换主题配色-->
            <li class="dropdown dropdown-skin">
              <span data-bs-toggle="dropdown" class="icon-item">
                <i class="mdi mdi-palette fs-5"></i>
              </span>
              <ul class="dropdown-menu dropdown-menu-end" data-stopPropagation="true">
                <li class="lyear-skin-title">
                  <p>主题</p>
                </li>
                <li class="lyear-skin-li clearfix">
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="site_theme" id="site_theme_1" value="default"
                      checked="checked">
                    <label class="form-check-label" for="site_theme_1"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="site_theme" id="site_theme_2"
                      value="translucent-green">
                    <label class="form-check-label" for="site_theme_2"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="site_theme" id="site_theme_3"
                      value="translucent-blue">
                    <label class="form-check-label" for="site_theme_3"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="site_theme" id="site_theme_4"
                      value="translucent-yellow">
                    <label class="form-check-label" for="site_theme_4"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="site_theme" id="site_theme_5"
                      value="translucent-red">
                    <label class="form-check-label" for="site_theme_5"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="site_theme" id="site_theme_6"
                      value="translucent-pink">
                    <label class="form-check-label" for="site_theme_6"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="site_theme" id="site_theme_7"
                      value="translucent-cyan">
                    <label class="form-check-label" for="site_theme_7"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="site_theme" id="site_theme_8" value="dark">
                    <label class="form-check-label" for="site_theme_8"></label>
                  </div>
                </li>
                <li class="lyear-skin-title">
                  <p>LOGO</p>
                </li>
                <li class="lyear-skin-li clearfix">
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="logo_bg" id="logo_bg_1" value="default"
                      checked="checked">
                    <label class="form-check-label" for="logo_bg_1"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="logo_bg" id="logo_bg_2" value="color_2">
                    <label class="form-check-label" for="logo_bg_2"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="logo_bg" id="logo_bg_3" value="color_3">
                    <label class="form-check-label" for="logo_bg_3"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="logo_bg" id="logo_bg_4" value="color_4">
                    <label class="form-check-label" for="logo_bg_4"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="logo_bg" id="logo_bg_5" value="color_5">
                    <label class="form-check-label" for="logo_bg_5"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="logo_bg" id="logo_bg_6" value="color_6">
                    <label class="form-check-label" for="logo_bg_6"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="logo_bg" id="logo_bg_7" value="color_7">
                    <label class="form-check-label" for="logo_bg_7"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="logo_bg" id="logo_bg_8" value="color_8">
                    <label class="form-check-label" for="logo_bg_8"></label>
                  </div>
                </li>
                <li class="lyear-skin-title">
                  <p>头部</p>
                </li>
                <li class="lyear-skin-li clearfix">
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="header_bg" id="header_bg_1" value="default"
                      checked="checked">
                    <label class="form-check-label" for="header_bg_1"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="header_bg" id="header_bg_2" value="color_2">
                    <label class="form-check-label" for="header_bg_2"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="header_bg" id="header_bg_3" value="color_3">
                    <label class="form-check-label" for="header_bg_3"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="header_bg" id="header_bg_4" value="color_4">
                    <label class="form-check-label" for="header_bg_4"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="header_bg" id="header_bg_5" value="color_5">
                    <label class="form-check-label" for="header_bg_5"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="header_bg" id="header_bg_6" value="color_6">
                    <label class="form-check-label" for="header_bg_6"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="header_bg" id="header_bg_7" value="color_7">
                    <label class="form-check-label" for="header_bg_7"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="header_bg" id="header_bg_8" value="color_8">
                    <label class="form-check-label" for="header_bg_8"></label>
                  </div>
                </li>
                <li class="lyear-skin-title">
                  <p>侧边栏</p>
                </li>
                <li class="lyear-skin-li clearfix">
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sidebar_bg" id="sidebar_bg_1" value="default"
                      checked="checked">
                    <label class="form-check-label" for="sidebar_bg_1"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sidebar_bg" id="sidebar_bg_2" value="color_2">
                    <label class="form-check-label" for="sidebar_bg_2"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sidebar_bg" id="sidebar_bg_3" value="color_3">
                    <label class="form-check-label" for="sidebar_bg_3"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sidebar_bg" id="sidebar_bg_4" value="color_4">
                    <label class="form-check-label" for="sidebar_bg_4"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sidebar_bg" id="sidebar_bg_5" value="color_5">
                    <label class="form-check-label" for="sidebar_bg_5"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sidebar_bg" id="sidebar_bg_6" value="color_6">
                    <label class="form-check-label" for="sidebar_bg_6"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sidebar_bg" id="sidebar_bg_7" value="color_7">
                    <label class="form-check-label" for="sidebar_bg_7"></label>
                  </div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sidebar_bg" id="sidebar_bg_8" value="color_8">
                    <label class="form-check-label" for="sidebar_bg_8"></label>
                  </div>
                </li>
              </ul>
            </li>
            <!--End 切换主题配色-->
            <!--个人头像内容-->
            <li class="dropdown">
              <a href="javascript:void(0)" data-bs-toggle="dropdown" class="dropdown-toggle">
                <!-- <img class="avatar-md rounded-circle" src="images/users/avatar.jpg" alt="笔下光年" /> -->
                <span style="margin-left: 10px;"><?php echo htmlentities($myAdmin['username']); ?></span>
              </a>
              <ul class="dropdown-menu dropdown-menu-end">
                <li>
                  <a class="multitabs dropdown-item" data-url="/index.php?s=/<?php echo htmlentities($app); ?>/index/my" href="javascript:void(0)">
                    <i class="mdi mdi-lock-outline"></i>
                    <span>修改信息</span>
                  </a>
                </li>
                <li class="dropdown-divider"></li>
                <li>
                  <a class="dropdown-item" href="/index.php?s=/<?php echo htmlentities($app); ?>/index/logout">
                    <i class="mdi mdi-logout-variant"></i>
                    <span>退出登录</span>
                  </a>
                </li>
              </ul>
            </li>
            <!--End 个人头像内容-->
          </ul>

        </nav>

      </header>
      <!--End 头部信息-->

      <!--页面主要内容-->
      <main class="lyear-layout-content">

        <div id="iframe-content"></div>

      </main>
      <!--End 页面主要内容-->
    </div>
  </div>

  <script type="text/javascript" src="/static/template/js/jquery.min.js"></script>
  <script type="text/javascript" src="/static/template/js/popper.min.js"></script>
  <script type="text/javascript" src="/static/template/js/bootstrap.min.js"></script>
  <script type="text/javascript" src="/static/template/js/perfect-scrollbar.min.js"></script>
  <script type="text/javascript" src="/static/template/js/bootstrap-multitabs/multitabs.min.js"></script>
  <script type="text/javascript" src="/static/template/js/jquery.cookie.min.js"></script>
  <script type="text/javascript" src="/static/template/js/index.min.js"></script>
  <script type="text/javascript">
    $(document).ready(function (e) { });
  </script>
</body>

</html>