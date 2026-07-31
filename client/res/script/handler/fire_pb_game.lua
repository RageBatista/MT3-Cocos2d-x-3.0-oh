
local sbeginschoolwheel = require "protodef.fire.pb.game.sbeginschoolwheel"
function sbeginschoolwheel:process()
	print("protodef.sbeginschoolwheel")
	
    require("logic.lottery.lotteryjifendlg").sbeginschoolwheel_process(self)
end
local sbeginxueyuewheel = require "protodef.fire.pb.game.sbeginxueyuewheel"
function sbeginxueyuewheel:process()
	print("protodef.sbeginxueyuewheel")
    require("logic.fuyuanbox.fuyuanboxdlg").Sfunyuan_pro(self.wheelindex)
end

local susexueyuekey = require "protodef.fire.pb.game.susexueyuekey"
function susexueyuekey:process()
	print("protodef.susexueyuekey")
    local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	flyWalkData.nMapId = self.mapid
    flyWalkData.nNpcKey = self.npckey
	flyWalkData.nTargetPosX = self.xpos
	flyWalkData.nTargetPosY = self.ypos
    flyWalkData.nNpcId = self.npckid
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)
end

local m = require "protodef.fire.pb.game.sroleaccusation"
function m:process()
	if self.isbereported == 1 then
		b_RoleAccusation = true
	elseif self.isbereported == 0 then
		b_RoleAccusation = false
	end
end
local m = require "protodef.fire.pb.game.soutrecharge"
function m:process()
	require "logic.qiandaosongli.loginrewardmanager"
	local mgr = LoginRewardManager.getInstance()
	mgr:SetPayNum(self.pay)
	mgr:SetTotal(self.total)
	mgr:SetDayReawardMap(self.dayrewardmap)
	mgr:SetTotalReawardMap(self.totalrewardmap)
end
local m = require "protodef.fire.pb.game.soutreawardresult"
function m:process()
	local dlg = require"logic.qiandaosongli.fuliplane".getInstanceNotCreate()
	if dlg then
		dlg:UpdateTitleText()
	end
end
local m = require "protodef.fire.pb.game.sroleaccusationcheck"
function m:process()
	
	local dlg = RoleAccusation.getInstanceNotCreate()
	if self.errorcode == 0 and dlg then
		local data = gGetDataManager():GetMainCharacterData()

		local id = gGetDataManager():GetMainCharacterID() --�ٱ���id
		local name = gGetDataManager():GetMainCharacterName() --�ٱ�������
		local lv = data:GetValue(fire.pb.attr.AttrType.LEVEL) --�ٱ��˵ȼ�
		local fushi = gGetDataManager():GetTotalRechargeYuanBaoNumber() --�ٱ����ۼƳ�ֵ
		
		gGetVoiceManager():RoleAccusation(dlg.m_RoleID, dlg.m_ReasonID, CEGUI.String(dlg.m_Content), dlg.m_RoleLv, dlg.m_Fushi, id, CEGUI.String(name), lv, fushi)
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(190037))
	end

	RoleAccusation.DestroyDialog()
end