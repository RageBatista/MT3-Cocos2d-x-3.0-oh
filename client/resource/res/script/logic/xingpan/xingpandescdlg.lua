require "logic.dialog"

XingPanDescDlg = {}
setmetatable(XingPanDescDlg, Dialog)
XingPanDescDlg.__index = XingPanDescDlg

local _instance
function XingPanDescDlg.getInstance()
	if not _instance then
		_instance = XingPanDescDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function XingPanDescDlg.getInstanceAndShow()
	if not _instance then
		_instance = XingPanDescDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function XingPanDescDlg.getInstanceNotCreate()
	return _instance
end

function XingPanDescDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function XingPanDescDlg.ToggleOpenClose()
	if not _instance then
		_instance = XingPanDescDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function XingPanDescDlg.GetLayoutFileName()
	return "xingpandescdlg.layout"
end


function XingPanDescDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, XingPanDescDlg)
	return self
end

function XingPanDescDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("xingyinxiangqing/closebtn"))
	self.XingPanBtn = CEGUI.toGroupButton(winMgr:getWindow("xingyinxiangqing/xingpan"))
	self.TaozhuangBtn = CEGUI.toGroupButton(winMgr:getWindow("xingyinxiangqing/taozhuang"))
	self.xingpanDesc = winMgr:getWindow("xingyinxiangqing/xingpandesc")
	self.TaozhuangDesc = winMgr:getWindow("xingyinxiangqing/taozhuangdesc")
	self.my1 = winMgr:getWindow("xingyinxiangqing/xingpandesc/1/my")
	self.t1 = winMgr:getWindow("xingyinxiangqing/xingpandesc/1/tiaoshu1")
	self.my2 = winMgr:getWindow("xingyinxiangqing/xingpandesc/1/my1")
	self.t2 = winMgr:getWindow("xingyinxiangqing/xingpandesc/1/tiaoshu11")
	self.my3 = winMgr:getWindow("xingyinxiangqing/xingpandesc/1/my11")
	self.t3 = winMgr:getWindow("xingyinxiangqing/xingpandesc/1/tiaoshu111")

	self.closeBtn:subscribeEvent("Clicked", XingPanDescDlg.HandleCloseBtn, self)
	self.XingPanBtn:subscribeEvent("SelectStateChanged", XingPanDescDlg.HandleXingPanClicked, self)
	self.TaozhuangBtn:subscribeEvent("SelectStateChanged", XingPanDescDlg.HandleTaozhuangClicked, self)
	self:updateXingPan()
end
function XingPanDescDlg:getXingYinCount()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local ycount = 0
    local fcount = 0
    for k=31,36 do
        local pItem, key = roleItemManager:GetItemByLoction(fire.pb.item.BagTypes.EQUIP, k)
        if pItem then
            if k == eEquipType_XPSHE or k == eEquipType_XPHU or k == eEquipType_XPTU then
                ycount = ycount + 1
            elseif k == eEquipType_XPNIU or k == eEquipType_XPLONG or k == eEquipType_XPYANG then
                fcount = fcount + 1
            end
        end
    end
    return ycount, fcount
end

function XingPanDescDlg:updateXingPan()
	local ycount, fcount = self:getXingYinCount()
	self.t1:setText("3圆+1方")
	self.t2:setText("1圆+3方")
	self.t3:setText("2圆+2方")
	self.my1:setVisible(ycount == 3 and fcount == 1)
	self.my2:setVisible(ycount == 1 and fcount == 3)
	self.my3:setVisible(ycount == 2 and fcount == 2)
end
function XingPanDescDlg:HandleCloseBtn(args)
	self:DestroyDialog()
end

function XingPanDescDlg:HandleXingPanClicked(args)
	self.xingpanDesc:setVisible(true)
	self.TaozhuangDesc:setVisible(false)
end

function XingPanDescDlg:HandleTaozhuangClicked(args)
	self.TaozhuangDesc:setVisible(true)
	self.xingpanDesc:setVisible(false)
end

return XingPanDescDlg
