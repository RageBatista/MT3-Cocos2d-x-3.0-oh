local Equiptipmaker = {}



--[[
local NORMAL_YELLOW = "fffbdc47"
local NORMAL_BLUE = "ff00d8ff " -- "ff5fbae0"  
local NORMAL_GREEN = "ff17ed15 " --"ff33ff00" 
local NORMAL_WHITE = "fffff2df"
local NORMAL_PURPLE = "ffff35fd"
--]]

local NORMAL_YELLOW = "fffbdc47"
local NORMAL_BLUE = "FF00b1ff" -- "ff5fbae0"
local NORMAL_GREEN = "FF06cc11" --"ff33ff00"
local NORMAL_WHITE = "fffff2df"
local NORMAL_PURPLE = "FFd200ff"

local GemColor = "ff17ed15" --"FF009ddb"

function Equiptipmaker.makeTip(richBox, nItemId, pObj, nItemIdInBody, pObjInBody)
    Equiptipmaker.color_NORMAL_YELLOW = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_YELLOW))
    Equiptipmaker.color_NORMAL_WHITE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_WHITE))
    Equiptipmaker.color_NORMAL_GREEN = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_GREEN))
    Equiptipmaker.color_NORMAL_BLUE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_BLUE))
    Equiptipmaker.color_NORMAL_PURPLE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(NORMAL_PURPLE))

    Equiptipmaker.color_GemColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(GemColor))

    local colorStr = richBox:GetColourString():c_str()
    if colorStr ~= "FFFFFFFF" then
        Equiptipmaker.color_NORMAL_WHITE = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(colorStr))
    end
  
    LogInfo("Equiptipmaker.maketips(nItemId,pObj)")
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if not itemAttrCfg then
        LogInfo("Equiptipmaker:makeTip=error=self.nItemId" .. nItemId)
        return false
    end
    local itemtypeid = itemAttrCfg.itemtypeid
    local pEquipData = nil
    if pObj then
        pEquipData = pObj
    end

   
    --local nItemIdInBody = 0
    --local pObjInBody = nil
    Equiptipmaker.makeLine(richBox)

    if IsJinMaiType(itemtypeid) then

    else
       
               --基础属性
        Equiptipmaker.makeBaseProperty(richBox, nItemId, pEquipData, nItemIdInBody, pObjInBody)
        --附加属性
        Equiptipmaker.makeAddProperty(richBox, nItemId, pEquipData)
        --装备技能
        Equiptipmaker.makeSkill(richBox, nItemId, pEquipData)
        --打造者
        Equiptipmaker.makeProducter(richBox, nItemId, pEquipData)
        --宝石
        Equiptipmaker.makeGem(richBox, nItemId, pEquipData)
        --打符
        Equiptipmaker.makeFumoProperty(richBox, nItemId, pEquipData)
        --耐久
        Equiptipmaker.makeEndure(richBox, nItemId, pEquipData)
        --评分
        Equiptipmaker.makeScore(richBox, nItemId, pEquipData)
        --适合角色
        Equiptipmaker.makeSex(richBox, nItemId, pEquipData)
      
     
    end
    --适合职业
    Equiptipmaker.makeCareer(richBox, nItemId, pEquipData)
    return true
end

function Equiptipmaker.makeLine(richBox)
    --richBox:AppendImage(CEGUI.String("common_pack"),CEGUI.String("goods_fengexian"))
    richBox:AppendBreak()
end

function Equiptipmaker.GetMinAndMax(vMin, vMax)
    local nMinNum = vMin:size()
    local nMaxNum = vMax:size()
    local nMin = 0
    local nMax = 0
    if nMinNum > 0 then
        nMin = vMin[0]
    end
    if nMaxNum > 0 then
        nMax = vMax[nMaxNum - 1]
    end
    return nMin, nMax
end

function Equiptipmaker.GetPropertyStrData(nEquipId, vCellData)
    local eauipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
    if not eauipAttrCfg then
        return
    end
    local nbaseAttrId = eauipAttrCfg.baseAttrId
    local eauipAddAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipiteminfo"):getRecorder(nbaseAttrId)
    if eauipAddAttrCfg == nil then
        return
    end

    local vAllId = {}
    vAllId[#vAllId + 1] = {}
    vAllId[#vAllId].nId = eauipAddAttrCfg.shuxing1id
    vAllId[#vAllId].vMin = eauipAddAttrCfg.shuxing1bodongduanmin
    vAllId[#vAllId].vMax = eauipAddAttrCfg.shuxing1bodongduanmax
    vAllId[#vAllId + 1] = {}
    vAllId[#vAllId].nId = eauipAddAttrCfg.shuxing2id
    vAllId[#vAllId].vMin = eauipAddAttrCfg.shuxing2bodongduanmin
    vAllId[#vAllId].vMax = eauipAddAttrCfg.shuxing2bodongduanmax
    vAllId[#vAllId + 1] = {}
    vAllId[#vAllId].nId = eauipAddAttrCfg.shuxing3id
    vAllId[#vAllId].vMin = eauipAddAttrCfg.shuxing3bodongduanmin
    vAllId[#vAllId].vMax = eauipAddAttrCfg.shuxing3bodongduanmax
    local strBolangzi = MHSD_UTILS.get_resstring(11001)
    for nIndex = 1, #vAllId do
        local objPropertyData = vAllId[nIndex]
        local nPropertyId = objPropertyData.nId
        local nTypeNameId = math.floor(nPropertyId / 10)
        nTypeNameId = nTypeNameId * 10
        nPropertyId = nTypeNameId
        local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
        if propertyCfg and propertyCfg.id ~= -1 then
            local strPropertyName = propertyCfg.name
            if strPropertyName == nil then
                strPropertyName = "empty"
            end
            local nMin, nMax = Equiptipmaker.GetMinAndMax(objPropertyData.vMin, objPropertyData.vMax)
            vCellData[#vCellData + 1] = {}
            vCellData[#vCellData].strPropertyName = strPropertyName
            if nMin == nMax then
                vCellData[#vCellData].strAddValue = "+" .. tostring(nMin)
            else
                vCellData[#vCellData].strAddValue = "+" .. tostring(nMin) .. strBolangzi .. tostring(nMax)

            end
        end
    end

end

--vCellData = {strPropertyName ,strAddValue }
function Equiptipmaker.makeBaseProperty_range(richBox, nItemId)

    local strJichushuxing = require "utils.mhsdutils".get_resstring(122)
    richBox:AppendText(CEGUI.String(strJichushuxing), Equiptipmaker.color_NORMAL_YELLOW)
    richBox:AppendBreak()

    local vCellData = {}
    Equiptipmaker.GetPropertyStrData(nItemId, vCellData)

    for nIndex = 1, #vCellData do
        local strTitleName = vCellData[nIndex].strPropertyName
        local strRange = vCellData[nIndex].strAddValue
        strTitleName = "  " .. strTitleName .. "  " .. strRange
        strTitleName = CEGUI.String(strTitleName)

        richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_WHITE)
        richBox:AppendBreak()
    end
end

--pObjInBody==nil   baseitemid
function Equiptipmaker.makeBaseProperty(richBox, nItemId, pEquipData, nItemIdInBody, pObjInBody)

    if not pEquipData then
        Equiptipmaker.makeBaseProperty_range(richBox, nItemId)
        return
    end
    --if pEquipData then
    local vcBaseKey = pEquipData:GetBaseEffectAllKey()
    if #vcBaseKey <= 0 then
        return
    end
    local strJichushuxing = require "utils.mhsdutils".get_resstring(122)
    richBox:AppendText(CEGUI.String(strJichushuxing), Equiptipmaker.color_NORMAL_YELLOW)
    richBox:AppendBreak()

    for nIndex = 1, #vcBaseKey do
        local nBaseId = vcBaseKey[nIndex]
        local nBaseValue = pEquipData:GetBaseEffect(nBaseId)
        if nBaseValue ~= 0 then
            local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nBaseId)
            if propertyCfg and propertyCfg.id ~= -1 then
                local strTitleName = propertyCfg.name
                local nValue = math.abs(nBaseValue)
                if nBaseValue > 0 then
                    strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
                elseif nBaseValue < 0 then
                    strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
                end
                strTitleName = "  " .. strTitleName
                strTitleName = CEGUI.String(strTitleName)
                richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_WHITE)
                --=====================================
                if pObjInBody then
                    local nValueInBody = Equiptipmaker.getPropertyValue(nBaseId, pObjInBody)
                    local nCha = nBaseValue - nValueInBody
                    if nCha > 0 then
                        richBox:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_up"));
                    elseif nCha < 0 then
                        richBox:AppendImage(CEGUI.String("shopui"), CEGUI.String("shop_down"));
                    end
                end
                --=====================================

                richBox:AppendBreak()
            end

        end
    end
    --end
end

function Equiptipmaker.getPropertyValue(nBaseId, pObjInBody)
    local pEquipData = nil
    if pObjInBody then
        pEquipData = pObjInBody
    end

    if pEquipData then
        local vcBaseKey = pEquipData:GetBaseEffectAllKey()
        for nIndex = 1, #vcBaseKey do
            local nBaseIdInBody = vcBaseKey[nIndex]
            local nBaseValue = pEquipData:GetBaseEffect(nBaseId)
            if nBaseId == nBaseIdInBody then
                return nBaseValue
            end
        end
    end
    return 0
end

function Equiptipmaker.makeAddProperty(richBox, nItemId, pEquipData)

    if not pEquipData then
        return
    end

    -- if pEquipData then
    local vPlusKey = pEquipData:GetPlusEffectAllKey()
    for nIndex = 1, #vPlusKey do
        local nPlusId = vPlusKey[nIndex]
        local mapPlusData = pEquipData:GetPlusEffect(nPlusId)
        if mapPlusData.attrvalue ~= 0 then

            local nPropertyId = mapPlusData.attrid
            local nPropertyValue = mapPlusData.attrvalue
            local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
            if propertyCfg and propertyCfg.id ~= -1 then
                local strTitleName = propertyCfg.name
                local nValue = math.abs(nPropertyValue)
                if nPropertyValue > 0 then
                    strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
                else
                    strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
                end
                local strEndSpace = "  "
                local strBeginSpace = "  "
                strTitleName = strTitleName .. strEndSpace
                strTitleName = strBeginSpace .. strTitleName

                strTitleName = CEGUI.String(strTitleName)
                richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_BLUE)
            end
        end --if end
    end --for end
    --========================
    if #vPlusKey > 0 then
        richBox:AppendBreak()
    end
    -- end --if end

end

--[[
11286	��ʱ
11287	��Ч����
11288	ʣ��
��ʱ���� + 10  ʣ�� 3�� 
��Ч����
--]]




function Equiptipmaker.makeFumoProperty(richBox, nItemId, pEquipData)
    if not pEquipData then
        return
    end

    local nFumoCount = pEquipData:getFumoCount()
    if nFumoCount <= 0 then
        return
    end

    local strLinshizi = require "utils.mhsdutils".get_resstring(11286)
    local strLeftzi = require "utils.mhsdutils".get_resstring(11288)
    local strEndTozi = require "utils.mhsdutils".get_resstring(11287)

    --richBox:AppendText(CEGUI.String(strJichushuxing),Equiptipmaker.color_NORMAL_YELLOW)
    --richBox:AppendBreak()

    for nIndexCount = 0, nFumoCount - 1 do
        local vFumoKey = pEquipData:GetFumoIdWithIndex(nIndexCount)

        local bHaveFumoInTime = require("logic.tips.commontiphelper").isHaveFumoInTime(pEquipData, nIndexCount)
        if bHaveFumoInTime then
            for nIndex = 0, vFumoKey:size() - 1 do
                local nFumoId = vFumoKey[nIndex]
                local nFumoValue = pEquipData:GetFumoValueWithId(nIndexCount, nFumoId)

                local propertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nFumoId)
                if propertyCfg and propertyCfg.id ~= -1 then
                    local strTitleName = propertyCfg.name
                    strTitleName = strLinshizi .. strTitleName
                    local nValue = math.abs(nFumoValue)
                    if nFumoValue > 0 then
                        strTitleName = strTitleName .. " " .. "+" .. tostring(nValue)
                    elseif nFumoValue < 0 then
                        strTitleName = strTitleName .. " " .. "-" .. tostring(nValue)
                    end
                    strTitleName = CEGUI.String(strTitleName)
                    richBox:AppendText(strTitleName, Equiptipmaker.color_NORMAL_GREEN)
                    --richBox:AppendBreak()
                    --richBox:AppendBreak()
                end
                -------------------------------
                local fumoData = pEquipData:getFumoDataWidthIndex(nIndexCount)
                local nFomoEndTime = 0
                if fumoData then
                    nFomoEndTime = fumoData.nFomoEndTime
                end
                if nFomoEndTime > 0 then
                    local nServerTime = gGetServerTime() / 1000
                    local nLeftSecond = nFomoEndTime / 1000 - nServerTime
                    local timeStr = require("logic.tips.commontiphelper").GetLeftTimeString(nLeftSecond) --Equiptipmaker.GetLeftTimeString(nLeftSecond)
                    strEndTozi = "  " .. strLeftzi .. timeStr
                    strEndTozi = CEGUI.String(strEndTozi)
                    richBox:AppendText(strEndTozi, Equiptipmaker.color_NORMAL_GREEN)
                    richBox:AppendBreak()
                end
                -------------------------------
            end
        end
    end
end

--1237 %d��%d��%d�� 
--1238 %dʱ%d��%d��
--1239 %d��%d��
--1240 %dСʱ%d����
--1241 %d����
--1242 %dСʱ

function Equiptipmaker.GetLeftTimeString(seconds)
    local strHourzi = require "utils.mhsdutils".get_resstring(1242)
    local strMinutezi = require "utils.mhsdutils".get_resstring(1241)

    local hours = math.floor(seconds / 3600)
    local leftMinSec = seconds - hours * 3600

    local mins = math.floor(leftMinSec / 60)
    local secs = math.floor(leftMinSec - mins * 60)

    if hours < 0 then
        hours = 0
    end
    if mins < 0 then
        mins = 0
    end
    if secs < 0 then
        secs = 0
    end

    local strTime = ""
    if hours > 0 then

        ---local sb = StringBuilder:new()
        --sb:Set("parameter1", strTitle)
        --sb:Set("parameter2", tostring(nStep))
        --strMsg = sb:GetString(strMsg)
        --sb:delete()

        --strTime = hours ..strHourzi.. mins..strMinutezi
        strTime = string.format(strHourzi, hours)
        -- strTime = strTime..string.format(strMinutezi,mins)

    else
        strTime = string.format(strMinutezi, mins)
    end
    return strTime
end

function Equiptipmaker.makeGem(richBox, nItemId, pEquipData)

    if not pEquipData then
        return
    end

    local vcGemList = pEquipData:GetGemlist()
    if vcGemList:size() <= 0 then
        return
    end

    local strBaoshishuxing = require "utils.mhsdutils".get_resstring(125)
    strBaoshishuxing = CEGUI.String(strBaoshishuxing)
    richBox:AppendText(strBaoshishuxing, Equiptipmaker.color_NORMAL_YELLOW)
    richBox:AppendBreak();

    for nIndex = 0, vcGemList:size() - 1 do
        local nGemId = vcGemList[nIndex]
        local gemEffectTable = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nGemId)
        local itemAttrTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nGemId)
        local strTitleName = "  "
        if itemAttrTable then
            strTitleName = strTitleName .. itemAttrTable.name
            strTitleName = strTitleName .. "  "
        end
        if gemEffectTable then
            strTitleName = strTitleName .. gemEffectTable.effectdes
        end

        strTitleName = CEGUI.String(strTitleName)
        richBox:AppendText(strTitleName, Equiptipmaker.color_GemColor)
        richBox:AppendBreak()
    end


end

function Equiptipmaker.makeSkill(richBox, nItemId, pEquipData)

    if not pEquipData then
        return
    end
    local nTejiId = pEquipData.skillid
    local nTexiaoId = pEquipData.skilleffect

    local texiaoTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTexiaoId)
    if texiaoTable and texiaoTable.id ~= -1 then
        local strTeXiaozi = require "utils.mhsdutils".get_resstring(11003)
        strTeXiaozi = "  " .. strTeXiaozi .. " " .. texiaoTable.name

        strTeXiaozi = CEGUI.String(strTeXiaozi)
        richBox:AppendText(strTeXiaozi, Equiptipmaker.color_NORMAL_PURPLE)
        richBox:AppendBreak();
    end

    local tejiTable = BeanConfigManager.getInstance():GetTableByName("skill.cequipskillinfo"):getRecorder(nTejiId)
    if tejiTable and tejiTable.id ~= -1 then
        local strTejizi = require "utils.mhsdutils".get_resstring(11002)
        strTejizi = "  " .. strTejizi .. " " .. tejiTable.name

        strTejizi = CEGUI.String(strTejizi)
        richBox:AppendText(strTejizi, Equiptipmaker.color_NORMAL_PURPLE)
        richBox:AppendBreak();
    end
end

function Equiptipmaker.makeEndure(richBox, nItemId, pEquipData)
    if not pEquipData then
        return
    end
    local nEndure = pEquipData.endure
    local strNaijiuzi = require "utils.mhsdutils".get_resstring(11000)
    strNaijiuzi = strNaijiuzi .. "：" .. tostring(nEndure)
    strNaijiuzi = CEGUI.String(strNaijiuzi)
    richBox:AppendText(strNaijiuzi, Equiptipmaker.color_NORMAL_YELLOW)
    richBox:AppendBreak();
end

function Equiptipmaker.makeProducter(richBox, nItemId, pEquipData)
    if not pEquipData then
        return
    end
    local strMakerName = pEquipData.maker
    if not strMakerName then
        return
    end
    if string.len(strMakerName) <= 0 then
        return
    end
    --[[
    local strDzType = ""
    local nType = math.floor( nItemId / 1000000)
	if nType == 5 then
		strDzType =  require "utils.mhsdutils".get_resstring(11004);
    elseif nType == 6 then
	    strDzType =  require "utils.mhsdutils".get_resstring(11005);
	end

    if string.len(strDzType) <= 0 then
        return
    end
    --]]
    local strZhizuozhezi = require "utils.mhsdutils".get_resstring(11269)

    strZhizuozhezi = strZhizuozhezi .. " " .. strMakerName

    strZhizuozhezi = CEGUI.String(strZhizuozhezi)
    richBox:AppendText(strZhizuozhezi, Equiptipmaker.color_NORMAL_YELLOW)
    richBox:AppendBreak();
end

function Equiptipmaker.makeScore(richBox, nItemId, pEquipData)
    if not pEquipData then
        return
    end

    local nScore = pEquipData.equipscore
    local strPingFen = require "utils.mhsdutils".get_resstring(111)
    strPingFen = strPingFen .. tostring(nScore)

    strPingFen = CEGUI.String(strPingFen)
    richBox:AppendText(strPingFen, Equiptipmaker.color_NORMAL_YELLOW)
    richBox:AppendBreak();
end

function Equiptipmaker.makeSex(richBox, nItemId, pEquipData)
    --  m_Tipscontainer.AppendText(sexneed == 1 ? MHSD_UTILS::GETSTRING(132) : MHSD_UTILS::GETSTRING(133), gGetDataManager()->GetMainCharacterData().sex != sexneed ? CEGUI::ColourRect(0xFFFF0000) : CEGUI::ColourRect(NORMAL_YELLOW));
    --	m_Tipscontainer.AppendBreak();
    local colorNormal = Equiptipmaker.color_NORMAL_YELLOW
    local colorRed = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffff0000"))
    local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance():getRecorder(nItemId)

    local vcnRoleId = equipEffectTable.roleNeed
    if vcnRoleId:size() > 0 then

        local nRoleId = vcnRoleId[0]
        local strRoleEquipzi = require "utils.mhsdutils".get_resstring(11349)
        if not strRoleEquipzi then
            return
        end
        --strRoleEquipzi = "111=$parameter$=222" --wangbin test
        local roleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(nRoleId)
        if roleTable.id == -1 then
            return
        end

        local roleColor = colorNormal
        if gGetDataManager() then
            local nModelId = gGetDataManager():GetMainCharacterShape()
            local nCurRoleId = nModelId % 10
            if nCurRoleId ~= nRoleId then
                roleColor = colorRed
            end
        end
        local strRoleName = roleTable.name

        local strSexNamezi = ""
        local strZhizuozhezi = require "utils.mhsdutils".get_resstring(11349)
        strZhizuozhezi = strZhizuozhezi .. "：" .. strRoleName

        strSexNamezi = CEGUI.String(strZhizuozhezi)
        richBox:AppendText(strSexNamezi, roleColor)
        richBox:AppendBreak()

        return
    end

    local nNeedSex = equipEffectTable.sexNeed
    --local mainRoleData = gGetDataManager():GetMainCharacterData()
    --local nCurSex = mainRoleData.sex

    if nNeedSex == 0 then
        return
    end
    local strSexNamezi = ""
    if nNeedSex == 1 then
        strSexNamezi = require "utils.mhsdutils".get_resstring(132)
    else
        strSexNamezi = require "utils.mhsdutils".get_resstring(133)
    end

    local roleColor = colorNormal
    if gGetDataManager() then
        local myData = gGetDataManager():GetMainCharacterData()
        if myData.sex ~= nNeedSex then
            roleColor = colorRed
        end
    end

    strSexNamezi = CEGUI.String(strSexNamezi)
    richBox:AppendText(strSexNamezi, roleColor)
    richBox:AppendBreak()

end

--���������ְҵ����
function Equiptipmaker.makeCareer(richBox, nItemId, pEquipData)
    local colorRed = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ffff0000"))
    local colorNormal = Equiptipmaker.color_NORMAL_YELLOW
    local mainCareedId = gGetDataManager():GetMainCharacterSchoolID()
    local roleColor = colorRed
    local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance():getRecorder(nItemId)
    if not equipEffectTable then
        print("get equipEffectTable failed")
        return
    end
    --����������ֱ��return
    if equipEffectTable.eequiptype ~= 0 then
        return
    end

    local careerIds = StringBuilder.Split(equipEffectTable.needCareer, ";")
    for k, v in pairs(careerIds) do
        if v == tostring(mainCareedId) then
            roleColor = colorNormal
            break
        end
    end
    local career = ""
    for k, v in pairs(careerIds) do
        local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(tonumber(v))
        if schoolinfo then
            career = schoolinfo.name .. " " .. career
        end
    end

    local strSexNamezi = ""
    local strZhizuozhezi = require "utils.mhsdutils".get_resstring(11431)
    strZhizuozhezi = strZhizuozhezi

    strSexNamezi = CEGUI.String(strZhizuozhezi .. " " .. career)
    if career ~= "" then
        richBox:AppendText(strSexNamezi, roleColor)
        richBox:AppendBreak()
    end
end

return Equiptipmaker
