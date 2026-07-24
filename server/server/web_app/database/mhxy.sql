-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2026-02-16 21:21:41
-- 服务器版本： 8.0.24
-- PHP 版本： 8.1.32

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `mhxy`
--

CREATE DATABASE IF NOT EXISTS `mhxy` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `mhxy`;

-- --------------------------------------------------------

--
-- 表的结构 `admin_account`
--

CREATE TABLE `admin_account` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `type` int NOT NULL DEFAULT '2',
  `lastagent` int NOT NULL DEFAULT '1',
  `lv` int NOT NULL DEFAULT '0',
  `qx` varchar(255) NOT NULL DEFAULT '0' COMMENT '权限',
  `agent_tree` varchar(255) DEFAULT '[0]',
  `fencheng` int NOT NULL DEFAULT '0',
  `invite` varchar(255) NOT NULL,
  `kefu` mediumtext,
  `wtime` date DEFAULT NULL,
  `wmoney` double(10,2) NOT NULL DEFAULT '0.00',
  `status` int NOT NULL DEFAULT '0',
  `direct_commission` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '直属玩家提成累计（70%）',
  `sub_commission` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '下级代理提成累计（5%+5%）',
  `total_commission` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '总提成（直属+下级）',
  `direct_player_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '直属玩家累计流水',
  `can_create_agent` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否可创建下级（0=否，1=是）',
  `pending_withdrawal` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '提现待审核金额',
  `withdrawal_apply_time` datetime DEFAULT NULL COMMENT '提现申请时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `admin_account`
--

INSERT INTO `admin_account` (`id`, `username`, `password`, `type`, `lastagent`, `lv`, `qx`, `agent_tree`, `fencheng`, `invite`, `kefu`, `wtime`, `wmoney`, `status`, `direct_commission`, `sub_commission`, `total_commission`, `direct_player_amount`, `can_create_agent`, `pending_withdrawal`, `withdrawal_apply_time`) VALUES
(1, 'admin188', '$2y$10$8ei0zus6fF13gCXUIEoxxeqFqIWzyIg25h5iz1aCJS6Xho3LsR2Cy', 1, 0, 0, '0', '[0]', 100, 'a888', NULL, NULL, 0.00, 1, 0.00, 0.00, 0.00, 0.00, 0, 0.00, NULL);

-- --------------------------------------------------------

--
-- 表的结构 `admin_log`
--

CREATE TABLE `admin_log` (
  `id` int NOT NULL,
  `username` varchar(50) DEFAULT NULL COMMENT '管理员用户名',
  `info` mediumtext COMMENT '操作信息',
  `date` varchar(255) DEFAULT NULL COMMENT '日期',
  `time` varchar(255) DEFAULT NULL COMMENT '时间',
  `ip` varchar(255) DEFAULT NULL COMMENT 'IP地址',
  `city` varchar(255) DEFAULT NULL COMMENT '城市'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='管理员操作日志';

--
-- 转存表中的数据 `admin_log`
--

INSERT INTO `admin_log` (`id`, `username`, `info`, `date`, `time`, `ip`, `city`) VALUES
(8, 'admin188', 'GM操作 - 玩家GM操作', '2026-02-02 21:01:57', '1770037317', '27.23.189.170', '湖北省黄冈市-电信');

-- --------------------------------------------------------

--
-- 表的结构 `agent_commission`
--

CREATE TABLE `agent_commission` (
  `id` int NOT NULL COMMENT '主键ID',
  `order_id` int NOT NULL COMMENT '订单ID',
  `orderid` varchar(50) NOT NULL COMMENT '订单号',
  `agent_id` int NOT NULL COMMENT '代理ID',
  `commission_type` tinyint(1) NOT NULL COMMENT '佣金类型（1=直属玩家70%，2=一级下级5%，3=二级下级5%）',
  `order_amount` decimal(10,2) NOT NULL COMMENT '订单金额',
  `commission_rate` decimal(5,2) NOT NULL COMMENT '佣金比例（%）',
  `commission_amount` decimal(10,2) NOT NULL COMMENT '佣金金额',
  `from_agent_id` int DEFAULT NULL COMMENT '来源代理ID（如果是下级代理的订单）',
  `from_user_id` int DEFAULT NULL COMMENT '来源玩家ID（如果是直属玩家的订单）',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态（0=待结算，1=已结算，2=已取消）',
  `settlement_date` date DEFAULT NULL COMMENT '结算日期',
  `order_date` datetime NOT NULL COMMENT '订单日期',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代理佣金明细表';

-- --------------------------------------------------------

--
-- 表的结构 `agent_relation`
--

CREATE TABLE `agent_relation` (
  `id` int NOT NULL COMMENT '主键ID',
  `agent_id` int NOT NULL COMMENT '代理ID',
  `parent_id` int DEFAULT NULL COMMENT '直属上级代理ID（NULL表示顶级代理）',
  `level_1_parent` int DEFAULT NULL COMMENT '一级上级代理ID',
  `level_2_parent` int DEFAULT NULL COMMENT '二级上级代理ID',
  `level` int NOT NULL DEFAULT '1' COMMENT '代理层级（1=顶级，2=二级...）',
  `path` varchar(500) DEFAULT NULL COMMENT '代理路径（如：1,5,12,18）',
  `total_children` int NOT NULL DEFAULT '0' COMMENT '总下级数量',
  `direct_children` int NOT NULL DEFAULT '0' COMMENT '直属下级数量',
  `can_create_agent` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否可以创建下级（0=否，1=是）',
  `direct_player_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '直属玩家累计流水',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代理关系表';

-- --------------------------------------------------------

--
-- 表的结构 `cdks`
--

CREATE TABLE `cdks` (
  `id` int NOT NULL,
  `cdk` varchar(25) NOT NULL,
  `lv` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT '授权等级/类型',
  `qid` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '区服ID',
  `uid` int UNSIGNED NOT NULL DEFAULT '0' COMMENT '角色UID',
  `used_at` datetime DEFAULT NULL COMMENT '使用时间',
  `pass` varchar(64) NOT NULL DEFAULT '' COMMENT '授权密码',
  `username` varchar(255) DEFAULT NULL,
  `passwd` varchar(255) DEFAULT NULL,
  `status` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 表的结构 `ip_log`
--

CREATE TABLE `ip_log` (
  `id` int NOT NULL,
  `user` varchar(255) NOT NULL,
  `pwd` varchar(255) NOT NULL,
  `time` datetime NOT NULL,
  `ip` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 表的结构 `login_log`
--

CREATE TABLE `login_log` (
  `id` int NOT NULL,
  `ip` varchar(255) NOT NULL,
  `time` datetime NOT NULL,
  `user` varchar(255) NOT NULL,
  `pwd` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 表的结构 `main_charge_award`
--

CREATE TABLE `main_charge_award` (
  `id` int NOT NULL,
  `value` int NOT NULL DEFAULT '0',
  `info` longtext NOT NULL,
  `mailitem` longtext NOT NULL,
  `xianyu` int NOT NULL DEFAULT '0',
  `vip` int NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '0',
  `type` int NOT NULL DEFAULT '1' COMMENT '1是今日2是角色'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `main_charge_award`
--

INSERT INTO `main_charge_award` (`id`, `value`, `info`, `mailitem`, `xianyu`, `vip`, `status`, `type`) VALUES
(10, 100, '可获得奖励：仙玉100万.金币100万.随机人参果100枚.13级宝石6枚.钨金100枚.元宵100枚.神兜兜100枚', '680513|1', 0, 0, 1, 2),
(11, 200, '可获得奖励：仙玉100万.金币100万.随机人参果100枚.15级宝石6枚.钨金100枚.元宵100枚.神兜兜100枚', '680514|1', 0, 0, 1, 2),
(12, 500, '可获得奖励：仙玉300万.金币300万.随机人参果300枚.18级宝石6枚.钨金300枚.元宵300枚.神兜兜300枚', '680515|1', 0, 0, 1, 2),
(13, 1000, '可获得奖励：仙玉500万.金币500万.随机人参果500枚.20级宝石6枚.钨金500枚.元宵500枚.神兜兜500枚', '680516|1', 0, 0, 1, 2),
(14, 2000, '可获得奖励：仙玉1000万.金币1000万.随机人参果1000枚.22级宝石2枚.钨金1000枚.元宵1000枚.神兜兜1000枚', '680517|1', 0, 0, 1, 2),
(15, 4000, '可获得奖励：仙玉2000万.金币2000万.随机人参果1000枚.24级宝石2枚.钨金2000枚.元宵2000枚.神兜兜2000枚', '680518|1', 0, 0, 1, 2),
(16, 6000, '可获得奖励：仙玉2000万.金币2000万.随机人参果1000枚.26级宝石2枚.钨金2000枚.元宵2000枚.神兜兜2000枚', '680519|1', 0, 0, 1, 2),
(17, 8000, '可获得奖励：仙玉2000万.金币2000万.随机人参果1000枚.28级宝石2枚.钨金2000枚.元宵2000枚.神兜兜2000枚', '680520|1', 0, 0, 1, 2),
(18, 10000, '可获得奖励：仙玉2000万.金币2000万.随机人参果1000枚.30级宝石2枚.钨金2000枚.元宵2000枚.神兜兜2000枚', '680521|1', 0, 0, 1, 2),
(19, 50, '可获得奖励：仙玉50万.金币100万.全能人参果10枚.13级星辉石4枚.钨金100枚.符石碎片100枚.神兜兜100枚', '680522|1', 0, 0, 1, 1),
(20, 100, '可获得奖励：仙玉50万.金币100万.全能人参果10枚.15级星辉石4枚.钨金100枚.符石碎片100枚.神兜兜100枚', '680523|1', 0, 0, 1, 1),
(21, 200, '可获得奖励：仙玉100万.金币200万.全能人参果20枚.18级星辉石4枚.钨金200枚.符石碎片200枚.神兜兜200枚', '680524|1', 0, 0, 1, 1),
(22, 500, '可获得奖励：仙玉300万.金币600万.全能人参果60枚.20级星辉石4枚.钨金600枚.符石碎片600枚.神兜兜600枚', '680525|1', 0, 0, 1, 1),
(23, 1000, '可获得奖励：仙玉500万.金币1000万.全能人参果100枚.22级星辉石2枚.钨金1000枚.符石碎片1000枚.神兜兜1000枚', '680526|1', 0, 0, 1, 1),
(24, 2000, '可获得奖励：仙玉1000万.金币2000万.全能人参果200枚.24级星辉石2枚.钨金2000枚.符石碎片2000枚.神兜兜2000枚', '680527|1', 0, 0, 1, 1),
(25, 3000, '可获得奖励：仙玉1000万.金币2000万.全能人参果200枚.26级星辉石2枚.钨金2000枚.符石碎片2000枚.神兜兜2000枚', '680528|1', 0, 0, 1, 1),
(26, 4000, '可获得奖励：仙玉1000万.金币2000万.全能人参果200枚.28级星辉石2枚.钨金2000枚.符石碎片2000枚.神兜兜2000枚', '680529|1', 0, 0, 1, 1),
(27, 5000, '可获得奖励：仙玉1000万.金币2000万.全能人参果200枚.30级星辉石2枚.钨金2000枚.符石碎片2000枚.神兜兜2000枚', '680530|1', 0, 0, 1, 1);

-- --------------------------------------------------------

--
-- 表的结构 `main_config`
--

CREATE TABLE `main_config` (
  `keys` varchar(255) NOT NULL,
  `values` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `main_config`
--

INSERT INTO `main_config` (`keys`, `values`) VALUES
('agent_notice', '代理须知:开通梦西游代理.结账由给你开通后台的上级代理结算.结账时间为次日12时之24时之间.开通代理权限后.拒绝绝内卷，伤人伤己，老G保证，所有总代子代一视同仁，无任何活动外的折扣，所有代理和气生财。赚足你的点位，别搞小动作！\r\nGM会不定期的清理开通代理权限后.只开户不做事的代理.以上几点大家一起遵守，互相监督，打造公平游戏环境。祝大家财源广进！\r\n'),
('background', '/static/updata/back.jpg'),
('icon', '/static/updata/icon.png'),
('jiesuan', '2026-02-07'),
('logo', '/static/updata/logo.png'),
('name', '追梦西游畅玩'),
('server_title', '{\r\n    \"GameConfigInfo\": {\r\n        \"GameId\": \"88\",\r\n        \"GameName\": \"mh\",\r\n        \"PatchUrl\": \"114.66.45.48\",\r\n        \"UpdateUrl\": \"114.66.45.48:88\",\r\n        \"ShareUrl\": \"http://114.66.45.48:88\",\r\n        \"IsAuth\": \"http://114.66.45.48:88\",\r\n        \"PlayerInfoUrl\": \"114.66.45.48:88\",\r\n        \"ChatUrl\": \"http://114.66.45.48:88\",\r\n        \"CommunityUrl\": \"114.66.45.48:88\",\r\n        \"NoticeUrl\": \"http://114.66.45.48:88/server/notice.php\",\r\n        \"ConfigUrl\": \"114.66.45.48:88\",\r\n        \"ServerInfoUrl\": \"114.66.45.48:88\",\r\n        \"JingLingUrl\": \"114.66.45.48:88\",\r\n        \"KongJianUrl\": \"114.66.45.48:88\",\r\n        \"HorseRaceUrl\": \"114.66.45.48:88\",\r\n        \"MoreGameSwitch\": \"请选择……\",\r\n        \"MoreGameUrl\": \"\",\r\n        \"MoreGameVersion\": \"\",\r\n        \"ServerMaxIndex\": \"4\"\r\n    },\r\n    \"GameAdInfo\": \"\"\r\n}'),
('tencent_asr_client', 'a:3:{s:9:\"secret_id\";s:36:\"AKID32ymS1PbbOzqUt1tWu2va0HNHzTj2FF1\";s:10:\"secret_key\";s:32:\"ynhU2MTM0Oo9G7jsyxlQo0Yv4xa4KM9h\";s:6:\"region\";s:12:\"ap-guangzhou\";}');

-- --------------------------------------------------------

--
-- 表的结构 `main_item`
--

CREATE TABLE `main_item` (
  `id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `itemid` int NOT NULL DEFAULT '0',
  `type` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 表的结构 `main_pay_channel`
--

CREATE TABLE `main_pay_channel` (
  `id` int NOT NULL,
  `channel` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `pay_api` varchar(255) NOT NULL,
  `pay_pid` varchar(255) NOT NULL,
  `pay_key` varchar(255) NOT NULL,
  `wxpay` int NOT NULL DEFAULT '0',
  `alipay` int NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `main_pay_channel`
--

INSERT INTO `main_pay_channel` (`id`, `channel`, `name`, `pay_api`, `pay_pid`, `pay_key`, `wxpay`, `alipay`, `status`) VALUES
(1, 'epay', '测试', 'http://sange.xlhnb.cn/', '10152', '', 1, 1, 1),
(2, 'epay', '测试', 'http://43.248.140.10/', '800809733', '', 1, 1, 1);

-- --------------------------------------------------------

--
-- 表的结构 `main_pay_item`
--

CREATE TABLE `main_pay_item` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `icon` varchar(255) NOT NULL,
  `price` int NOT NULL COMMENT '价格',
  `daylimit` int NOT NULL COMMENT '每日限购0不限制',
  `rolelimit` int NOT NULL DEFAULT '0' COMMENT '角色限购0不限制',
  `info` longtext NOT NULL COMMENT '介绍',
  `mailinfo` longtext NOT NULL COMMENT '邮件物品',
  `xianyu` int NOT NULL DEFAULT '0',
  `vip` int NOT NULL DEFAULT '0',
  `effect` varchar(255) NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '0' COMMENT '状态',
  `beishu` int NOT NULL DEFAULT '0' COMMENT '翻倍标签'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `main_item`
--

INSERT INTO `main_pay_item` (`id`, `name`, `icon`, `price`, `daylimit`, `rolelimit`, `info`, `mailinfo`, `xianyu`, `vip`, `effect`, `status`, `beishu`) VALUES
(1, '超值梦幻月卡', 'set:itemicon50 image:1802', 1, 0, 0, '购买后邮件发货月卡道具#在福利菜单月卡奖励使用#每日获得超多仙玉等道具', '337034|1', 0, 0, '0', 1, 0),
(2, '20元十倍礼包', 'set:jiangli image:6', 20, 0, 0, '2026新年充值活动礼包#该礼包可获得二百万仙玉#并获得对应200万V经验.', '340716|1', 0, 0, '0', 1, 0),
(3, '50元十倍礼包', 'set:jiangli image:6', 50, 0, 0, '2026新年充值活动礼包#该礼包可获得五百万仙玉#并获得对应500万V经验.', '340717|1', 0, 0, '0', 1, 0),
(4, '100元十倍礼包', 'set:jiangli image:8', 100, 0, 0, '2026新年充值活动礼包#该礼包可获得一千万仙玉#并获得对应1000万V经验.', '340718|1', 0, 0, '0', 1, 0),
(5, '200元十倍礼包', 'set:jiangli image:8', 200, 0, 0, '2026新年充值活动礼包#该礼包可获得二千万仙玉#并获得对应2000万V经验.', '340719|1', 0, 0, '0', 1, 0),
(6, '388元特惠神宠', 'set:jiangli image:8', 388, 0, 0, '2026新年活动神兽礼包#25成长宠物1只.千叶4枚#神兜兜6千枚.元宵6万枚#神兽丹2百.V经验3880万', '340723|1', 0, 0, '0', 1, 0),
(7, '500元十倍礼包', 'set:jiangli image:8', 500, 0, 0, '2026新年充值活动礼包#该礼包可获得五千万仙玉#并获得对应5000万V经验', '340720|1', 0, 0, '0', 1, 0),
(8, '1000元十倍礼包', 'set:jiangli image:8', 1000, 0, 0, '2026新年充值活动礼包#该礼包可获得一个亿仙玉#并获得对应一个亿V经验', '340721|1', 0, 0, '0', 1, 0),
(9, '2000元十倍礼包', 'set:jiangli image:8', 2000, 0, 0, '2026新年充值活动礼包#该礼包可获得二个亿仙玉#并获得对应二个亿V经验', '340722|1', 0, 0, '0', 1, 0);

-- --------------------------------------------------------

--
-- 表的结构 `main_server`
--

CREATE TABLE `main_server` (
  `id` int NOT NULL,
  `groupname` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `serverip` varchar(255) NOT NULL,
  `serverport` int NOT NULL,
  `gmport` int NOT NULL,
  `serverid` int NOT NULL,
  `opentime` varchar(255) NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deng` int NOT NULL,
  `biao` int NOT NULL,
  `gmlocal` int NOT NULL,
  `charge` int NOT NULL,
  `xianyu` int NOT NULL,
  `vip` int NOT NULL,
  `notice` mediumtext,
  `status` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `main_server`
--

INSERT INTO `main_server` (`id`, `groupname`, `name`, `serverip`, `serverport`, `gmport`, `serverid`, `opentime`, `deng`, `biao`, `gmlocal`, `charge`, `xianyu`, `vip`, `notice`, `status`) VALUES
(1, '追梦西游', '追梦1区', '43.248.140.10', 42001, 41001, 1000000001, '2025年07月18日', 0, 3, 1, 1, 1, 1, '0', 1);

-- --------------------------------------------------------

--
-- 表的结构 `role`
--

CREATE TABLE `role` (
  `roleid` bigint NOT NULL COMMENT '角色ID',
  `name` varchar(50) NOT NULL COMMENT '角色名称',
  `avatar` int NOT NULL DEFAULT '0' COMMENT '角色头像/外观ID',
  `level` int NOT NULL DEFAULT '1' COMMENT '角色等级',
  `userid` int DEFAULT NULL COMMENT '关联的用户ID',
  `profession` int DEFAULT NULL COMMENT '职业',
  `createtime` bigint DEFAULT NULL COMMENT '创建时间',
  `lastlogintime` bigint DEFAULT NULL COMMENT '最后登录时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='游戏角色表';

-- --------------------------------------------------------

--
-- 表的结构 `role_relation`
--

CREATE TABLE `role_relation` (
  `roleid` bigint NOT NULL COMMENT '角色ID',
  `friendid` bigint NOT NULL COMMENT '好友角色ID',
  `relation` varchar(10) NOT NULL DEFAULT 'u0001' COMMENT '关系类型',
  `createtime` bigint DEFAULT NULL COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色好友关系表';

-- --------------------------------------------------------

--
-- 表的结构 `user_account`
--

CREATE TABLE `user_account` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `lastagent` int NOT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `zhiboqu` int NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '1',
  `bidserver` longtext,
  `login_ip` varchar(255) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `user_account`
--

INSERT INTO `user_account` (`id`, `username`, `password`, `lastagent`, `platform`, `zhiboqu`, `status`, `bidserver`, `login_ip`) VALUES
(1, 'www123', '$2y$10$.sds7bbLRZO0KRm2k1wYfuTup6tz4qOIx8uBI.UmkZxEN3no5Kt1S', 1, '', 0, 1, NULL, '27.23.189.170');

-- --------------------------------------------------------

--
-- 表的结构 `user_agentjs`
--

CREATE TABLE `user_agentjs` (
  `id` int NOT NULL,
  `uid` int NOT NULL,
  `time` date NOT NULL,
  `money` double(10,2) NOT NULL,
  `start` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 表的结构 `user_bind`
--

CREATE TABLE `user_bind` (
  `id` int NOT NULL,
  `userid` int NOT NULL,
  `serverid` int NOT NULL,
  `playerid` int NOT NULL,
  `playername` varchar(255) NOT NULL,
  `charge` decimal(10,2) NOT NULL DEFAULT '0.00',
  `fb_sc` int NOT NULL DEFAULT '0',
  `zhuanqu` int NOT NULL DEFAULT '0',
  `lq_daycharge` longtext,
  `lq_rolecharge` longtext,
  `daycharge` decimal(10,2) NOT NULL DEFAULT '0.00',
  `chargedate` varchar(255) DEFAULT '0',
  `rolelimit` longtext,
  `daylimit` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `user_bind`
--

INSERT INTO `user_bind` (`id`, `userid`, `serverid`, `playerid`, `playername`, `charge`, `fb_sc`, `zhuanqu`, `lq_daycharge`, `lq_rolecharge`, `daycharge`, `chargedate`, `rolelimit`, `daylimit`) VALUES
(1, 1, 1000000001, 4097, '周立轩', 0.00, 0, 0, NULL, NULL, 0.00, '0', NULL, NULL);

-- --------------------------------------------------------

--
-- 表的结构 `user_black_ip`
--

CREATE TABLE `user_black_ip` (
  `id` int NOT NULL,
  `ip` varchar(255) NOT NULL,
  `info` varchar(255) NOT NULL DEFAULT '未定义'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 表的结构 `user_fankui`
--

CREATE TABLE `user_fankui` (
  `id` int NOT NULL,
  `role` int NOT NULL DEFAULT '0',
  `info` longtext,
  `time` varchar(255) DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `uid` int NOT NULL DEFAULT '0' COMMENT '用户ID',
  `username` varchar(50) DEFAULT NULL COMMENT '用户名',
  `source_server_id` int NOT NULL DEFAULT '0' COMMENT '源服务器ID',
  `target_server_id` int NOT NULL DEFAULT '0' COMMENT '目标服务器ID',
  `target_role_id` int NOT NULL DEFAULT '0' COMMENT '目标角色ID（转区后）',
  `target_role_name` varchar(100) DEFAULT NULL COMMENT '目标角色名称',
  `contact` varchar(255) DEFAULT NULL COMMENT '联系方式',
  `type` int NOT NULL DEFAULT '1' COMMENT '类型：1-反馈，2-转区申请',
  `reply` text COMMENT '管理员回复',
  `admin_id` int DEFAULT NULL COMMENT '处理管理员ID',
  `processed_at` datetime DEFAULT NULL COMMENT '处理时间',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
`updated_at` datetime DEFAULT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 表的结构 `user_log`
--

CREATE TABLE `user_log` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `info` mediumtext NOT NULL,
  `date` varchar(255) NOT NULL,
  `time` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `lv` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 转存表中的数据 `user_log`
--

INSERT INTO `user_log` (`id`, `username`, `info`, `date`, `time`, `ip`, `city`, `lv`) VALUES
(1, 'admin188', '清空所有玩家数据: 玩家账号(1条), 订单记录(1084条), 日志记录(30219条), ', '2026-02-02 21:39:22', '1770039562', '127.0.0.1', '本机', 3),
(2, 'www123', '成功注册账号', '2026-02-02 21:41:12', '1770039672', '27.23.189.170', '湖北省黄冈市-电信', 1),
(3, 'www123', '登录游戏客户端，使用设备：', '2026-02-02 21:41:15', '1770039675', '27.23.189.170', '湖北省黄冈市-电信', 1),
(4, 'www123', '登陆游戏', '2026-02-02 21:41:17', '1770039677', '127.0.0.1', '本地网络-本地保留地址', 1),
(5, 'www123', '登录游戏客户端，使用设备：', '2026-02-02 21:45:28', '1770039928', '27.23.189.170', '湖北省黄冈市-电信', 1),
(6, 'www123', '登陆游戏', '2026-02-02 21:45:31', '1770039931', '127.0.0.1', '本地网络-本地保留地址', 1),
(7, 'www123', '绑定新角色：{\"userid\":1,\"serverid\":\"1000000001\",\"playerid\":\"4097\",\"playername\":\"周立轩\"}', '2026-02-02 21:45:35', '1770039935', '127.0.0.1', '本地网络-本地保留地址', 1),
(8, 'admin188', '超级管理员登录成功（二次验证）- 账号:admin188, IP:119.102.0.112', '2026-02-07 18:07:38', '1770458858', '119.102.0.112', '湖北省武汉市-电信', 3),
(9, 'admin188', '登录后台中心', '2026-02-07 18:07:38', '1770458858', '119.102.0.112', '湖北省武汉市-电信', 3),
(10, 'admin188', '清空物品数据：删除记录数=1728', '2026-02-07 18:07:55', '1770458875', '119.102.0.112', '湖北省武汉市-电信', 3);

-- --------------------------------------------------------

--
-- 表的结构 `user_order`
--

CREATE TABLE `user_order` (
  `id` int NOT NULL,
  `orderid` varchar(255) NOT NULL,
  `agent` longtext NOT NULL,
  `ordertype` int NOT NULL DEFAULT '1',
  `user` longtext NOT NULL,
  `item` longtext NOT NULL,
  `channel` int NOT NULL,
  `paytype` varchar(255) NOT NULL,
  `realmoney` decimal(10,2) NOT NULL,
  `date` varchar(255) NOT NULL,
  `time` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `status` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 表的结构 `user_transfer`
--

CREATE TABLE `user_transfer` (
  `id` int NOT NULL COMMENT '主键ID',
  `uid` int NOT NULL DEFAULT '0' COMMENT '用户ID',
  `username` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户名',
  `role` int NOT NULL DEFAULT '0' COMMENT '源角色ID（转区前）',
  `source_server_id` int NOT NULL DEFAULT '0' COMMENT '源服务器ID',
  `target_server_id` int NOT NULL DEFAULT '0' COMMENT '目标服务器ID',
  `target_role_id` int NOT NULL DEFAULT '0' COMMENT '目标角色ID',
  `target_role_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '目标角色名称',
  `contact` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系方式',
  `reason` longtext COLLATE utf8mb4_unicode_ci COMMENT '转区原因',
  `type` int NOT NULL DEFAULT '2' COMMENT '类型：1-反馈，2-转区申请',
  `reply` text COLLATE utf8mb4_unicode_ci COMMENT '管理员回复',
  `admin_id` int DEFAULT NULL COMMENT '处理管理员ID',
  `status` int NOT NULL DEFAULT '0' COMMENT '状态：0-待审核，1-审核通过，2-审核拒绝，3-处理中，4-已完成',
  `processed_at` datetime DEFAULT NULL COMMENT '处理时间',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='转区申请表';

-- --------------------------------------------------------

--
-- 表的结构 `user_voice`
--

CREATE TABLE `user_voice` (
  `id` int NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `text` mediumtext NOT NULL,
  `channelid` varchar(255) NOT NULL,
  `time` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- 表的结构 `withdrawal_records`
--

CREATE TABLE `withdrawal_records` (
  `id` int NOT NULL COMMENT '主键ID',
  `agent_id` int NOT NULL COMMENT '代理ID',
  `agent_username` varchar(50) NOT NULL COMMENT '代理账号',
  `withdrawal_amount` decimal(10,2) NOT NULL COMMENT '提现金额',
  `direct_commission` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '直属玩家分成',
  `sub_commission` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '下级代理分成',
  `payment_method` varchar(200) DEFAULT NULL COMMENT '收款方式（支付宝/USDT）',
  `zfb_name` varchar(50) DEFAULT NULL COMMENT '支付宝姓名',
  `zfb_account` varchar(50) DEFAULT NULL COMMENT '支付宝账号',
  `usdt_address` varchar(200) DEFAULT NULL COMMENT 'USDT地址',
  `apply_time` datetime DEFAULT NULL COMMENT '申请时间（从pending_withdrawal转入时）',
  `settlement_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '结算时间（管理员审核时间）',
  `settlement_admin` varchar(50) DEFAULT NULL COMMENT '结算管理员账号',
  `settlement_admin_id` int DEFAULT NULL COMMENT '结算管理员ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态（1=已结算，2=已取消）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='提现结算记录表';

-- --------------------------------------------------------

--
-- 表的结构 `player_login_log`
--

CREATE TABLE `player_login_log` (
  `id` int NOT NULL COMMENT '主键ID',
  `user_id` int NOT NULL DEFAULT '0' COMMENT '用户ID',
  `username` varchar(50) DEFAULT NULL COMMENT '用户名',
  `ip` varchar(255) DEFAULT NULL COMMENT 'IP地址',
  `platform` varchar(50) DEFAULT 'web' COMMENT '平台',
  `user_agent` text COMMENT '用户代理',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态：1-成功，0-失败',
  `remark` text COMMENT '备注',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='玩家登录日志表';

-- --------------------------------------------------------

--
-- 表的结构 `player_profile`
--

CREATE TABLE `player_profile` (
  `id` int NOT NULL COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名',
  `gender` tinyint(1) DEFAULT NULL COMMENT '性别',
  `birthday` date DEFAULT NULL COMMENT '生日',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `qq` varchar(20) DEFAULT NULL COMMENT 'QQ号',
  `wechat` varchar(50) DEFAULT NULL COMMENT '微信号',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `remark` text COMMENT '备注',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='玩家个人资料表';

--
-- 转存表中的数据 `withdrawal_records`
--

INSERT INTO `withdrawal_records` (`id`, `agent_id`, `agent_username`, `withdrawal_amount`, `direct_commission`, `sub_commission`, `payment_method`, `zfb_name`, `zfb_account`, `usdt_address`, `apply_time`, `settlement_time`, `settlement_admin`, `settlement_admin_id`, `remark`, `status`) VALUES
(1, 96, 'a123456789', 4000.00, 0.00, 0.00, '支付宝：张三(18888888888)', '张三', '18888888888', '暂未设置', '2026-01-11 01:22:45', '2026-01-11 01:22:45', 'qwe1853579', 1, '撒大苏打', 1),
(2, 97, 'aaa123', 4000.00, 0.00, 0.00, '支付宝：张三(18888888888), USDT：暂未设置1', '张三', '18888888888', '暂未设置1', '2026-01-11 01:27:38', '2026-01-11 01:27:38', 'qwe1853579', 1, '', 1),
(3, 96, 'a123456789', 2000.00, 0.00, 0.00, '支付宝：张三(18888888888)', '张三', '18888888888', '暂未设置', '2026-01-11 01:27:38', '2026-01-11 01:27:38', 'qwe1853579', 1, '', 1);

--
-- 转储表的索引
--

--
-- 表的索引 `admin_account`
--
ALTER TABLE `admin_account`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_type_status` (`type`,`status`),
  ADD KEY `idx_lastagent` (`lastagent`),
  ADD KEY `idx_can_create` (`can_create_agent`);

--
-- 表的索引 `admin_log`
--
ALTER TABLE `admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_date` (`date`);

--
-- 表的索引 `agent_commission`
--
ALTER TABLE `agent_commission`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_id` (`order_id`),
  ADD KEY `idx_orderid` (`orderid`),
  ADD KEY `idx_agent_id` (`agent_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_settlement_date` (`settlement_date`),
  ADD KEY `idx_order_date` (`order_date`);

--
-- 表的索引 `agent_relation`
--
ALTER TABLE `agent_relation`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_agent_id` (`agent_id`),
  ADD KEY `idx_parent_id` (`parent_id`),
  ADD KEY `idx_level_1_parent` (`level_1_parent`),
  ADD KEY `idx_level_2_parent` (`level_2_parent`),
  ADD KEY `idx_can_create` (`can_create_agent`),
  ADD KEY `idx_path` (`path`(255));

--
-- 表的索引 `cdks`
--
ALTER TABLE `cdks`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `cdk` (`cdk`) USING BTREE;

--
-- 表的索引 `ip_log`
--
ALTER TABLE `ip_log`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `login_log`
--
ALTER TABLE `login_log`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `main_charge_award`
--
ALTER TABLE `main_charge_award`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `main_config`
--
ALTER TABLE `main_config`
  ADD PRIMARY KEY (`keys`),
  ADD UNIQUE KEY `keys` (`keys`),
  ADD UNIQUE KEY `keys_2` (`keys`);

--
-- 表的索引 `main_item`
--
ALTER TABLE `main_item`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `main_pay_channel`
--
ALTER TABLE `main_pay_channel`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `main_pay_item`
--
ALTER TABLE `main_pay_item`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `main_server`
--
ALTER TABLE `main_server`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`roleid`),
  ADD KEY `idx_userid` (`userid`),
  ADD KEY `idx_level` (`level`);

--
-- 表的索引 `role_relation`
--
ALTER TABLE `role_relation`
  ADD PRIMARY KEY (`roleid`,`friendid`),
  ADD KEY `idx_friendid` (`friendid`);

--
-- 表的索引 `user_account`
--
ALTER TABLE `user_account`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_lastagent` (`lastagent`),
  ADD KEY `idx_status` (`status`);

--
-- 表的索引 `user_agentjs`
--
ALTER TABLE `user_agentjs`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `user_bind`
--
ALTER TABLE `user_bind`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `user_black_ip`
--
ALTER TABLE `user_black_ip`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `player_login_log`
--
ALTER TABLE `player_login_log`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_ip` (`ip`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- 表的索引 `player_profile`
--
ALTER TABLE `player_profile`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `uk_user_id` (`user_id`),
  ADD KEY `idx_nickname` (`nickname`),
  ADD KEY `idx_phone` (`phone`);

--
-- 表的索引 `user_fankui`
--
ALTER TABLE `user_fankui`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_uid_type` (`uid`,`type`),
  ADD KEY `idx_type_status` (`type`,`status`),
  ADD KEY `idx_source_server` (`source_server_id`),
  ADD KEY `idx_target_server` (`target_server_id`);

--
-- 表的索引 `user_log`
--
ALTER TABLE `user_log`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `user_order`
--
ALTER TABLE `user_order`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `idx_status_date` (`status`,`date`(10));

--
-- 表的索引 `user_transfer`
--
ALTER TABLE `user_transfer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_uid` (`uid`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_source_target` (`source_server_id`,`target_server_id`);

--
-- 表的索引 `user_voice`
--
ALTER TABLE `user_voice`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- 表的索引 `withdrawal_records`
--
ALTER TABLE `withdrawal_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_agent_id` (`agent_id`),
  ADD KEY `idx_settlement_time` (`settlement_time`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_settlement_admin_id` (`settlement_admin_id`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `admin_account`
--
ALTER TABLE `admin_account`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;

--
-- 使用表AUTO_INCREMENT `admin_log`
--
ALTER TABLE `admin_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- 使用表AUTO_INCREMENT `agent_commission`
--
ALTER TABLE `agent_commission`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID', AUTO_INCREMENT=13;

--
-- 使用表AUTO_INCREMENT `agent_relation`
--
ALTER TABLE `agent_relation`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID', AUTO_INCREMENT=4;

--
-- 使用表AUTO_INCREMENT `cdks`
--
ALTER TABLE `cdks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `ip_log`
--
ALTER TABLE `ip_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1679;

--
-- 使用表AUTO_INCREMENT `login_log`
--
ALTER TABLE `login_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=215;

--
-- 使用表AUTO_INCREMENT `main_charge_award`
--
ALTER TABLE `main_charge_award`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- 使用表AUTO_INCREMENT `main_item`
--
ALTER TABLE `main_item`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1729;

--
-- 使用表AUTO_INCREMENT `main_pay_channel`
--
ALTER TABLE `main_pay_channel`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `main_pay_item`
--
ALTER TABLE `main_pay_item`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- 使用表AUTO_INCREMENT `main_server`
--
ALTER TABLE `main_server`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- 使用表AUTO_INCREMENT `user_account`
--
ALTER TABLE `user_account`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `user_agentjs`
--
ALTER TABLE `user_agentjs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- 使用表AUTO_INCREMENT `user_bind`
--
ALTER TABLE `user_bind`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `user_black_ip`
--
ALTER TABLE `user_black_ip`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `player_login_log`
--
ALTER TABLE `player_login_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

--
-- 使用表AUTO_INCREMENT `player_profile`
--
ALTER TABLE `player_profile`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

--
-- 使用表AUTO_INCREMENT `user_fankui`
--
ALTER TABLE `user_fankui`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `user_log`
--
ALTER TABLE `user_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- 使用表AUTO_INCREMENT `user_order`
--
ALTER TABLE `user_order`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `user_transfer`
--
ALTER TABLE `user_transfer`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID';

--
-- 使用表AUTO_INCREMENT `user_voice`
--
ALTER TABLE `user_voice`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `withdrawal_records`
--
ALTER TABLE `withdrawal_records`
  MODIFY `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID', AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
