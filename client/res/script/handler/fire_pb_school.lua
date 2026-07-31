--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local m = require "protodef.fire.pb.school.change.soldschoollist"
function m:process()
	local dlg = ZhuanZhiDlg.getInstanceNotCreate()
	if dlg then
		dlg:SetOldSchoolList(self.oldshapelist, self.oldschoollist)
	end
end


--endregion
local mchangeweapon = require "protodef.fire.pb.school.change.schangeweapon"
function mchangeweapon:process()

	local dlg = WeaponSwitchDlg.getInstanceNotCreate()
	
	if dlg then
		dlg:RefreshFormInfo()
		GetCTipsManager():AddMessageTipById(193448)
	end
end


local mchangeweapon = require "protodef.fire.pb.school.change.schangegem"
function mchangeweapon:process()

	local dlg = ZhuanZhiBaoShi.getInstanceNotCreate()
	
	if dlg then
		dlg:RefreshFormInfo()
		GetCTipsManager():AddMessageTipById(193448)
	end
end