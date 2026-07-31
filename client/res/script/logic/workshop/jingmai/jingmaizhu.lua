require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

JingMaiZhu = {}
setmetatable(JingMaiZhu, Dialog)
JingMaiZhu.__index = JingMaiZhu
local _instance;
local JINGMAI_BASE_WIDTH = 1280
local JINGMAI_BASE_HEIGHT = 720

local function GetJingMaiLayoutScale()
    local engine = Nuclear.GetEngine and Nuclear.GetEngine()
    if not engine then
        return 1
    end

    local logicWidth = engine:GetLogicWidth()
    local logicHeight = engine:GetLogicHeight()
    if not logicWidth or logicWidth <= 0 or not logicHeight or logicHeight <= 0 then
        return 1
    end

    local layoutScale = math.min(logicWidth / JINGMAI_BASE_WIDTH, logicHeight / JINGMAI_BASE_HEIGHT)
    if layoutScale < 1 then
        layoutScale = 1
    end
    return layoutScale
end

local function ScaleJingMaiDim(dim, layoutScale)
    return CEGUI.UDim(dim.scale, dim.offset * layoutScale)
end

local function IsAutoWindow(wnd)
    if not wnd then
        return false
    end
    local name = wnd:getName()
    return name and string.find(name, "__auto_", 1, true) ~= nil
end

local function ScaleJingMaiWindowTree(wnd, layoutScale)
    if not wnd or layoutScale == 1 or IsAutoWindow(wnd) then
        return
    end

    wnd:setPosition(CEGUI.UVector2(
        ScaleJingMaiDim(wnd:getXPosition(), layoutScale),
        ScaleJingMaiDim(wnd:getYPosition(), layoutScale)))
    wnd:setSize(CEGUI.UVector2(
        ScaleJingMaiDim(wnd:getWidth(), layoutScale),
        ScaleJingMaiDim(wnd:getHeight(), layoutScale)))

    for i = 0, wnd:getChildCount() - 1 do
        ScaleJingMaiWindowTree(wnd:getChildAtIdx(i), layoutScale)
    end
end
--//===============================
function JingMaiZhu:OnCreate()
    Dialog.OnCreate(self)
    --SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.layoutScale = GetJingMaiLayoutScale()
    ScaleJingMaiWindowTree(self:GetWindow(), self.layoutScale)


	--GetCTipsManager():AddMessageTip("大全22") --jingmai111/diban/tuteng

    self.ScrollProperty = CEGUI.toScrollablePane(winMgr:getWindow("jingmaizhu/jingmais"))
    self.jieshaobtn = CEGUI.toPushButton(winMgr:getWindow("jingmaizhu/jingmaijieshao"))
    self.jieshaobtn:subscribeEvent("MouseButtonUp", JingMaiZhu.HandlejieshaoClick, self)

    self.jingmaiwenben = CEGUI.toPushButton(winMgr:getWindow("jingmaizhu/liebiao/level/lvwenben"))
    self.jingmaiwenben:subscribeEvent("MouseButtonUp", JingMaiZhu.HandlexuanzeClick, self)

    self.guanbi = CEGUI.toPushButton(winMgr:getWindow("jingmaizhu/guanbi"))
    self.guanbi:subscribeEvent("MouseButtonUp", JingMaiZhu.HandleguanbiClick, self)

    self.qianyuandanjia = CEGUI.toPushButton(winMgr:getWindow("jingmaizhu/qianyuandanjia"))
    self.qianyuandanjia:subscribeEvent("MouseButtonUp", JingMaiZhu.HandleqianyuandanClick, self)
    self.qiankundanjia = CEGUI.toPushButton(winMgr:getWindow("jingmaizhu/qiankundanjia"))
    self.qiankundanjia:subscribeEvent("MouseButtonUp", JingMaiZhu.HandleqiankundanClick, self)
    self.xingchenjia = CEGUI.toPushButton(winMgr:getWindow("jingmaizhu/xingchenjia"))
    self.xingchenjia:subscribeEvent("MouseButtonUp", JingMaiZhu.HandlexingchenjiaClick, self)
    self.fanganwenben = winMgr:getWindow("jingmaizhu/fanganwenben")
    self.fanganbtn = CEGUI.toPushButton(winMgr:getWindow("jingmaizhu/diban/shang/btnfangan"))
    self.fanganbtn:subscribeEvent("MouseButtonUp", JingMaiZhu.HandlefanganClick, self)

    self.qianyuandanwenben = winMgr:getWindow("jingmaizhu/qianyuandanwenben")
    self.qiankundanwenben = winMgr:getWindow("jingmaizhu/qiankundanwenben")
    self.xingchenwenben = winMgr:getWindow("jingmaizhu/xingchenwenben")


    self.fangan=0
    self.fangan2=0
    self.fanganwenben:setVisible(true)
    self.fanganbtn:setVisible(false)
	
	-- --背景特效
	local bgtxANi = gGetGameUIManager():AddUIEffect(self.ScrollProperty, "spine/my_spine/jinmai/my_jinmai_bg", true) --?????Ч ????
	bgtxANi:SetDefaultActName("stand1")
	bgtxANi:SetScale(0.92 * self.layoutScale)


end
function JingMaiZhu:showMain(data)
    local qianyuandannum=0
    local qiankundannum=0
    if data.state==0 then
        self.fanganwenben:setVisible(false)
        self.fanganbtn:setVisible(true)
    else
        self.fanganwenben:setVisible(true)
        self.fanganbtn:setVisible(false)
    end
    for k,v in pairs(data.jingmais) do
        if k>=1 and k<=12 then
            if v>0 then
                qianyuandannum=qianyuandannum+1
            end
        else
            if v>0 then
                qiankundannum=qiankundannum+1
            end
        end
    end

    self.qianyuandanwenben:setText(qianyuandannum.."/"..data.qianyuandan)
    self.qiankundanwenben:setText(qiankundannum.."/"..data.qiankundan)

    local xingyuns=0
    for k,v in pairs(data.xingchen) do
        xingyuns=xingyuns+1
    end
    local jihuox=0
    for k,v in pairs(data.jingmais) do
        if v==1 then
            jihuox=jihuox+1
        end
    end
    local keqianxian=0
     if GetMainCharacter():GetLevel()<=69 then
        keqianxian=5
    elseif GetMainCharacter():GetLevel()>=70 and GetMainCharacter():GetLevel()<=89 then
        keqianxian=6
    elseif GetMainCharacter():GetLevel()>=90 then
        keqianxian=7
    end
    if jihuox>=16 then
        keqianxian=keqianxian+1
    end
    self.xingchenwenben:setText(xingyuns.."/"..keqianxian)
    local schools = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaizhanshi"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    self.jingmaiwenben:setText(schools.names[data.fangan-1])
    self.data=data
    self.ScrollProperty:cleanupNonAutoChildren()
    local zhiye=gGetDataManager():GetMainCharacterSchoolID()
    self.fangan=data.fangan
    self.fangan2=self.fangan
    local prefix = "jingmai"..zhiye..data.fangan

    local cellPreview =  require "logic.workshop.jingmai.jingmais".new(self.ScrollProperty,0,prefix,self.layoutScale)
	
	local nextID = nil
			
			--筋脉激活为0时
			local itemsAni2 = gGetGameUIManager():AddUIEffect(cellPreview.itemTX[1], "spine/my_spine/jinmai/my_jingmai_kongdot", true) 
			itemsAni2:SetDefaultActName(zhiye)
			itemsAni2:SetScale(0.5 * self.layoutScale)

    for index=1,16 do
        if  data.xingchen[index] then--镶嵌的情况
            --cellPreview.items[index]:SetImage("itemicon7", "1127")
			local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(data.xingchen[index].id)
			cellPreview.items[index]:SetImage(gGetIconManager():GetItemIconByID(needItemCfg.icon))

			
			
			local itemsAni = gGetGameUIManager():AddUIEffect(cellPreview.itemTX[index], "spine/my_spine/jinmai/my_jingmai_dot", true) 
			
			itemsAni:SetDefaultActName(zhiye)
			itemsAni:SetScale(0.45 * self.layoutScale)

        elseif data.jingmais[index]==1 then--激活情况
			--下一个点的动画
			 nextID = index+1
			if nextID >= 17 then nextID =16 end
			local itemsAni2 = gGetGameUIManager():AddUIEffect(cellPreview.itemTX[nextID], "spine/my_spine/jinmai/my_jingmai_kongdot", true) 
			itemsAni2:SetDefaultActName(zhiye)
			itemsAni2:SetScale(0.5 * self.layoutScale)
		
			--已激活的动画
			local itemsAni = gGetGameUIManager():AddUIEffect(cellPreview.itemTX[index], "spine/my_spine/jinmai/my_jingmai_dot", true) 
			itemsAni:SetDefaultActName(zhiye)
			itemsAni:SetScale(0.45 * self.layoutScale)
			

	

        else--无激活
            cellPreview.items[index]:SetImage("my_jingmai", "tm")
        end

        --cellPreview.items[index]:SetCornerImage("skillui", "meng")
        cellPreview.items[index]:subscribeEvent(CEGUI.ItemCell.EventCellClick, JingMaiZhu.HandleTableClick2, self);
    end
	
	if nextID then
		--GetCTipsManager():AddMessageTip("恭喜获得"..nextID)

		cellPreview.items[nextID]:SetImage("my_jingmai", "kong")
		if nextID == 16 then
		--GetCTipsManager():AddMessageTip("恭喜AA 获得"..nextID)
		     cellPreview.items[nextID]:SetImage("my_jingmai", "tm")
		end
	end

end
function JingMaiZhu:HandlefanganClick(arg)
    local function ClickYes(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        local p = require "logic.workshop.jingmai.cjingmaisel":new()
        p.idx = 4 --normal
        p.index = self.fangan --normal
        require "manager.luaprotocolmanager":send(p)

    end
    local function ClickNo(self, args)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        if _instance then
            _instance.DestroyDialog()
        end
    end
    local sb = StringBuilder:new()
    sb:Set("parameter1", GameTable.common.GetCCommonTableInstance():getRecorder(630).value)
    local strMsg = sb:GetString(MHSD_UTILS.get_resstring(11928))
    sb:delete()
    gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes,
            self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))
    --
    --get_resstring(11805)
    --get_msgtipstring(11805)




end
function JingMaiZhu:HandleTableClick2(e)
    local MouseArgs = CEGUI.toMouseEventArgs(e);

    local pCell = CEGUI.toItemCell(MouseArgs.window);

    if (pCell == nil) then

        return true;
    end
    local idx=pCell:getID()
    local index=pCell:GetIndex()


    local tableAllId = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaixiaoguo"):getAllID()
    for k,v in pairs(tableAllId) do
        local xiaoguos = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaixiaoguo"):getRecorder(v)
        if xiaoguos.zhiye==gGetDataManager():GetMainCharacterSchoolID() and xiaoguos.jingmaiid==self.fangan then

            local tip =  require "logic.workshop.jingmai.jingmaitips".ShowTip(xiaoguos.jingmais[index-1],xiaoguos.xingchens[index-1],self.data,index)
            local pos = pCell:GetScreenPosOfCenter()

            SetPositionOffset(tip:GetWindow(),800, 263, 0.1, 0.1)
        end
    end




    local pTable = CEGUI.toItemTable(pCell:getParent());
    if (pTable == nil) then
        return true;
    end
    return true;
end
function JingMaiZhu:HandleguanbiClick(arg)
    self.DestroyDialog()
    require "logic.workshop.jingmai.jingmaitips".DestroyDialog()
end
function JingMaiZhu:HandleqianyuandanClick(arg)
    if self.data.qianyuandan>=12 then
        GetCTipsManager():AddMessageTipById(199000)
        return
    end
    require "logic.workshop.jingmai.jingmaiqianyuandan".getInstanceAndShow()
end
function JingMaiZhu:HandlexingchenjiaClick(arg)

    local e = CEGUI.toMouseEventArgs(arg)
    local touchPos = e.position
    --星辰结晶获取途径
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(629).value))
    if not itemAttrCfg then
        return
    end
    local nPosX = touchPos.x
    local nPosY = touchPos.y
    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    local nType = Commontipdlg.eType.eComeFrom
    --nType = Commontipdlg.eType.eNormal

    commontipdlg:RefreshItem(nType,tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(629).value),nPosX,nPosY)
    commontipdlg.nComeFromItemId = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(629).value)
end

function JingMaiZhu:HandleqiankundanClick(arg)
    if self.data.qianyuandan < 12 then
        GetCTipsManager():AddMessageTipById(199002)
        return
    end
    if self.data.qiankundan>=4 then
        GetCTipsManager():AddMessageTipById(199001)
        return
    end
    require "logic.workshop.jingmai.jingmaiqiankundan".getInstanceAndShow()
end
function JingMaiZhu:HandlejieshaoClick(arg)
    require "logic.workshop.jingmai.jingmaixuanze".getInstanceAndShow()
end
--function JingMaiZhu:HandleClick(arg)
--    self.DestroyDialog()
--    require "logic.item.fabao.JingMaiZhu1".getInstanceAndShow()
--
--end
function JingMaiZhu:HandlexuanzeClick(arg)
    require "logic.workshop.jingmai.jingmailistcell".getInstanceAndShow(self.m_pMainFrame,self.fangan)
end

function JingMaiZhu.getInstance()
    if not _instance then
        _instance = JingMaiZhu:new()
        _instance:OnCreate()
    end
    return _instance
end

function JingMaiZhu.getInstanceAndShow()
    if not _instance then
        _instance = JingMaiZhu:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiZhu.getInstanceNotCreate()
    return _instance
end

function JingMaiZhu.getInstanceOrNot()
    return _instance
end

function JingMaiZhu.GetLayoutFileName()
    return "jingmaizhu.layout"
end

function JingMaiZhu:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiZhu)
    self:ClearData()
    return self
end

function JingMaiZhu.DestroyDialog()
    if not _instance then
        return
    end
    if not _instance.m_bCloseIsHide then
        _instance:OnClose()
        _instance = nil
    else
        _instance:ToggleOpenClose()
    end
end
function JingMaiZhu.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiZhu:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiZhu:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function JingMaiZhu:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function JingMaiZhu:ClearCellAll()
end

function JingMaiZhu:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return JingMaiZhu
