require "logic.dialog"

CharacterInfoDlg = {}
setmetatable(CharacterInfoDlg, Dialog)
CharacterInfoDlg.__index = CharacterInfoDlg

local _instance

local BIGRED = 32037
local BIGBLUE	= 32038

function CharacterInfoDlg.getInstance()
    if not _instance then
        _instance = CharacterInfoDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function CharacterInfoDlg.getInstanceAndShow()
    if not _instance then
        _instance = CharacterInfoDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function CharacterInfoDlg.getInstanceNotCreate()
    return _instance
end

function CharacterInfoDlg.DestroyDialog()


    if _instance then
    
        if _instance.spine then
            _instance.spine:delete()
            _instance.spine = nil
        end
        
        if _instance.spriteBack then
            _instance.spriteBack:getGeometryBuffer():setRenderEffect(nil)
        end
        
        
        gGetDataManager().m_EventMainCharacterDataChange:RemoveScriptFunctor( _instance.m_eventData )
        gGetDataManager().m_EventMainCharacterExpChange:RemoveScriptFunctor(_instance.m_eventExp)
        gGetDataManager().m_EventMainCharacterHpMpChange:RemoveScriptFunctor(_instance.m_eventHpMp)
        gGetDataManager().m_EventMainBattlerAttributeChange:RemoveScriptFunctor(_instance.m_eventMainBattlerAtt)
        gGetDataManager().m_EventExtendSkillMapChange:RemoveScriptFunctor(_instance.m_eventSkillMap)
        gGetDataManager().m_EventMainCharacterQiLiChange:RemoveScriptFunctor(_instance.m_eventQili)
        Dialog.OnClose(_instance)
        _instance = nil
    end
    
end

function CharacterInfoDlg.ToggleOpenClose()
    if not _instance then
        _instance = CharacterInfoDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function CharacterInfoDlg.GetLayoutFileName()
    return "charecterinfo.layout"
end

function CharacterInfoDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CharacterInfoDlg)
    return self
end


function CharacterInfoDlg:UpdateHPMPStore() 
    local role_hp_buffid = 500009
    local role_mp_buffid = 500010
    local pet_hp_buffid = 500138
    local pet_mp_buffid = 500139
    local pet_loy_buffid = 500140
    local hpstore = gGetDataManager():GetHPMPStoreByID(role_hp_buffid)
    local mpstore = gGetDataManager():GetHPMPStoreByID(role_mp_buffid)
    local pethpstore = gGetDataManager():GetHPMPStoreByID(pet_hp_buffid)
    local petmpstore = gGetDataManager():GetHPMPStoreByID(pet_mp_buffid)
    local petloystore = gGetDataManager():GetHPMPStoreByID(pet_loy_buffid)
    local hpreserve = 0
    local nItem = BIGRED
    local hpconfig = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(BIGRED)
    if hpconfig and not ( hpconfig.effect:size() <= 0 ) then
       hpreserve = hpconfig.effect[0]
    end
    local mpreserve = 0
    local mpconfig = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(BIGRED)
    if mpconfig and not ( mpconfig.effect:size() <= 0 ) then
        mpreserve = mpconfig.effect[0]
    end
    local nhpscale = hpstore/hpreserve
    self.m_gressHP:setProgress(nhpscale)
    self.m_gressHP:setText("当前剩余：" .. hpstore)

    local nmpscale = mpstore/mpreserve
    self.m_gressMP:setProgress( nmpscale )
    self.m_gressMP:setText("当前剩余：" .. mpstore)

end
function CharacterInfoDlg.UpdateAllScoreInstance()
    
    if _instance then
        _instance:UpdateAllScore()
    end

end
function CharacterInfoDlg.UpdateHpMpStoreInstance()
    if _instance then
        _instance:UpdateHPMPStore()
    end

end

function CharacterInfoDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7) 
        -- 保存动画实例
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function CharacterInfoDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_eventData = gGetDataManager().m_EventMainCharacterDataChange:InsertScriptFunctor(CharacterInfoDlg.UpdatePlayerData) 
    self.m_eventExp = gGetDataManager().m_EventMainCharacterExpChange:InsertScriptFunctor(CharacterInfoDlg.UpdatePlayerData)
    self.m_eventHpMp = gGetDataManager().m_EventMainCharacterHpMpChange:InsertScriptFunctor(CharacterInfoDlg.UpdatePlayerData)
    self.m_eventMainBattlerAtt = gGetDataManager().m_EventMainBattlerAttributeChange:InsertScriptFunctor(CharacterInfoDlg.UpdatePlayerData)
    self.m_eventSkillMap = gGetDataManager().m_EventExtendSkillMapChange:InsertScriptFunctor(CharacterInfoDlg.UpdatePlayerData)
    self.m_eventQili = gGetDataManager().m_EventMainCharacterQiLiChange:InsertScriptFunctor(CharacterInfoDlg.UpdatePlayerData)
    SetPositionOfWindowWithLabel(self:GetWindow())

    self.m_bg = CEGUI.toFrameWindow(winMgr:getWindow("charecterinfo"))
    self.m_itemcellHP = CEGUI.toItemCell(winMgr:getWindow("charecterinfo/left/chuxudiban/tubian"))
    self.m_gressHP = CEGUI.toProgressBar(winMgr:getWindow("charecterinfo/left/chubei/hpchubei"))
    self.m_itemcellMP = CEGUI.toItemCell(winMgr:getWindow("charecterinfo/left/chuxudiban2/tubiao2"))
    self.m_gressMP = CEGUI.toProgressBar(winMgr:getWindow("charecterinfo/left/chubei2/chubeisp"))
    self.m_btnScoreExchange = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/right/wencaigo2"))
    self.m_btnHelpCount = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/right/wencaigo21"))
    self.m_btnAdd1 = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/left/jiahao1"))
    self.m_btnAdd2 = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/left/jiahao2"))


    self.m_txtSchool = winMgr:getWindow("charecterinfo/youbg2/zhiyedi/zhiye")
    self.m_txtFaction = winMgr:getWindow("charecterinfo/youbg2/gonghuidi/gonghui")
    
    self.m_btnSchool = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/youbg2/btn"))
    self.m_btnFaction = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/youbg2/btn1"))
    self.m_RedPackBtn = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/youbg2/btn2"))
    self.m_RedPackBtn:subscribeEvent("MouseClick", self.HandleBtnRedPackClick, self);
    self.m_btnFaction:subscribeEvent("Clicked", function()
        if self.m_btnFaction.animation then
            self.m_btnFaction.animation:stop()
        end
        if self.m_btnSchool.animation then
            self.m_btnSchool.animation:stop()
        end
        CharacterInfoDlg.HandlerBtnFactionClicked(self)
    end, self)
    self.m_btnSchool:subscribeEvent("Clicked",  function()
        if self.m_btnFaction.animation then
            self.m_btnFaction.animation:stop()
        end
        if self.m_btnSchool.animation then
            self.m_btnSchool.animation:stop()
        end
        CharacterInfoDlg.HandlerBtnSchoolClicked(self)
    end, self)

    self.m_btnScoreExchange:subscribeEvent("Clicked", CharacterInfoDlg.HandlerBtnScoreExchangeClicked, self)
    self.m_btnAdd1:subscribeEvent("Clicked", CharacterInfoDlg.HandlerBtnAdd1Clicked, self)
	self:addButtonAnimation(self.m_btnAdd1, "studyBtnPress")
    self.m_btnAdd2:subscribeEvent("Clicked", CharacterInfoDlg.HandlerBtnAdd2Clicked, self)
	self:addButtonAnimation(self.m_btnAdd2, "studyBtnPress")
    self.m_itemcellHP:subscribeEvent("MouseButtonUp", CharacterInfoDlg.HandleItemCellHpBtnUp, self)
    self.m_itemcellMP:subscribeEvent("MouseButtonUp", CharacterInfoDlg.HandleItemCellMpBtnUp, self)
    self.m_btnHelpCount:subscribeEvent("Clicked", CharacterInfoDlg.HandlerBtnHelpCountClicked, self)
    self:GetCloseBtn():removeEvent("Clicked")
    self:GetCloseBtn():subscribeEvent("Clicked", CharacterLabel.DestroyDialog, nil)
    self.m_AllTxtResName = 
    {
        "charecterinfo/right/221","charecterinfo/right/223","charecterinfo/right/224",
         "charecterinfo/right/225", "charecterinfo/right/222", "charecterinfo/right/227",
         "charecterinfo/right/226"		
    }
    self.m_txtXinyong = winMgr:getWindow("charecterinfo/right/xinyongzhi1")

    self.m_listScoreName = {}
    for index , value in pairs( self.m_AllTxtResName ) do
        local tempUi = winMgr:getWindow(value)
        table.insert(self.m_listScoreName, tempUi)
    end
    
    self.m_ListScoreEnum = {}
    table.insert(self.m_ListScoreEnum , fire.pb.attr.RoleCurrency.PROF_CONTR)
    for index = fire.pb.attr.RoleCurrency.GUILD_DED ,  fire.pb.attr.RoleCurrency.FRIEND_SCORE do
        table.insert( self.m_ListScoreEnum , index)
    end
    
    self:UpdateRestoreItem()
    self:UpdateAllScore()
    
    self:UpdateHPMPStore()
    
    local p = require("protodef.fire.pb.creqroleinfo"):new()
    p.reqkey = 1
    LuaProtocolManager:send(p)

    
    self.m_txtPlayerName = winMgr:getWindow("charecterinfo/left/diban/baojudaduiduizhang")
    self.m_txtLvl = winMgr:getWindow("charecterinfo/left/diban/LvNum")
    self.m_txtID = winMgr:getWindow("charecterinfo/left/123456")
    self.m_txtHonour = winMgr:getWindow("charecterinfo/left/text2/jinshi")
    self.m_btnToHonorDlg = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/left/chengweibutton"))
    self.m_imgSchool = winMgr:getWindow("charecterinfo/left/zhiyetubiao")
    self.m_btnToHonorDlg:subscribeEvent("Clicked", self.HandleClickBtnAppellation, self)

    self.m_btnIntro = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/tishibutton"))
    self.m_gressExp = CEGUI.toProgressBar(winMgr:getWindow("charecterinfo/jingyantiao"))
    self.m_txtExpSurplus = winMgr:getWindow("charecterinfo/0")
    self.m_btnIntro:subscribeEvent("Clicked", self.HandleClikBtnIntro1, self)

    self.m_xyzButton = CEGUI.toPushButton(winMgr:getWindow("charecterinfo/left/chengweibutton1"))
    self.m_xyzButton:setVisible(true)
    self.m_xyzButton:subscribeEvent("Clicked", self.HandleClickXYZButton, self)
    self:addButtonAnimation(self.m_xyzButton, "studyBtnPress")
    
    self:addButtonAnimation(self.m_btnSchool, "studyBtnPress")--后续修改
    self:addButtonAnimation(self.m_btnFaction, "studyBtnPress")--后续修改
    self:addButtonAnimation(self.m_btnScoreExchange, "studyBtnPress")
    self:addButtonAnimation(self.m_btnHelpCount, "studyBtnPress")

    local send = require "protodef.fire.pb.attr.capplyyingfuexprience":new()
    require "manager.luaprotocolmanager":send(send)

    self.m_listRoleSpine   = winMgr:getWindow("charecterinfo/left/aimuti")     

    self:UpdatePlayerData()
    self:ShowPlayerSpine()
    self:UpdateFactionAndSchool()
end

function CharacterInfoDlg:HandleClickXYZButton(arg)
    local tipsStr = require("utils.mhsdutils").get_resstring(11620)
    if IsPointCardServer() then
        tipsStr = require("utils.mhsdutils").get_resstring(11625)
    end
    local title = require("utils.mhsdutils").get_resstring(11619)
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function CharacterInfoDlg:UpdateFactionAndSchool()
    local nSchoolName = gGetDataManager():GetMainCharacterSchoolName()
    self.m_txtSchool:setText(nSchoolName)
    local datamanager = require "logic.faction.factiondatamanager"
    if not datamanager.factionid then
        local text =  MHSD_UTILS.get_resstring(11290)
        self.m_txtFaction:setText(text)
    elseif datamanager.factionid>0 then
        self.m_txtFaction:setText(datamanager.factionname)
    else
        local text =  MHSD_UTILS.get_resstring(11290)
        self.m_txtFaction:setText(text)
    end
    if datamanager then
        self.m_btnFaction:setEnabled(datamanager:IsHasFaction())
    end
    local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    local mapRecord =BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(schoolConfig.schooljobmapid)
    local mapName = mapRecord.mapName
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", mapName)
    local msg=strbuilder:GetString(MHSD_UTILS.get_resstring(11322))
    strbuilder:delete()
    self.m_btnSchool:setText(msg)
    
end

function CharacterInfoDlg:HandleBtnRedPackClick(args)
    require "logic.qiandaosongli.fuliplane".getInstanceAndShow()
end

function CharacterInfoDlg:HandleClikBtnIntro1(e)

    local title = MHSD_UTILS.get_resstring(11328)
    local strAllString = MHSD_UTILS.get_resstring(11329)
    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(gGetDataManager():getServerLevel()))
    strbuilder:Set("parameter2", tostring(gGetDataManager():getServerLevelDays()))
    strAllString = strbuilder:GetString(strAllString)
    strbuilder:delete()
    local tips1 = require "logic.workshop.tips1"
    tips1.getInstanceAndShow(strAllString, title)

    return true
end
function CharacterInfoDlg:HandleClickBtnAppellation(e)
    local dlg = require "logic.title.titledlg".getInstanceAndShow()

    return true
end

function CharacterInfoDlg:UpdateRestoreItem()
    local nCureItemID = BIGRED;
    local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nCureItemID);
    if itembean then
        _instance.m_itemcellHP:SetImage(gGetIconManager():GetItemIconByID(itembean.icon))
    end

    local nReMpItemID = BIGBLUE
    local itemMp = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nReMpItemID)
    if itemMp then
        _instance.m_itemcellMP:SetImage(gGetIconManager():GetItemIconByID(itemMp.icon))
    end
    
    _instance.m_itemcellHP:SetBackGroundEnable(true)

    _instance.m_itemcellMP:SetBackGroundEnable(true)
end

function CharacterInfoDlg:UpdateAllScore()
    local data = gGetDataManager():GetMainCharacterData()
    for index, value in pairs( self.m_listScoreName ) do
        local tempScoreValue = data:GetScoreValue( self.m_ListScoreEnum[fire.pb.attr.RoleCurrency.GUILD_DKP+index-1] )
        if index == 1 then
            tempScoreValue = data:GetScoreValue(fire.pb.attr.RoleCurrency.PROF_CONTR)
        end
        value:setText(tempScoreValue )
    end
    local xinyong = data:GetScoreValue(fire.pb.attr.RoleCurrency.EREDITPOINT_SCORE)
    self.m_txtXinyong:setText(xinyong)
end

function CharacterInfoDlg:UpdatePlayerData()
    local data = gGetDataManager():GetMainCharacterData()
    local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    _instance.m_txtLvl:setText(tostring(nLvl))
    _instance.m_txtPlayerName:setText(gGetDataManager():GetMainCharacterName())
    _instance.m_txtID:setText(gGetDataManager():GetMainCharacterID())
    local crc = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(nLvl)
    if crc == nil then
    else
        if crc.nextexp == 0 then
            _instance.m_gressExp:setText(data.exp)
            _instance.m_gressExp:setProgress(0.0)
        else
            local nExpScale = data.exp / crc.nextexp
            _instance.m_gressExp:setText(data.exp .. "/" .. crc.nextexp)
            _instance.m_gressExp:setProgress(nExpScale)
        end
    end
    local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    _instance.m_imgSchool:setProperty("Image", schoolConfig.schooliconpath)
    local nStrHonor = gGetDataManager():GetCurTilte()
    local splited = false
    nStrHonor, splited = SliptStrByCharCount(nStrHonor, 14)
    if splited then
        nStrHonor, splited = SliptStrByCharCount(nStrHonor, 12)
        nStrHonor = nStrHonor .."..."
    end
    _instance.m_txtHonour:setText(nStrHonor)
end

function CharacterInfoDlg:ShowPlayerSpine()
    local npcid = gGetDataManager():GetMainCharacterShape()
    local ids = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getAllID()
    for index, var in pairs(ids) do
        local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(var)
        if conf ~=nil and  npcid ==  conf.model then
            self:createSpineSprite( conf ) 
            break;			
        end 
    end
end

function CharacterInfoDlg.performPostRenderFunctions(id)
    if CharacterInfoDlg:getInstance():GetWindow():getAlpha() > 0.2 and CharacterInfoDlg:getInstance().spine then
        CharacterInfoDlg:getInstance().spine:RenderUISprite()
    end
    local instance = CharacterInfoDlg:getInstance()
    if(instance._spine_sprite ~= nil) then
       print("xuanran")
        Nuclear.GetEngine():GetRenderer():DrawPicture( instance._spine_sprite, 
            Nuclear.NuclearFRectt(instance.__x -187.5, instance.__y -187.5, instance.__x +187.5, instance.__y +187.5),  
            Nuclear.NuclearColor(0xffffffff) )
    end
end
 
function CharacterInfoDlg:createSpineSprite( conf )
    if not conf then return end
    local pos = self.m_listRoleSpine:GetScreenPosOfCenter()
    local loc = Nuclear.NuclearPoint(pos.x, pos.y)
    self.__x = pos.x
    self.__y = pos.y
    if not self.spine then
         print(conf.spine)
        self._spine_sprite = Nuclear.GetEngine():GetRenderer():LoadPicture("/model/" .. conf.spine .."/" ..conf.spine ..".png")
        print("iinfo wh create sprite success", self._spine_sprite)

        local winMgr = CEGUI.WindowManager:getSingleton()
        self.spriteBack = winMgr:getWindow("charecterinfo/left/guge")
        self.spriteBack:getGeometryBuffer():setRenderEffect(
        GameUImanager:createXPRenderEffect(0, CharacterInfoDlg.performPostRenderFunctions))
    end
end


function CharacterInfoDlg:HandleItemCellHpBtnUp(args)
    local e = CEGUI.toMouseEventArgs(args)
    local touchPos = e.position
    
    local nPosX = touchPos.x
    local nPosY = touchPos.y
    
    local nItemId = BIGRED
    
    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    local nType = Commontipdlg.eType.eNormal

    commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    return true
end
function CharacterInfoDlg:HandleItemCellMpBtnUp( args )
    print( "CharacterInfoDlg:HandleItemCellMpBtnUp" )
    local e = CEGUI.toMouseEventArgs(args)
    local touchPos = e.position
    
    local nPosX = touchPos.x
    local nPosY = touchPos.y
    
    local nItemId = BIGBLUE
    
    local Commontipdlg = require "logic.tips.commontipdlg"
    local commontipdlg = Commontipdlg.getInstanceAndShow()
    local nType = Commontipdlg.eType.eNormal

    commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    return true
end
function CharacterInfoDlg:HandlerBtnHelpCountClicked(args)
    print("HandlerBtnHelpCountClicked")
    local p = require "protodef.fire.pb.creqhelpcountview":new()
    require "manager.luaprotocolmanager".getInstance():send(p)
end
function CharacterInfoDlg:HandlerBtnFactionClicked(args)

    if GetBattleManager():IsInBattle() then
        GetCTipsManager():AddMessageTipById(144879)
        CharacterLabel.DestroyDialog()
        return
    end
    local p = require "protodef.fire.pb.clan.centerclanmap":new()
    require "manager.luaprotocolmanager".getInstance():send(p)
    CharacterLabel.DestroyDialog()
end
function CharacterInfoDlg:HandlerBtnSchoolClicked(args)
    
    if GetTeamManager() and  not GetTeamManager():CanIMove() then
    
        if GetChatManager() then
            GetChatManager():AddTipsMsg(150030)	
        end
        return true
    end

    local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())
    local  nMapID = schoolConfig.schooljobmapid
    local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapID)
    
    if mapRecord == nil then	
        return true;
    end

    if mapRecord.maptype == 1 or mapRecord.maptype == 2  then
    
        local randX = mapRecord.bottomx - mapRecord.topx
        randX = mapRecord.topx + math.random(0, randX)

        local randY = mapRecord.bottomy - mapRecord.topy
        randY = mapRecord.topy + math.random(0, randY)
        gGetNetConnection():send(fire.pb.mission.CReqGoto(nMapID, randX, randY));
        if gGetScene()  then
            gGetScene():EnableJumpMapForAutoBattle(false);
        end
        CharacterLabel.DestroyDialog()
    else
        return false
    end	
        
    return true;
    
end
function CharacterInfoDlg.HandlerBtnAdd2Clicked( args )
    local dlg = require "logic.shop.npcshop":getInstanceAndShow()
    dlg:setShopType( SHOP_TYPE.WINESHOP )
end
function CharacterInfoDlg.HandlerBtnAdd1Clicked( args )
    local dlg = require "logic.shop.npcshop":getInstanceAndShow()
    dlg:setShopType( SHOP_TYPE.WINESHOP )
end
function CharacterInfoDlg:HandlerBtnScoreExchangeClicked(args)
    local p = require "protodef.fire.pb.csendhelpsw":new()
    require "manager.luaprotocolmanager".getInstance():send(p)
    return true
end

return CharacterInfoDlg