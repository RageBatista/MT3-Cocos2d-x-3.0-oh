require "logic.dialog"
require "utils.commonutil"
require "utils.mhsdutils"


Taskuseitemdialog = {}
setmetatable(Taskuseitemdialog, Dialog)
Taskuseitemdialog.__index = Taskuseitemdialog
local _instance

Taskuseitemdialog.eUseType = 
{
    taskUseItem =1,
    cangbaotu =2,
    chuanzhuangbei=3,
}


function Taskuseitemdialog:OnCreate()
	
	local prefixName = "Taskuseitemdialog"
	Dialog.OnCreate(self,nil,prefixName)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefixName.."UseToRemindcard/item"))
	self.labelName = winMgr:getWindow(prefixName.."UseToRemindcard/name")
	self.btnUse = winMgr:getWindow(prefixName.."UseToRemindcard/ok")
	self.btnUse:subscribeEvent("MouseClick", self.HandleClickedUse, self)
	self.btnClose = winMgr:getWindow(prefixName.."UseToRemindcard/closed")
	self.btnClose:subscribeEvent("MouseClick", self.HandleClickedClose, self)
	
	self:GetWindow():subscribeEvent("WindowUpdate", Taskuseitemdialog.HandleWindowUpate, self)

	
	self.m_pMainFrame:setAlwaysOnTop(true)
	self.treasureId = 331300      -- 低级藏宝图
	self.superTreasureId = 331301 -- 高级藏宝图

    self.itemCell:subscribeEvent("TableClick", Taskuseitemdialog.HandleClickItemCell, self)

    self:GetWindow():setRiseOnClickEnabled(false)
end

function Taskuseitemdialog:HandleClickItemCell(args)
    local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e2 = CEGUI.toMouseEventArgs(args)
	local touchPos = e2.position
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	local Commontipdlg = require "logic.tips.commontipdlg"
	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--local nType = Commontipdlg.eType.eComeFrom
	local nType = Commontipdlg.eType.eNormal 
    local pObj = nil

    if self.nType == Taskuseitemdialog.eUseType.cangbaotu  or 
        self.nType == Taskuseitemdialog.eUseType.chuanzhuangbei
    then
        local nBagType = fire.pb.item.BagTypes.BAG
        local nItemKey = self.key
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	    pItem = roleItemManager:FindItemByBagAndThisID(nItemKey,nBagType) -- roleItemManager:GetItemByBaseID(nItemId,bBind,nBagType)
	    if pItem then
		    pObj = pItem:GetObject()
	    end
    end

	commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY,pObj)
end


function Taskuseitemdialog:isTaskItem(nItemId)
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return false
	end
	local nItemType = itemAttrCfg.itemtypeid
	local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType) 

	if nFirstType==eItemType_TASKITEM then
		return true
	end
	return false
end

function Taskuseitemdialog:HandleWindowUpate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    --self.m_iLeftTime = self.m_iLeftTime - ue.d_timeSinceLastFrame * 1000;

	local nItemId = self.nItemId
	local nBagType = fire.pb.item.BagTypes.QUEST
	local bBind = false
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local bHaveItem = false
	local pItem = roleItemManager:GetItemByBaseID(nItemId,bBind,nBagType)
	if pItem then
		bHaveItem = true
	end
	
	nBagType = fire.pb.item.BagTypes.BAG
	pItem = roleItemManager:GetItemByBaseID(nItemId,bBind,nBagType)
	if pItem then
		bHaveItem = true
	end
	
	if not bHaveItem then
		Taskuseitemdialog.DestroyDialog()
	end

    return true
end

--[[
<variable name="neffectid" type="int" fromCol="显示特效ID" /> 
			<variable name="treasure" type="int" fromCol="是否珍品" /> 		
			
			<variable name="nroleeffectid" type="int" fromCol="使用特效ID" /> 
			<variable name="neffectposx" type="int" fromCol="显示特效X轴" /> 
			<variable name="neffectposy" type="int" fromCol="显示特效Y轴" />
			
--]]

function  Taskuseitemdialog:clickCangbaoTu()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:GetBagItem(self.key)
	roleItemManager:UseItem(pItem)
    Taskuseitemdialog.DestroyDialog()
end

function Taskuseitemdialog:clickChuanEquip()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local nItemId = self.nItemId
    local nBagType = fire.pb.item.BagTypes.BAG
	local bBind = false
	local pItem = roleItemManager:GetItemByBaseID(nItemId,bBind,nBagType)
	if not pItem then
        return
    end

    roleItemManager:RightClickItem(pItem)
    Taskuseitemdialog.DestroyDialog()
end

function Taskuseitemdialog.isTreasure()
    if _instance and (_instance.nItemId == _instance.treasureId or _instance.nItemId == _instance.superTreasureId) then
        return 1
	else
        return 0
    end
end

function Taskuseitemdialog:HandleClickedUse(e)
	local nItemId = self.nItemId
	
	if	nItemId == self.treasureId or 
		nItemId == self.superTreasureId then
		self:clickCangbaoTu()
        return 
	end

    if self.nType == Taskuseitemdialog.eUseType.chuanzhuangbei then
        self:clickChuanEquip()
        return
    end
   
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local bTaskItem = self:isTaskItem(nItemId)
		if bTaskItem then
			local nBagType = fire.pb.item.BagTypes.QUEST
			local bBind = false
			local pItem = roleItemManager:GetItemByBaseID(nItemId,bBind,nBagType)
			if pItem then
				roleItemManager:UseTaskItem(pItem)
			end
		else
			local nBagType = fire.pb.item.BagTypes.BAG
			local bBind = false
			local pItem = roleItemManager:GetItemByBaseID(nItemId,bBind,nBagType)
			if pItem then
				roleItemManager:UseItem(pItem)
			end
		
		end
		
	--self:showEffect(nItemId)
	
	Taskuseitemdialog.DestroyDialog()
end


function Taskuseitemdialog:showEffect(nItemId)
	--//use item 
	local taskItemCfg = BeanConfigManager.getInstance():GetTableByName("item.ctaskrelative"):getRecorder(nItemId)
	if taskItemCfg then
		local nEffectId = taskItemCfg.neffectid
		--local nRoleEffectId = taskItemCfg.
		--nEffectId = 10300 
		
		if nEffectId > 0 then
			local nPosX =  taskItemCfg.neffectposx
			local nPosY =  taskItemCfg.neffectposy
			local rootWin = gGetGameUIManager():GetMainRootWnd() 
			
			local strEffectPath = require ("utils.mhsdutils").get_effectpath(nEffectId)
			gGetGameUIManager():AddUIEffect(rootWin, strEffectPath, false,nPosX,nPosY,false)
		end
		
		local nRoleEffectId = taskItemCfg.nroleeffectid
		--nRoleEffectId = 10300 
		if nRoleEffectId > 0 then 
			
			local strEffectPath = require ("utils.mhsdutils").get_effectpath(nRoleEffectId)
			GetMainCharacter():PlayEffect(strEffectPath)
		end
	end
end

--[[
--    Nuclear::IEffect* AddUIEffect(CEGUI::Window* pWnd, const std::wstring& strEffectName, bool bCycle = true, int x = 0, int y = 0, bool clip = false);

virtual void PlayEffect(const std::wstring &effect_name,int dx, int dy,int times = 1, bool selfRef = true,bool bnofollowscale = false,bool playsound = true,bool alwaystop = false);
	virtual void PlayEffect(const std::wstring &effect_name,bool basync = false, bool playsound = true,bool linkframe = false);
	void Play3DEffect(const std::wstring &effect_name,const std::wstring &hostname,bool async=false,int times=1,int x=0,int y=0);
	virtual Nuclear::IEffect* SetDurativeEffect(const std::wstring &effect_name,  int bindType, int dx, int dy, bool selfRef,bool basync = true,bool bnofollowscale = false,bool alwayontop = false,bool underSprite=false,bool isShadow=false);
	virtual Nuclear::IEffect* SetDurativeEffect(const std::wstring &effect_name, int dx, int dy,const std::wstring& hostname = L"",bool basync = true);
	virtual void RemoveDurativeEffect(Nuclear::IEffect* pEffect);
	
--]]
function Taskuseitemdialog:HandleClickedClose(e)
	self:DestroyDialog()
end

function Taskuseitemdialog:SetUseItemId(nItemId, key,nType)
	self.nItemId = nItemId
    self.itemCell:setID(nItemId)
    self.nType = nType
    self.key = key

	NewRoleGuideManager.getInstance():GuideStartProperty(nItemId, self.btnUse:getName(), self.btnUse:getName())
	if key then
		self.key = key
	end
	local equipConfig = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not equipConfig then
		return
	end
	self.itemCell:SetImage(gGetIconManager():GetItemIconByID(equipConfig.icon))
	self.labelName:setText(equipConfig.name)


    if self.nType == Taskuseitemdialog.eUseType.chuanzhuangbei then

         local strZhuangbei = require("utils.mhsdutils").get_resstring(2666)
         self.btnUse:setText(strZhuangbei)
    end

    
end

--//==============================
function Taskuseitemdialog:GetLayoutFileName()
	return "usetoremindcard.layout"
end

function Taskuseitemdialog.getInstance()
	if _instance == nil then
		_instance = Taskuseitemdialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Taskuseitemdialog.getInstanceAndLoadData( itemId, key )
    local nType = Taskuseitemdialog.eUseType.cangbaotu
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    if roleItemManager:FindItemByBagAndThisID(key, fire.pb.item.BagTypes.BAG) == nil then
        return
    end
	if _instance == nil then
		_instance = Taskuseitemdialog:new()
		_instance:OnCreate()
        
		_instance:SetUseItemId(itemId, key,nType)
	else	
		_instance:SetUseItemId(itemId, key,nType)
	end
	return _instance
end


function Taskuseitemdialog.getInstanceNotCreate()
	return _instance
end

function Taskuseitemdialog.getInstanceOrNot()
	return _instance
end


function Taskuseitemdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Taskuseitemdialog)
	self:ClearData()
	return self
end

function Taskuseitemdialog.DestroyDialog()
	if not _instance then
		return
	end
	_instance:OnClose()
end

function Taskuseitemdialog:ClearData()

end

function Taskuseitemdialog:OnClose()
	Dialog.OnClose(self)
	self:ClearData()
	_instance = nil
end

function Taskuseitemdialog:OnBattleBegin()
    self:SetVisible(false)
end

function Taskuseitemdialog:OnBattleEnd()
    self:SetVisible(true)
end

return Taskuseitemdialog



