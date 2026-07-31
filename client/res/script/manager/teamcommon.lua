require "utils.bit"
require "utils.tableutil"
require "utils.class"

------------------------------------------------------------------
--队伍一些常量定义

MAX_TEAMMEMBER	    = 5		--最大队伍数
MAX_APPLYMEMBER     = 15	--最大申请数


------------------------------------------------------------------
--队伍成员数据结构

stTeamMember = class("stTeamMember")

function stTeamMember:init()
	self.id				 = 0    --ID
	self.strName		 = ""   --名字
	self.level			 = 0    --等级
	self.eSchool		 = 0
	self.shapeID		 = 0    --造型ID
	self.iMapID			 = 0    --地图ID
	self.iSceneID		 = 0    --地图sceneID
	self.ptLogicLocation = {x=-1, y=-1} --当前队员的位置，逻辑坐标
	self.HP              = 0
	self.MaxHP           = 0
	self.MP              = 0
	self.MaxMP           = 0
	self.eMemberState	 = eTeamMemberNULL --队员状态，正常，暂离，掉线...
	self.components      = {}
	self.mulTimeType     = 0    --领取的多倍经验时间类型
	self.mulExpTime      = 0    --领取的多倍经验时间
    self.campType        = 0
end

--TeamMemberBasic
function stTeamMember:setData(data)
    self.id = data.roleid
	self.strName = data.rolename		--名字
	self.level = data.level
	self.eSchool = data.school
	self.shapeID = data.shape
	self.iSceneID = data.sceneid
	self.iMapID = bit.band(self.iSceneID, 0x00000000FFFFFFFF) --地图ID
	self.ptLogicLocation = {x=data.pos.x, y=data.pos.y}
	self.HP = data.hp
	self.MaxHP = data.maxhp
	self.MP = data.mp
	self.MaxMP = data.maxmp
	self.eMemberState = data.state	--队员状态，正常，暂离，掉线...
    self.campType = data.camp
	self.components = data.components
end

function stTeamMember:IsNormal()
	return self.eMemberState == eTeamMemberNormal
end

function stTeamMember:getComponentNum()
    return TableUtil.tablelength(self.components)
end

function stTeamMember:getComponent(key)
    return self.components[key] or 0
end

------------------------------------------------------------------
--作为队长邀请过的人
stTeamInviter = class("stTeamInviter")

function stTeamInviter:init()
	self.roleid = 0
	self.life = 20000  --20s自动消失
end

------------------------------------------------------------------
--队伍匹配设置
stTeamMatchInfo = class("stTeamMatchInfo")

function stTeamMatchInfo:init()
	self.targetid = 0   --行动目标
	self.minlevel = 1
	self.maxlevel = 100
end

------------------------------------------------------------------
--队伍申请者
stApplyMember = class("stApplyMember")

function stApplyMember:init()
	self.id         = 0
	self.strName    = ""
	self.level      = 0
	self.eSchool    = 0
	self.life       = 60000	--存在1分钟后要自动消失，这里客户端自己删吧
	self.shape      = 0
	self.components = {}
end

--data: TeamApplyBasic
function stApplyMember:setData(data)
    self.id = data.roleid;
	self.strName = data.rolename
	self.eSchool = data.school
	self.level = data.level
	self.shape = data.shape
	self.components = data.components
end

function stApplyMember:getComponent(key)
    return self.components[key] or 0
end

------------------------------------------------------------------
-- TeamError
TeamErrorInfoList = {
    --程序内字符串
	1291,    --0 未知错误
    1292,    --1 自己已经在队伍中
    1293,    --2 自己不在队伍中
    1294,    --3 对方已经在队伍中
    1295,    --4 自己不是队长
    1296,    --5 对方不是队长
    1297,    --6 对方不在线
    1298,    --7 自己组队开关关闭
    1299,    --8 对方组队开关关闭
    1300,    --9 自己在不可组队状态
    1301,    --10 对方在不可组队状态
    1302,    --11 队伍人数已满
    1303,    --12 对方已经在队伍中
    1304,    --13 对方正在被其他人邀请中
    1305,    --14 对方30秒内曾经被队伍或者个人邀请过
    1306,    --15 正在邀请人数达到4个，不能再邀请更多
    1307,    --16 邀请你的队伍已经解散
    1308,    --17 邀请者不是队长
    1309,    --18 申请者已经在队伍中
    1310,    --19 该申请已经超时
    1311,    --20 队伍申请列表已满
    1312,    --21 申请者级别不符合队伍要求
    1313,    --22 队伍处在不可以换队长的状态
    1314,    --23 已经提出更换队长，等待回应中
    1315,    --24 队伍2分钟只能更换队长一次
    1316,    --25 队员不处于正常状态
    1317,    --26 距离过远，不能归队
    1318,    --27 队伍没有暂离的队员
    1319,    --28 拒绝成为队长
    1320,    --29 对方不在队伍中。
    1321,    --30 你已经在对方的申请列表中，别着急……
    1322,    --31 暂离队伍的玩家不能提升为队长

    --客户端提示
    150021,  --32 等级设置错误
    150022,  --33 等级不符合
    150023,  --34 没有设置目标
    150024,	 --35 队伍人数已满
    150025,	 --36 已经在匹配中
    150026,	 --37 活动暂未开放
    150027,	 --38 你没有加入公会
    0,       --39 组队状态客户端服务器不同步
    150028	 --40 请稍后再喊
}