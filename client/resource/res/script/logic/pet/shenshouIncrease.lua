require "logic.dialog"
require "logic.pet.shenshouIncreasecell"

ShenShouIncrease = {}
setmetatable(ShenShouIncrease, Dialog)
ShenShouIncrease.__index = ShenShouIncrease

local _instance
function ShenShouIncrease.getInstance()
	if not _instance then
		_instance = ShenShouIncrease:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShenShouIncrease.getInstanceAndShow()
	if not _instance then
		_instance = ShenShouIncrease:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShenShouIncrease.getInstanceNotCreate()
	return _instance
end

function ShenShouIncrease.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
		    gGetDataManager().m_EventPetDataChange:RemoveScriptFunctor(_instance.eventPetDataChange) -- 注销宠物数据变化的事件
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShenShouIncrease.ToggleOpenClose()
	if not _instance then
		_instance = ShenShouIncrease:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShenShouIncrease.GetLayoutFileName()
	return "tishenshenshou.layout"
end

function ShenShouIncrease:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShenShouIncrease)
	return self
end

function ShenShouIncrease:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_list = winMgr:getWindow("tishenshenshou/diban")

	self.m_IncreaseTimes = winMgr:getWindow("tishenshenshou/tishenshu")
	self.m_RemainTimes = winMgr:getWindow("tishenshenshou/shengyushu")

	self.m_attackApt = winMgr:getWindow("tishenshenshou/gongzishu")
	self.m_attackApt_Increase = winMgr:getWindow("tishenshenshou/tishenshu21")
	self.m_defendApt = winMgr:getWindow("tishenshenshou/fangzishu")
	self.m_defendApt_Increase = winMgr:getWindow("tishenshenshou/fangzishu1")
	self.m_phyApt = winMgr:getWindow("tishenshenshou/tizishu")
	self.m_phyApt_Increase = winMgr:getWindow("tishenshenshou/tizishu1")
	self.m_magicApt = winMgr:getWindow("tishenshenshou/fazishu")
	self.m_magicApt_Increase = winMgr:getWindow("tishenshenshou/tishenshu2121")
	self.m_speedApt = winMgr:getWindow("tishenshenshou/suzishu")
	self.m_speedApt_Increase = winMgr:getWindow("tishenshenshou/tishenshu21211")
	self.m_growApt = winMgr:getWindow("tishenshenshou/chengzhangshu")
	self.m_growApt_Increase = winMgr:getWindow("tishenshenshou/chengzhangshu1")

    self.m_ItemCell = CEGUI.toItemCell(winMgr:getWindow("tishenshenshou/bg2/daoju"))
    self.m_ItemName = winMgr:getWindow("tishenshenshou/bg2/shendoudou")
    self.m_ItemNum = winMgr:getWindow("tishenshenshou/bg2/number")
    self.m_Btn_Increase = winMgr:getWindow("tishenshenshou/bg2/btnduihuan")
    self.m_Btn_Increase:subscribeEvent("Clicked", ShenShouIncrease.OnIncreaseClicked, self)
	
	self.ccmoxing = winMgr:getWindow("tishenshenshou/dizicy/mxcc")
	self.ccname = winMgr:getWindow("tishenshenshou/dizicy/name")
	self.ccinfo = CEGUI.toRichEditbox(winMgr:getWindow("tishenshenshou/dizicy/ccinfo"))
	
	self.cctips = CEGUI.toPushButton(winMgr:getWindow("tishenshenshou/tips"))
	self.cctips:subscribeEvent("Clicked", ShenShouIncrease.handtishenTipClicked, self)

	
	
	self.petScrohdc = CEGUI.toScrollablePane(winMgr:getWindow("tishenshenshou/jineng"))
	self.skillBoxes = {}
	for i=1,12 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("tishenshenshou/jineng/skill"..i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", ShenShouIncrease.handleSkillClicked, self)
        self.skillBoxes[i]:SetBackGroupOnTop(true)
		self.petScrohdc:addChildWindow(self.skillBoxes[i])
	end

    -- 宠物栏中的神兽列表
    self.m_ShenShouList = require("logic.pet.shenshoucommon").GetShenShouList()

    -- 刷新神兽列表
    self:RefreshListView()

    -- 刷新UI
    self:RefreshUI()

    -- 注册宠物数据变化的事件
	self.eventPetDataChange = gGetDataManager().m_EventPetDataChange:InsertScriptFunctor(ShenShouIncrease.handleEventPetDataChange)
end

-- 刷新神兽列表
function ShenShouIncrease:RefreshListView()
    local listSize = self.m_list:getPixelSize()
    if not self.m_ListEntrys then
        self.m_ListEntrys = TableView.create(self.m_list)
        self.m_ListEntrys:setViewSize(listSize.width, listSize.height - 10)
        self.m_ListEntrys:setPosition(5, 5)
	    self.m_ListEntrys:setColumCount(4)----显示4个
        self.m_ListEntrys:setCellInterval(5, 5)
        self.m_ListEntrys:setDataSourceFunc(self, ShenShouIncrease.tableViewGetCellAtIndex)
    end

    local len = #self.m_ShenShouList
    self.m_ListEntrys:setCellCountAndSize(len, 291, 100)
    self.m_ListEntrys:reloadData()

    -- 当前选中第一个神兽
    if len > 0 then
        self.m_ListEntrys.visibleCells[0].m_Btn:setSelected(true)
    end
	
end

-- 设置单个神兽的数据
function ShenShouIncrease:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end

    if not cell then
        cell = ShenShouIncreaseCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
    end
    if self.m_ShenShouList and #self.m_ShenShouList > idx then
        cell:SetPetInfo(self.m_ShenShouList[idx + 1])
        cell.m_Btn:subscribeEvent("SelectStateChanged", ShenShouIncrease.OnCellSelectStateChanged, self)
        cell.m_Btn:setID(idx + 1)
    end

    return cell
end

function ShenShouIncrease:handleSkillClicked(args)
	local wnd = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if wnd:GetSkillID() == 0 then
		return
	end
	local pos = wnd:GetScreenPos()
	PetSkillTipsDlg.ShowTip(wnd:GetSkillID(),pos.x, pos.y)
end

-- 神兽选中状态发生变化的回调
function ShenShouIncrease:OnCellSelectStateChanged(args)
    local windowEventArgs = CEGUI.toWindowEventArgs(args)
    self.m_SelectedEntryIndex = windowEventArgs.window:getID() - 1

    -- 刷新神兽数据
    self:RefreshShenShouInfo(self.m_SelectedEntryIndex)
end

-- 处理点击提升按钮
function ShenShouIncrease:OnIncreaseClicked(args)
   local petInfo = self.m_ShenShouList[self.m_SelectedEntryIndex + 1]
   ShenShouCommon.DoIncrease(petInfo.key)
end

-- 刷新UI
function ShenShouIncrease:RefreshUI()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)

    -- 背包中“神兽兑换道具”的数量
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

    -- 提升神兽需要的“神兽兑换道具”的数量
	local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(288).value
    local nNeedItemNum = tonumber(strNeedItemNum)

    if itemAttr then
        -- 道具图标
	    local image = gGetIconManager():GetItemIconByID(itemAttr.icon)
        self.m_ItemCell:SetImage(image)
        SetItemCellBoundColorByQulityItemWithId(self.m_ItemCell, nItemID)
        -- 道具名称
        self.m_ItemName:setText(itemAttr.name)
    end

    -- 道具数量
    self.m_ItemNum:setText(string.format("%d/%d", curItemNum, nNeedItemNum))

    -- 刷新神兽数据
    self:RefreshShenShouInfo(self.m_SelectedEntryIndex)
end

function ShenShouIncrease:handtishenTipClicked(args)
    local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
    local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)
    local itemName = itemAttr and itemAttr.name or ""
    local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(288).value
    local nNeedItemNum = tonumber(strNeedItemNum)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)
    local petInfo = self.m_ShenShouList[self.m_SelectedEntryIndex + 1]
    local nNowIncCnt = petInfo.shenshouinccount
    local strMaxIncCnt = GameTable.common.GetCCommonTableInstance():getRecorder(305).value
    local nMaxIncCnt = tonumber(strMaxIncCnt)
    local nRemainIncCnt = nMaxIncCnt - nNowIncCnt

    local str = MHSD_UTILS.get_resstring(7491) 

    str = string.gsub(str, "%$parameter1%$", petInfo.name)--名字
    str = string.gsub(str, "%$parameter2%$", nNowIncCnt)--提升次数
    str = string.gsub(str, "%$parameter3%$", nRemainIncCnt)--还可以提升次数
    str = string.gsub(str, "%$parameter4%$", itemName)---物品名字
    str = string.gsub(str, "%$parameter5%$", nNeedItemNum)--需要的数量
    str = string.gsub(str, "%$parameter6%$", curItemNum) -- 当前拥有
	str = string.gsub(str, "%$parameter7%$", petInfo:getAttribute(fire.pb.attr.AttrType.LEVEL))--宠物等级

    local tip = TextTip.CreateNewDlg()
    tip:setTipText(str)
end


-- 刷新神兽数据
function ShenShouIncrease:RefreshShenShouInfo(idx)
    if self.m_ShenShouList and #self.m_ShenShouList > idx then
        local petInfo = self.m_ShenShouList[idx + 1]

        -- 神兽提升最大次数
	    local strMaxIncCnt = GameTable.common.GetCCommonTableInstance():getRecorder(305).value
        local nMaxIncCnt = tonumber(strMaxIncCnt)
        -- 当前神兽提升次数
        local nNowIncCnt = petInfo.shenshouinccount
	    self.m_IncreaseTimes:setText(nNowIncCnt)
        -- 当前神兽剩余提升次数
        local nRemainIncCnt = nMaxIncCnt - nNowIncCnt
	    self.m_RemainTimes:setText(nRemainIncCnt)
		
		local strBuilder = StringBuilder:new() 
        strBuilder:Set("parameter1", petInfo.name) 
        strBuilder:Set("parameter2", nNowIncCnt) -- 已经提升次数
        strBuilder:Set("parameter3", nRemainIncCnt) 
        local infoText = strBuilder:GetString(MHSD_UTILS.get_resstring(7490))
        self.ccinfo:Clear()
        self.ccinfo:AppendParseText(CEGUI.String(infoText))
        self.ccinfo:Refresh()
        strBuilder:delete()

		local skillNum = petInfo:getSkilllistlen()
        for i = 1, 12 do 
            if i <= skillNum then 
                local skill = petInfo:getSkill(i)
                if skill then
                    local petSkill = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
                    if petSkill then
                        self.skillBoxes[i]:SetBackgroundDynamic(true)
                        self.skillBoxes[i]:SetImage(gGetIconManager():GetSkillIconByID(petSkill.icon))
                        local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
                        if skillconf and skillconf.id ~= -1 then
                            local img = (skillconf.skilltype == 1 and "beiji" or "zhuji")
                            img = img .. (skillconf.color == 1 and 1 or 2)
                            self.skillBoxes[i]:SetBackGroundImage(CEGUI.String("ccui"), CEGUI.String(img))
                        end
					self.skillBoxes[i]:SetSkillID(skill.skillid)
                    local isSkillBind = petInfo:isSkillBind(skill.skillid) 
                    local showCornerImg = true
                    SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petInfo, showCornerImg, skill.certification, isSkillBind) 

                    end
                else
                    
                    self.skillBoxes[i]:SetBackgroundDynamic(false)
                   -- self.skillBoxes[i]:SetImage("")
                    self.skillBoxes[i]:SetSkillID(0)
                end
            else
                
                self.skillBoxes[i]:SetBackgroundDynamic(false)
               -- self.skillBoxes[i]:SetImage("")
                self.skillBoxes[i]:SetSkillID(0) 
            end
        end
		
		local shapeID = petInfo:GetShapeID() 
        if not self.sprite then 
            local pos = self.ccmoxing:GetScreenPosOfCenter() 
            local loc = Nuclear.NuclearPoint(pos.x, pos.y) 
            self.sprite = UISprite:new(shapeID)
            if self.sprite then
                self.sprite:SetUILocation(loc)
                self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT) 
                self.ccmoxing:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, ShenShouIncrease.performPostRenderFunctions))
            end
        else 
            self.sprite:SetModel(shapeID) 
            self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT) 
        end
		
		

        -- 当前神兽资质
        self.m_attackApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT))
        self.m_defendApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT))
        self.m_phyApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT))
        self.m_magicApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT))
        self.m_speedApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT))
        self.m_growApt:setText(string.format("%0.3f", math.floor(petInfo.growrate * 1000) / 1000))

        local plus = MHSD_UTILS.get_resstring(11477)
        self.ccname:setText(petInfo.name) 
        -- 当前神兽资质可提升值
        self.m_attackApt_Increase:setText(plus .. 0)
        self.m_defendApt_Increase:setText(plus .. 0)
        self.m_phyApt_Increase:setText(plus .. 0)
        self.m_magicApt_Increase:setText(plus .. 0)
        self.m_speedApt_Increase:setText(plus .. 0)
        self.m_growApt_Increase:setText(plus .. 0)
        if nRemainIncCnt > 0 then
            local ids = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getAllID()
            for i = 1, #ids do
	            local shenshouinc = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getRecorder(ids[i])
                if shenshouinc and shenshouinc.petid == petInfo.baseid and shenshouinc.inccount == nNowIncCnt + 1 then
                    self.m_attackApt_Increase:setText(plus .. shenshouinc.atkinc)
                    self.m_defendApt_Increase:setText(plus .. shenshouinc.definc)
                    self.m_phyApt_Increase:setText(plus .. shenshouinc.hpinc)
                    self.m_magicApt_Increase:setText(plus .. shenshouinc.mpinc)
                    self.m_speedApt_Increase:setText(plus .. shenshouinc.spdinc)
                    self.m_growApt_Increase:setText(plus .. string.format("%0.3f", shenshouinc.attinc / 1000))
                end
            end
        end
    end
end

function ShenShouIncrease.performPostRenderFunctions(id)
	if _instance and _instance:IsVisible() and _instance:GetWindow():getEffectiveAlpha() > 0.95 and _instance.selectedPetKey ~= 0 and _instance.sprite then
		_instance.sprite:RenderUISprite()
	end
end

-- 宠物数据变化的回调
function ShenShouIncrease.handleEventPetDataChange(key)
	if _instance and _instance:IsVisible() then
	    _instance:RefreshUI()
	end
end

return ShenShouIncrease