require "logic.dialog"
require "utils.commonutil"
require "logic.addnewitemseffect"

LuaUIManager = {m_UIDialog = {}}
LuaUIManager.__index = LuaUIManager

local _instance = nil
function LuaUIManager.getInstance()
	if not _instance then
		_instance = LuaUIManager:new()
	end
	
	return _instance
end


function LuaUIManager.Exit()
	if _instance then
		_instance:RemoveAllDialog()
	end
	
	FormationManager.Destroy()
	package.loaded["logic.faction.factiondatamanager"] = nil
	require "logic.faction.factiondatamanager"
	
	g_getyc = false

	require "logic.specialeffect.specialeffectmanager"
	SpecialEffectManager.Destroy()

	require "logic.task.taskmanager".Destroy() --
	require "logic.task.tasktimermanager".Destroy() --Tasktimermanager
	require "logic.workshop.workshopmanager".Destroy() --workshopmanager.lua
	require "system.maillistmanager".Destroy()
    require ("logic.qiandaosongli.loginrewardmanager").Destroy()
    require ("logic.jingji.jingjimanager").Destroy()
    require ("logic.space.spacemanager").Destroy()
    require "logic.space.eventmanager".Destroy()
    require("logic.bingfengwangzuo.bingfengwangzuomanager").setInBingfeng( false )
    require "logic.task.schedulermanager".Destroy()
    require "logic.skill.roleskillmanager".destroyInstance()
    require "logic.battle.battlemanager".destroyInstance()
    require "logic.pointcardserver.pointcardservermanager".Destroy()
    require("logic.huodong.huodongmanager").Destroy()
    require("logic.redpack.redpackmanager").Destroy()
    require("logic.pointcardserver.pointcardservermanager").Destroy()
    require("logic.shoujianquan.shoujianquanmgr").clear()

	gCommon.reset()
	ShopManager:onGameExit()
    YangChengListDlg.Clean()
    AddNewItemsEffect.Destroy()
    TeamManager.removeInstance()
    WelfareManager.removeInstance()
    TaskManager_CToLua.removeInstance()
    NotificationCenter.purgeData()
    CurrencyManager.purgeData()
    MainRoleDataManager.removeInstance()
    FriendManager.Destroy()
    local datamanager = require "logic.family.familyfightmanager"
    if datamanager then
        datamanager:ResetData()
    end
end

function LuaUIManager:new()
	local self = {}
	setmetatable(self, LuaUIManager)

    CEGUI.System:getSingleton():subscribeEvent("GUISheetChanged", LuaUIManager.handleGUISheetChanged, self)
    self.savedModalTarget = nil

	return self
end

function LuaUIManager:handleGUISheetChanged(args)
    print("handleGUISheetChanged")

    local activeSheet = CEGUI.System:getSingleton():getGUISheet()
    local rootWnd = gGetGameUIManager():GetMainRootWnd()

    if not activeSheet or not rootWnd then
        return
    end

    if activeSheet == rootWnd then
        if self.savedModalTarget then
            --print("restore old modal target")
            self.savedModalTarget:setModalState(true)
            self.savedModalTarget = nil
        end
    else
        local child_count = rootWnd:getChildCount()
        for i = 0, child_count - 1 do
            local child = rootWnd:getChildAtIdx(i)
            if child and child:isVisible(true) and child:getEffectiveAlpha() > 0.95 and child:isModalAfterShow() then
                --print("save old modal target")
                self.savedModalTarget = child
                self.savedModalTarget:subscribeEvent("DestructStart", LuaUIManager.OnSavedModalTargetDestroyed, self)
                break
            end
        end
    end
end

function LuaUIManager:OnSavedModalTargetDestroyed(args)
    self.savedModalTarget = nil
end

function LuaUIManager:AddDialog(window, dialog)
	if window then
		print(" add a dialog", window)
		self.m_UIDialog[window] = dialog
        window:subscribeEvent("DestructStart", LuaUIManager.OnUIDialogDestructStarted, self)
	end
end

function LuaUIManager:getDialog(window)
    if window then
		return self.m_UIDialog[window]
    end
	return nil
end

function LuaUIManager:OnUIDialogDestructStarted(args)
    local window = CEGUI.toWindowEventArgs(args).window
    if self.m_UIDialog[window] then
        --It won't make any problem, just give a tip, this dialog didn't call OnClose. by lg
        if self.m_UIDialog[window].DestroyDialog then
            self.m_UIDialog[window]:DestroyDialog()
        end
        self.m_UIDialog[window] = nil
    end
end

function LuaUIManager:RemoveAllDialog()
	local temp = {}
	for k,v in pairs(self.m_UIDialog) do
		table.insert(temp, v)
	end
	for i,dlg in ipairs(temp) do
		dlg.m_bCloseIsHide = nil
		dlg:DestroyDialog()
	end
	LuaUIManager.m_UIDialog = {}
end

function LuaUIManager:RemoveUIDialog(window)
	print("remove dialog", window:getName())
	self.m_UIDialog[window] = nil
end

--[[

Openui.eUIId = 
{
	shanghui_01 =1, 
	baitan_02 =2,
	bangpaijineng_03 =3,
	shangcheng_04 =4,
	chongzhi_05 =5,
	zhuangbeidazao_06 =6,
	baoshihecheng_07 =7,
	zhuangbeixiuli_08 =8,
	zhuangbeixiangqian_09 =9,
}


--]]
function LuaUIManager.OpenXq(nBagId,nItemKey)
	--local luaUIManager = LuaUIManager.getInstance()
	--luaUIManager:OpenUI(LuaUIManager.eUIId.workshopxq)
	local Openui= require("logic.openui")
	Openui.OpenUI(Openui.eUIId.zhuangbeixiangqian_09,nBagId,nItemKey)
end

function LuaUIManager.OpenBaitan(nBagId,nItemKey)
	
	--local nItemKey = self.nItemKey
	require("logic.shop.stalldlg").showStallSell(nItemKey)
	
	--local Openui= require("logic.openui")
	--Openui.OpenUI(Openui.eUIId.baitan_02,nBagId,nItemKey)
end

function LuaUIManager.OpenShanghui(nBagId,nItemKey)
	
	local Openui= require("logic.openui")
	Openui.OpenUI(Openui.eUIId.shanghui_01,nBagId,nItemKey)
end

function LuaUIManager:OpenUI(nUIId)
	--[[
	LogInfo("LuaUIManager:OpenUI(nUIId)=nUIId="..nUIId)
	if LuaUIManager.eUIId.workshopxq==nUIId then
		local nBagId =0
		local nItemKey = 0
		local nType = 2 --xq
		require "logic.workshop.workshoplabel".Show(nType, nBagId, nItemKey)
	end
	--]]
	
end

return LuaUIManager
