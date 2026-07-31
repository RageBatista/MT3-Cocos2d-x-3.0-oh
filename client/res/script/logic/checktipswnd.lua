require "logic.contactroledlg"
require "logic.team.teammembermenu"
require "logic.pet.petskillidentify"
debugrequire "logic.skill.lifeskilltipdlg"
require "logic.multimenu"
require "logic.mapchose.autofightskillcell"
require "logic.workshop.tipsguajiimg"
require "logic.numkeyboarddlg"
require "logic.workshop.comefromtips"
require "logic.tips.equipinfotips"
require "logic.tips.commontipdlg"
require "logic.shop.stallpettip"
require "logic.task.tasknpcdialog"
require "logic.family.familygaimingdialog"
require "logic.tips.activitytips"
require "logic.bingfengwangzuo.bingfengwangzuodlg"
require "logic.chat.chatoutputdialog"
require "logic.chat.insertdlg"
require "logic.tips.serverleveltipdlg"
require "logic.team.anyteammenu"
----点击空白关闭窗口
CheckTipsWnd = { }
local btnDownWndName = nil
function CheckTipsWnd.OnLButtonDown()
	local petPropertyDlg = PetPropertyDlgNew.getInstanceNotCreate()
    if petPropertyDlg then
        petPropertyDlg:OnLButtonDown()
    end
	local btnDownWnd = CheckTipsWnd.GetCursorWindow()
    if btnDownWnd then
        btnDownWndName = btnDownWnd:getName()
    else
        btnDownWndName = nil
    end
	
	local pMainPackDlg = CMainPackDlg:getInstanceOrNot()
    if pMainPackDlg and btnDownWnd ~= pMainPackDlg.gengduo then -- 检查点击的区域是否为 gengduo 按钮
        pMainPackDlg:OnLButtonDown()
    end
	
	

	
	--[[local pFriendDialog = pFriendDialog:getInstanceOrNot()
    if pFriendDialog and btnDownWnd ~= pFriendDialog.cc_qunliaoBtn then 
        pFriendDialog:OnLButtonDown()
    end--]]


    CheckTipsWnd.Check_activityTip()

    CheckTipsWnd.Check_YaoQingShaiXuan()

    CheckTipsWnd.Check_ShowTeamInfoByClickLink()

    CheckTipsWnd.CheckContactRoleDlg()
    CheckTipsWnd.CheckFamilycaidan()
    CheckTipsWnd.CheckTeamMemberMenu()
	CheckTipsWnd.CheckAnyTeamMenu()
    CheckTipsWnd.CheckZhenfaTipDlg()
    CheckTipsWnd.CheckAccountList()
    CheckTipsWnd.CheckWorkshopDzLevelList()
    CheckTipsWnd.CheckZhuangBeiFuMoEffectList()
	CheckTipsWnd.ChecktejidingzhiEffectList()
    CheckTipsWnd.CheckWorkshopDzDes()
    CheckTipsWnd.CheckAddPointDlg()
    CheckTipsWnd.CheckPetEquipInfo()
    CheckTipsWnd.CheckBattleAutoSkill()
    CheckTipsWnd.CheckTaskNpcChatDlg()
    CheckTipsWnd.CheckTipsLifeSkillDlg() -- yanji 20150717
    CheckTipsWnd.CheckPetSkillIndentify()
    CheckTipsWnd.CheckMapChoseDlg()
    CheckTipsWnd.CheckNumKeyboardDlg()
    CheckTipsWnd.CheckComefromtips()
    CheckTipsWnd.CheckBattleTip()

    CheckTipsWnd.Check_tasknpcdialog()
    CheckTipsWnd.CheckFamilygaimingdialog()

    
    CheckTipsWnd.CheckHuobanSchoolBg()
    CheckTipsWnd.CheckYangchengListDlg()

    CheckTipsWnd.Check_bingfengTips()

    CheckTipsWnd.CheckLeiTaiUnder()
    CheckTipsWnd.CheckLeiTaiUnder1()

	CheckTipsWnd.Check_NpcNameListTips()
	CheckTipsWnd.Check_TaskDetailTips()
	CheckTipsWnd.Check_ZhuanZhiJueSeTips()
	CheckTipsWnd.Check_ZhuanZhiZhiYeTips()
	CheckTipsWnd.Check_ZhuanZhiBaoShiList()

    CheckTipsWnd.Check_NumberSelDlg()
    CheckTipsWnd.Check_SkillTip()
    CheckTipsWnd.Check_UserAndPetIcon()
	CheckTipsWnd.CheckColorPanel()
    CheckTipsWnd.Check_serverlevelTip()

    CheckTipsWnd.Check_gaiMingKa()
 
    CheckTipsWnd.Check_ShengSiZhanTip()

    CheckTipsWnd.Check_redPackTip()


    CheckTipsWnd.Check_selpicDialog()

    CheckTipsWnd.Check_anyeTip()

    CheckTipsWnd.Check_ChosePetDlg()

    CheckTipsWnd.Check_recordVoiceSpaceDialog()
    CheckTipsWnd.Check_InsertDlg()

    CheckTipsWnd.Check_familyFightInfoTip()
    CheckTipsWnd.CheckSelAddressListTip()

    CheckTipsWnd.CheckFubenSettingClick()
    CheckTipsWnd.CheckJinglingHistory()
	
end

function CheckTipsWnd.OnLButtonUp()

	CheckTipsWnd.CheckCommontipdlg()
    CheckTipsWnd.CheckMultiMenu()
    CheckTipsWnd.CheckStallPetTip()
    CheckTipsWnd.CheckWorldMap()
    CheckTipsWnd.CheckNpcMenu()
	CheckTipsWnd.CheckPetSkillTipsDlg()
	CheckTipsWnd.CheckStallNormalSearchAdvice()
	CheckTipsWnd.CheckStallSearchMenuDlg()
	CheckTipsWnd.CheckStallEquipPreviewTip()
	CheckTipsWnd.CheckStallPetPreviewTip()
    CheckTipsWnd.CheckOrderSetDlg()
    local petSkillIdentify = PetSkillIdentifyLingWu.getInstanceNotCreate()----绮梦技能学习特殊关闭方式
    if petSkillIdentify then
        petSkillIdentify:CheckClickOutside()
    end
	
	local petSkillIdentifyYiWang = PetSkillIdentifyYiWang.getInstanceNotCreate()
    if petSkillIdentifyYiWang then
        petSkillIdentifyYiWang:CheckClickOutside()
    end
	
	
	--yangbin
	
	CheckTipsWnd.Check_DepotMenuBtn()

    btnDownWndName = nil --set it nil at function end
end

function CheckTipsWnd.Check_ChosePetDlg()
    local dlg = require('logic.chosepetdialog').getInstanceNotCreate()
    if dlg then
        if dlg.m_CloseWindow then
            local pTargetWnd = CheckTipsWnd.GetCursorWindow()
            if pTargetWnd == dlg.scrollPane then
                return 
            

            end 
            for k,layoutCell in pairs(dlg.vCell) do
                if pTargetWnd == layoutCell then
                    return 
	            end
            end
            dlg:DestroyDialog()
        end

    end
end
function CheckTipsWnd.CheckPetEquipInfo()
    local dlg = require "logic.tips.petequiptips"
    local dlgdz = require "logic.pet.petpropertydlgnew"


    local targetWnd = CheckTipsWnd.GetCursorWindow()
    local btnDialog = dlgdz.getInstanceNotCreate()
    if btnDialog == nil then
        return
    end
    if not targetWnd or targetWnd == btnDialog.BtnSelEffect then
        return
    end

    if dlg.getInstanceNotCreate()then
        dlg.closeDialog()
    end

end

function CheckTipsWnd.CheckJinglingHistory()
    local dlg = require "logic.jingling.jinglingdlg".getInstanceNotCreate()
    if dlg then
        dlg:checkHistoryClick()
    end
end

function CheckTipsWnd.CheckWorldMap()
    local cursorwin = CheckTipsWnd.GetCursorWindow()
    local wordmap = require "logic.worldmap.worldmapdlg".GetSingleton()
    if wordmap then
        if wordmap.mapId > 0 then
            if wordmap.m_MapButtonMap[wordmap.mapId] ~= cursorwin then
                wordmap:initMapBtnStatus()
            end
        end
    end
end

function CheckTipsWnd.IsRelatedToButtonDownWnd(wnd)
    if btnDownWndName and CEGUI.WindowManager:getSingleton():isWindowPresent(btnDownWndName) then
        local btnDownWnd = CEGUI.WindowManager:getSingleton():getWindow(btnDownWndName)
        return (btnDownWnd and (btnDownWnd == wnd or btnDownWnd:isAncestor(wnd)))
    end
	return false
end

function CheckTipsWnd.GetCursorWindow()
    local guiSystem = CEGUI.System:getSingleton();
    local mousePos = CEGUI.MouseCursor:getSingleton():getPosition();

    local pTargetWindow = guiSystem:getTargetWindow(mousePos, false);

    return pTargetWindow;
end
local function check(wnd)
    local pTargetWnd = CheckTipsWnd.GetCursorWindow()
    if wnd == pTargetWnd then return true end

    if pTargetWnd then
        return pTargetWnd:isAncestor(wnd)
    else
        return false
    end
end
function CheckTipsWnd.CheckWnd(aPWnd)
    if not aPWnd then
        return
    end
    local pTargetWnd = CheckTipsWnd.GetCursorWindow();
    local pWnd = aPWnd.m_pMainFrame;

    if pWnd == pTargetWnd or pTargetWnd == nil then return; end

    local isAncestor = pTargetWnd:isAncestor(pWnd);

    if not isAncestor then
        aPWnd:DestroyDialog();
    end
end

function CheckTipsWnd.CheckWnds(...)
    for i, v in ipairs { ...} do
        local dlg = v
        if dlg then
            print("check wnd=" .. dlg.m_pMainFrame:getName())
            local flag = check(dlg.m_pMainFrame)
            if flag then
                return
            end
        end
    end
    for i, v in ipairs { ...} do
        if v then
            v:DestroyDialog()
        end
    end
end

function CheckTipsWnd.CheckFamilycaidan()
    -- ����Ȩ�޲˵���
    if Familycaidan.getInstanceNotCreate() and Familycaidan.getInstanceNotCreate().IsCanClose then
        CheckTipsWnd.CheckWnds(Familycaidan.getInstanceNotCreate())
    end
end

--������رո���Dialog
function CheckTipsWnd.CheckFamilygaimingdialog()
    local dlg = Familygaimingdialog.getInstanceNotCreate()
    if dlg then
        local targetWnd = CheckTipsWnd.GetCursorWindow()
        if not targetWnd or targetWnd == dlg.trigger then
            return
        end

        if targetWnd ~= dlg:GetWindow() and not targetWnd:isAncestor(dlg:GetWindow()) then
            dlg.DestroyDialog()
        end
    end
end

function CheckTipsWnd.CheckZhenfaTipDlg()
    if ZhenFaTip.peekInstance() then
        CheckTipsWnd.CheckWnd(ZhenFaTip.peekInstance());
    end
end

function CheckTipsWnd.CheckContactRoleDlg()
    --LogInfo("CheckTipsWnd.CheckContactRoleDlg")
    local inst = ContactRoleDialog.getInstanceNotCreate()
    if inst then
        local guiSystem = CEGUI.System:getSingleton()
        local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()

        local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
        local dlgWnd = inst:GetWindow()
        local bIsDlgWnd = ptTargetWindow == dlgWnd

        if ptTargetWindow then
            local isAncestor = ptTargetWindow:isAncestor(dlgWnd)
            if not bIsDlgWnd and not isAncestor then
                inst:DestroyDialog()
            end
        else
            inst:DestroyDialog()
        end
    end
end

function CheckTipsWnd.CheckTeamMemberMenu()
    -- print("CheckTipsWnd.CheckTeamMemberMenu")
    local inst = TeamMemberMenu.getInstanceNotCreate()
    if inst and inst:IsVisible() then
        local guiSystem = CEGUI.System:getSingleton()
        local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()

        local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
        local triggerWindow = inst:getTriggerWnd()
        if triggerWindow and ptTargetWindow and (triggerWindow == ptTargetWindow or ptTargetWindow:isAncestor(triggerWindow)) then
            return
        end

        local dlgWnd = inst:GetWindow()
        local bIsDlgWnd = ptTargetWindow == dlgWnd

        if ptTargetWindow then
            local isAncestor = ptTargetWindow:isAncestor(dlgWnd)
            if not bIsDlgWnd and not isAncestor then
                inst:SetVisible(false)
            end
        else
            inst:SetVisible(false)
        end
    end
end


 
function CheckTipsWnd.CheckAnyTeamMenu()
    -- print("CheckTipsWnd.CheckTeamMemberMenu")
    local inst = Anyteammenu.getInstanceNotCreate()
    if inst and inst:IsVisible() then
        local guiSystem = CEGUI.System:getSingleton()
        local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()

        local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
        local triggerWindow = inst:getTriggerWnd()
        if triggerWindow and ptTargetWindow and (triggerWindow == ptTargetWindow or ptTargetWindow:isAncestor(triggerWindow)) then
            return
        end

        local dlgWnd = inst:GetWindow()
        local bIsDlgWnd = ptTargetWindow == dlgWnd

        if ptTargetWindow then
            local isAncestor = ptTargetWindow:isAncestor(dlgWnd)
            if not bIsDlgWnd and not isAncestor then
                inst:SetVisible(false)
            end
        else
            inst:SetVisible(false)
        end
    end
end

function CheckTipsWnd.CheckSpringActivityInfoDlg()
    if CheckSpringActivityInfoDlg.getInstanceNotCreate() then
        CheckTipsWnd.CheckWnd(CheckSpringActivityInfoDlg.getInstanceNotCreate());
    end
end

function CheckTipsWnd.CheckPetSummonDlg()
    local BattlePetSummonDlg = require "logic.pet.battlepetsummondlg"
    if BattlePetSummonDlg.getInstanceNotCreate() then
        CheckTipsWnd.CheckWnd(BattlePetSummonDlg.getInstanceNotCreate())
    end
end

function CheckTipsWnd.CheckAccountList()
    local dlg = require('logic.accountlistdlg').getInstanceNotCreate()
    if dlg then
        local targetWnd = CheckTipsWnd.GetCursorWindow()
        if targetWnd and targetWnd == dlg.triggerBtn then
            return
        end

        if not targetWnd or(targetWnd ~= dlg:GetWindow() and not targetWnd:isAncestor(dlg:GetWindow())) then
            dlg.DestroyDialog()
        end
    end
end

function CheckTipsWnd.CheckFubenSettingClick()
    local dlg = require "logic.fuben.fubensetting".getInstanceNotCreate()
    if dlg then
        if not dlg:checkTouchInWnd() then
            dlg.DestroyDialog()
        end
    end
end


function CheckTipsWnd.CheckWorkshopDzLevelList()
    local dlg = require "logic.workshop.workshopdznewcell"
    local dlgdz = require "logic.workshop.workshopdznew"


    local targetWnd = CheckTipsWnd.GetCursorWindow()
    local btnDialog = dlgdz.getInstanceOrNot()
    if btnDialog == nil then
        return
    end
    if not targetWnd or targetWnd == btnDialog.BtnSelLevel then
        return
    end

    if dlg.getInstanceNotCreate() and not check(dlg.getInstanceNotCreate().m_pMainFrame) then
        dlg.closeDialog()
    end

end
function CheckTipsWnd.CheckZhuangBeiFuMoEffectList()
    local dlg = require "logic.workshop.zhuangbeifumocell"
    local dlgdz = require "logic.workshop.zhuangbeifumo"


    local targetWnd = CheckTipsWnd.GetCursorWindow()
    local btnDialog = dlgdz.getInstanceOrNot()
    if btnDialog == nil then
        return
    end
    if not targetWnd or targetWnd == btnDialog.BtnSelEffect then
        return
    end

    if dlg.getInstanceNotCreate() and not check(dlg.getInstanceNotCreate().m_pMainFrame) then
        dlg.closeDialog()
    end

end
----特技定制
function CheckTipsWnd.ChecktejidingzhiEffectList()
    local dlg = require "logic.workshop.tejidingzhicell"
    local dlgdz = require "logic.workshop.tejidingzhi"


    local targetWnd = CheckTipsWnd.GetCursorWindow()
    local btnDialog = dlgdz.getInstanceOrNot()
    if btnDialog == nil then
        return
    end
    if not targetWnd or targetWnd == btnDialog.BtnSelEffect then
        return
    end

    if dlg.getInstanceNotCreate() and not check(dlg.getInstanceNotCreate().m_pMainFrame) then
        dlg.closeDialog()
    end

end

function CheckTipsWnd.CheckWorkshopDzDes()
    local dlg = require "logic.workshop.tips1"
    if dlg.getInstanceNotCreate() then
        dlg.DestroyDialog()
        --CheckTipsWnd.CheckWnd(dlg.getInstanceNotCreate())
    end
    --[[	if dlg.getInstanceNotCreate() and not check(dlg.getInstanceNotCreate().m_pMainFrame) then
		dlg.DestroyDialog()
	end]]


end



function CheckTipsWnd.CheckAddPointDlg()----点击空白关闭窗口
    -- by bayaer
    --

    local addptrlistdlg = require('logic.addpointlistdlg')
    local addptrdlg = require("logic.characterinfo.characterpropertyaddptrdlg")
    if addptrlistdlg.getInstanceNotCreate() and not check(addptrlistdlg.getInstanceNotCreate().m_pMainFrame) and addptrdlg.getInstanceNotCreate() and not check(addptrdlg.getInstanceNotCreate().m_schemeBtn) then
        addptrlistdlg.DestroyDialog()
        print("CheckTipsWnd.CheckDepotDlg---------------------------")
    end
    local addptrintrodlg = require('logic.addpointintro')
    if addptrintrodlg.getInstanceNotCreate() and not check(addptrintrodlg.getInstanceNotCreate().m_pMainFrame) then
        addptrintrodlg.DestroyDialog()
    end
	
	local addcptrintrodlg = require('logic.addcpointintro')
    if addcptrintrodlg.getInstanceNotCreate() and not check(addcptrintrodlg.getInstanceNotCreate().m_pMainFrame) then
        addcptrintrodlg.DestroyDialog()
    end
	
	local PetEquipTipsdlg = require('logic.tips.petequiptips')----宠物装备
    if PetEquipTipsdlg.getInstanceNotCreate() and not check(PetEquipTipsdlg.getInstanceNotCreate().m_pMainFrame) then
        PetEquipTipsdlg.DestroyDialog()
    end
	
	local Addndpointintrodlg = require('logic.pet.Addndpointintro')----内丹合成
    if Addndpointintrodlg.getInstanceNotCreate() and not check(Addndpointintrodlg.getInstanceNotCreate().m_pMainFrame) then
        Addndpointintrodlg.DestroyDialog()
    end
	
	local Accqunliaodlg = require('logic.friend.Accqunliao')
    if Accqunliaodlg.getInstanceNotCreate() and not check(Accqunliaodlg.getInstanceNotCreate().m_pMainFrame) then
        Accqunliaodlg.DestroyDialog()
    end
    
	local Addqimentishidlg = require('logic.pet.Addqimentishi') 
    if Addqimentishidlg.getInstanceNotCreate() and not check(Addqimentishidlg.getInstanceNotCreate().m_pMainFrame) then 
        Addqimentishidlg.getInstanceNotCreate():DestroyDialog()  --  绮梦提示
    end 
	
	local Addfabaoshuomingdlg = require('logic.item.addfabaoshuoming') 
    if Addfabaoshuomingdlg.getInstanceNotCreate() and not check(Addfabaoshuomingdlg.getInstanceNotCreate().m_pMainFrame) then 
        Addfabaoshuomingdlg.getInstanceNotCreate():DestroyDialog()  --  法宝提示1
    end 
	
	--[[local Accmpsmdlg = require('logic.accmpsm') 
    if Accmpsmdlg.getInstanceNotCreate() and not check(Accmpsmdlg.getInstanceNotCreate().m_pMainFrame) then 
        Accmpsmdlg.getInstanceNotCreate():DestroyDialog()  --  门派提示
    end ]]
	
	--[[local Addfabaoduihuandlg = require('logic.item.addfabaoduihuan') 
    if Addfabaoduihuandlg.getInstanceNotCreate() and not check(Addfabaoduihuandlg.getInstanceNotCreate().m_pMainFrame) then 
        Addfabaoduihuandlg.getInstanceNotCreate():DestroyDialog()  --  法宝兑换
    end ]]
	
	local fuliplanedlg = require('logic.qiandaosongli.fuliplane') 
    if fuliplanedlg.getInstanceNotCreate() and not check(fuliplanedlg.getInstanceNotCreate().m_pMainFrame) then 
        fuliplanedlg.getInstanceNotCreate():DestroyDialog()  --  法宝兑换
    end 
	
    local fenxiangdlg = require('logic.shengsizhan.fenxianglistdlg')
    if fenxiangdlg.getInstanceNotCreate() and not check(fenxiangdlg.getInstanceNotCreate().m_pMainFrame) then
        fenxiangdlg.DestroyDialog()
    end
end

function CheckTipsWnd.CheckBattleAutoSkill()
    local dlg = require "logic.battleautofightdlg"
    if dlg.getInstanceNotCreate() then
        dlg.getInstanceNotCreate():HideSkillTip()
        local pTargetWnd = CheckTipsWnd.GetCursorWindow()
        local rootwnd = dlg.getInstanceNotCreate().m_SkillBG
        if pTargetWnd == rootwnd then return true end
        if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
            if dlg.getInstanceNotCreate().m_PlayerOrPet == 0 then
                if not check(dlg.getInstanceNotCreate().m_pBtnPlayerSkill) then
                    dlg.getInstanceNotCreate():HideSkillBG()
                end
            else
                if not check(dlg.getInstanceNotCreate().m_pBtnPetSkill) then
                    dlg.getInstanceNotCreate():HideSkillBG()
                end
            end

        end
        -- if CBattleSkillTip:GetSingleton() then
        -- if not pTargetWnd or not pTargetWnd:isAncestor(CBattleSkillTip:GetSingleton():GetWindow()) then
        -- dlg.getInstanceNotCreate():HideSkillTip()
        -- end
        -- end
    end
end

function CheckTipsWnd.CheckTaskNpcChatDlg()
    local taskNpcChat = require('logic.task.tasknpcchatdialog')
    if taskNpcChat.getInstanceNotCreate() then
        -- and not check(taskNpcChat.getInstanceNotCreate().m_pMainFrame) then
        taskNpcChat.DestroyDialog()
    end
end
-- by wangjianfeng 20150916 add
function CheckTipsWnd.Check_activityTip()
    local activitytip = require('logic.tips.activitytips')
    if activitytip.getInstanceNotCreate() then
        local commontipdlg = require('logic.tips.commontipdlg').getInstanceNotCreate()
	    if commontipdlg then
            return
        end
        local pTargetWnd = CheckTipsWnd.GetCursorWindow()
        local rootwnd = activitytip.getInstanceNotCreate().m_MainFrame
        if pTargetWnd == rootwnd then return true end
        if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
            activitytip.DestroyDialog()
        end
    end
end
function CheckTipsWnd.Check_redPackTip()
    local tip = require('logic.redpack.redpackrecorddlg')
    if tip.getInstanceNotCreate() then
        local pTargetWnd = CheckTipsWnd.GetCursorWindow()
        local rootwnd = tip.getInstanceNotCreate().m_List
        if pTargetWnd == rootwnd then return true end
        if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
            tip.DestroyDialog()
        end
    end
end
function CheckTipsWnd.Check_serverlevelTip()
    local activitytip = require('logic.tips.serverleveltipdlg')
    if activitytip.getInstanceNotCreate() then
        local pTargetWnd = CheckTipsWnd.GetCursorWindow()  
        local dlgWnd = activitytip.getInstanceNotCreate():GetWindow() 
        
        if pTargetWnd and not pTargetWnd:isAncestor(dlgWnd) then 
        
            activitytip.DestroyDialog()  
        end
    end
end
function CheckTipsWnd.CheckHuobanSchoolBg()
    local schoolbg = require('logic.team.huobanzhuzhanschoolbg')
    if schoolbg.getInstanceNotCreate() then
        local pTargetWnd = CheckTipsWnd.GetCursorWindow()
        local rootwnd = schoolbg.getInstanceNotCreate():GetWindow()
        local huobanzhuzhandialog = require('logic.team.huobanzhuzhandialog').getInstanceNotCreate()
        if huobanzhuzhandialog then
            local btnwnd = huobanzhuzhandialog.m_Schoolbtn
            if pTargetWnd == btnwnd then return true end
        end 
        
        if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
            local dlg = require('logic.team.huobanzhuzhandialog').getInstanceNotCreate()
            if dlg then
               dlg:CloseSchoolBtn()
            end
        end
    end
end
function CheckTipsWnd.CheckTipsLifeSkillDlg()
    local lifetip = require('logic.skill.lifeskilltipdlg')
    if lifetip.getInstanceNotCreate() then
        lifetip.DestroyDialog()
    end
end


function CheckTipsWnd.CheckDepotDlg()
    local depotbtndlg = require "logic.item.depotmenubtn"
    if depotbtndlg.getInstanceNotCreate() and not check(depotbtndlg:getInstanceNotCreate().m_pMainFrame) then
        depotbtndlg.DestroyDialog()
        print("CheckTipsWnd.CheckDepotDlg---------------------------")
    end
end

function CheckTipsWnd.CheckPetSkillIndentify()
    local dlg = PetSkillIdentify.getInstanceNotCreate()
    if dlg and dlg:IsVisible() and not check(dlg:GetWindow()) then
		dlg.DestroyDialog()
		CheckTipsWnd.CheckWnd(PetSkillTipsDlg.getInstanceNotCreate())
    end
end

function CheckTipsWnd.CheckMapChoseDlg()
    local autodlg = require "logic.mapchose.autofightskillcell"
    if autodlg.getInstanceNotCreate() and not check(autodlg:getInstanceNotCreate().m_pMainFrame) then
        autodlg.DestroyDialog()
        print("CheckTipsWnd.CheckMapChoseDlg---------------------------")
    end

    local tipsdlg = require "logic.workshop.tipsguajiimg"
    if tipsdlg.getInstanceNotCreate() and not check(tipsdlg:getInstanceNotCreate().m_pMainFrame) then
        tipsdlg.DestroyDialog()
        print("CheckTipsWnd.CheckMapChoseDlg---------------------------")
    end

end

function CheckTipsWnd.CheckYangchengListDlg()
    local ycDlg = require "logic.yangchengnotify.yangchenglistdlg"
    if ycDlg.getInstanceNotCreate() and not check(ycDlg.getInstanceNotCreate().m_MainFrame) then
        if check(require "logic.logo.logoinfodlg".getInstance().m_btnTisheng) then
            require "logic.logo.logoinfodlg".getInstance().isLastTouchAtTSIcon = true
        end
        ycDlg.DestroyDialog()
        print("CheckTipsWnd.CheckYangchengListDlg---------------------------")
    end
end


function CheckTipsWnd.CheckMultiMenu()
    local dlg = MultiMenu.getInstanceNotCreate()
    if dlg then
		if CheckTipsWnd.IsRelatedToButtonDownWnd(dlg.window) then
			return
		end
        local targetWnd = CheckTipsWnd.GetCursorWindow()
        if targetWnd and targetWnd == dlg.triggerBtn then
            return
        end

        if not targetWnd or(targetWnd ~= dlg.window and not targetWnd:isAncestor(dlg.window)) then
            dlg.DestroyDialog()
        end
    end
end

function CheckTipsWnd.CheckNumKeyboardDlg()
    local dlg = NumKeyboardDlg.getInstanceNotCreate()
    if dlg then
        local targetWnd = CheckTipsWnd.GetCursorWindow()
        if targetWnd and targetWnd == dlg.triggerBtn then
            return
        end

        if not targetWnd or(targetWnd ~= dlg:GetWindow() and not targetWnd:isAncestor(dlg:GetWindow())) then
            dlg.DestroyDialog()
        end
    end
end

function CheckTipsWnd.CheckComefromtips()
    local Comefromtips = require('logic.workshop.comefromtips')
    local Commontipdlg = require('logic.tips.commontipdlg')

    if Commontipdlg.getInstanceNotCreate() and
        check(Commontipdlg.getInstanceNotCreate().btnComeFrom)
    then
        return
    end

    if Comefromtips.getInstanceNotCreate() and not check(Comefromtips.getInstanceNotCreate().m_pMainFrame) then
        Comefromtips.DestroyDialog()
    end
end

function CheckTipsWnd.Check_Equipinfotips()
    local Equipinfotips = require('logic.tips.equipinfotips')
    if Equipinfotips.getInstanceNotCreate() and not check(Equipinfotips.getInstanceNotCreate().m_pMainFrame) then
        Equipinfotips.DestroyDialog()
    end
end

function CheckTipsWnd.CheckColorPanel()
	local dlg = require('logic.chat.chatoutputdialog').getInstanceNotCreate()
	if dlg and dlg.m_ColorSelectDlg and dlg.m_ColorSelectDlg:isVisible() then

		local pWindow = CheckTipsWnd.GetCursorWindow()
		if pWindow == nil or(pWindow ~= dlg.m_ColorSelectDlg and not pWindow:isAncestor(dlg.m_ColorSelectDlg)) then
			dlg:OnCloseColorDialogBtn()
		end
	end
end

function CheckTipsWnd.CheckCommontipdlg()
    local commontipdlg = require('logic.tips.commontipdlg').getInstanceNotCreate()
	if commontipdlg then
		if commontipdlg.willCheckTipsWnd then
			local comefromtips = require('logic.workshop.comefromtips').getInstanceNotCreate()
			if comefromtips and not check(commontipdlg.m_pMainFrame) then
				return
			end

			if commontipdlg.bRequestTipsProtocol then
				commontipdlg.bRequestTipsProtocol = false
				return
			end

			if commontipdlg and not check(commontipdlg.m_pMainFrame) then
				commontipdlg.DestroyDialog()
			end
		else
			commontipdlg.willCheckTipsWnd = true
		end
	end
end

-- ���PK����
function CheckTipsWnd.CheckLeiTaiUnder()
    require "logic.leitai.leitaiunder"
    local dlg = LeiTaiUnder.getInstanceNotCreate()
    if dlg then
        local targetWnd = CheckTipsWnd.GetCursorWindow()
        if not targetWnd or targetWnd == dlg.trigger then
            return
        end
        local dlg1 = LeiTaiDialog.getInstanceNotCreate()
        if not dlg1 then
            return
        end
        if targetWnd ~= dlg:GetWindow() and not targetWnd:isAncestor(dlg:GetWindow()) and dlg1.m_ZhiYeShaiXuanBtn ~= targetWnd then
            dlg.DestroyDialog()
        end
        dlg1:SetUpAndDown()
    end

end
function CheckTipsWnd.CheckLeiTaiUnder1()
    require "logic.leitai.leitaiunder1"
    local dlg = LeiTaiUnder1.getInstanceNotCreate()
    if dlg then
        local targetWnd = CheckTipsWnd.GetCursorWindow()
        if not targetWnd or targetWnd == dlg.trigger then
            return
        end
        local dlg1 = LeiTaiDialog.getInstanceNotCreate()
        if not dlg1 then
            return
        end
        if targetWnd ~= dlg:GetWindow() and not targetWnd:isAncestor(dlg:GetWindow()) and dlg1.m_AllButton ~= targetWnd then
            dlg.DestroyDialog()
        end
        dlg1:SetUpAndDown2()
    end

end
function CheckTipsWnd.CheckDeathNoteDlg()
    local DeathNoteDlg = require('logic.deathNoteDlg')
    if DeathNoteDlg.getInstanceNotCreate() then
        local wnd = DeathNoteDlg.getInstanceNotCreate():GetWindow()
        local curModalTarget = CEGUI.System:getSingleton():getModalTarget()
        if curModalTarget == wnd and not check(wnd) then
            GetMainCharacter():SetMovingStat(true)
            DeathNoteDlg.DestroyDialog()
        end
    end
end

function CheckTipsWnd.CheckBattleTip()
    local dlg = require "logic.battle.battletips"
    if dlg.getInstanceNotCreate() then
        local pTargetWnd = CheckTipsWnd.GetCursorWindow()
        local rootwnd = dlg.getInstanceNotCreate():GetWindow()
        if pTargetWnd == rootwnd then return true end
        if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
            dlg.CSetBattleID(0, 0)
        end
    end
end

function CheckTipsWnd.CheckOrderSetDlg()
    local dlg = require "logic.fightorder.ordersetdlg"
    if dlg.getInstanceNotCreate() then
        dlg.DestroyDialog()
    end
end

function CheckTipsWnd.CheckStallPetTip()
    local dlg = StallPetTip.getInstanceNotCreate()
    if dlg then
		if dlg.willCheckTipsWnd and not check(dlg:GetWindow()) then
			dlg.DestroyDialog()
		else
			dlg.willCheckTipsWnd = true
		end
    end
end

function CheckTipsWnd.Check_tasknpcdialog()
    local Tasknpcdialog = require('logic.task.tasknpcdialog')
    if Tasknpcdialog.getInstanceNotCreate() and not check(Tasknpcdialog.getInstanceNotCreate().m_pMainFrame) then
        Tasknpcdialog.DestroyDialog()
    end
end

function CheckTipsWnd.CheckNpcMenu()
    if SmallMapDlg then
        local dlg = SmallMapDlg.getInstanceNotCreate()
        if dlg then
            local targetWnd = CheckTipsWnd.GetCursorWindow()
            if not targetWnd or(targetWnd ~= dlg:GetWindow()) and(not targetWnd:isAncestor(dlg:GetWindow())) then
                dlg.m_npcFrame:setVisible(false)
            end
        end
    end
end

function CheckTipsWnd.Check_bingfengTips()
    local dlg = bingfengwangzuoDlg.getInstanceNotCreate()
    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if targetWnd == nil then
        return
    end
   if dlg and targetWnd ~= dlg:getRankButton() and targetWnd ~= dlg:getLevelButton() and not targetWnd:isAncestor(dlg:getLevelBtnBg()) then
   --if dlg and targetWnd ~= dlg:getRankButton() and targetWnd ~= dlg:getLevelButton() and not targetWnd:isAncestor(dlg:getRankBtnBg()) and not targetWnd:isAncestor(dlg:getSchoolBg()) and not targetWnd:isAncestor(dlg:getLevelBtnBg()) then

        dlg:checkAllListBg()
    end
end

function CheckTipsWnd.Check_NpcNameListTips()
	local dlg = require "logic.npcnamelist".getInstanceNotCreate()
	if dlg then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.getInstanceNotCreate().panel
		if pTargetWnd == rootwnd then return true end
		if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		end
	end
end
function CheckTipsWnd.Check_InsertDlg()
	local dlg = require "logic.chat.insertdlg".getInstanceNotCreate()

	if dlg and dlg.willCheckTipsWnd then
		dlg.willCheckTipsWnd = false
		return
	end

	if dlg then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.getInstanceNotCreate():GetWindow()
		if pTargetWnd == rootwnd then return true end
		if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		end
	end
end

function CheckTipsWnd.Check_DepotMenuBtn()
	local depotMenu = require "logic.item.depotmenubtn".getInstanceNotCreate();
	if depotMenu then

		if depotMenu.mbJustCreated then
			depotMenu.mbJustCreated = false;
			return;
		end

		local pTargetWnd = CheckTipsWnd.GetCursorWindow();
		local depotMenuWnd = depotMenu:GetWindow();

		if not pTargetWnd or (pTargetWnd ~= depotMenuWnd and not pTargetWnd:isAncestor(depotMenuWnd)) then
			depotMenu.DestroyDialog();
		end

		
	end
end

function CheckTipsWnd.Check_TaskDetailTips()
	local dlg = require "logic.task.showtaskdetail".getInstanceNotCreate()
	if dlg then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.getInstanceNotCreate():GetWindow()
		if pTargetWnd == rootwnd then return true end
		if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		end
	end
end

function CheckTipsWnd.Check_ZhuanZhiJueSeTips()
	local dlg = require "logic.zhuanzhi.zhuanzhiselectjuese".getInstanceNotCreate()
	if dlg then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.getInstanceNotCreate():GetWindow()
		if pTargetWnd == rootwnd then return true end
		if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		end
	end
end

function CheckTipsWnd.Check_ZhuanZhiZhiYeTips()
	local dlg = require "logic.zhuanzhi.zhuanzhizhiye".getInstanceNotCreate()
	if dlg then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.getInstanceNotCreate():GetWindow()
		if pTargetWnd == rootwnd then return true end
		if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		end
	end
end

function CheckTipsWnd.Check_ZhuanZhiBaoShiList()
	local dlg = require "logic.zhuanzhi.zhuanzhibaoshilist".getInstanceNotCreate()
	if dlg then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.getInstanceNotCreate():GetWindow()
		if pTargetWnd == rootwnd then return true end
		if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		end
	end
end

function CheckTipsWnd.Check_NumberSelDlg()
	local dlg = require "logic.numbersel"
	if dlg.getInstanceNotCreate() then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.getInstanceNotCreate():GetWindow()
		if pTargetWnd == rootwnd then return true end
		if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		end
	end
end

function CheckTipsWnd.Check_SkillTip()
	local dlg = require "logic.battle.battleskilltip"
	if dlg.getInstanceNotCreate() then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.getInstanceNotCreate():GetWindow()
		if pTargetWnd == rootwnd then return true end
		if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		end
	end
end

function CheckTipsWnd.Check_ShengSiZhanTip()
	local dlg = require "logic.shengsizhan.shengsizhanteampanel"
	if dlg.getInstanceNotCreate() then
		--local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		--local rootwnd = dlg.getInstanceNotCreate():GetWindow()
		--if pTargetWnd == rootwnd then return true end
		--if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
			dlg.DestroyDialog()
		--end
	end
end

function CheckTipsWnd.CheckPetSkillTipsDlg()
	local dlg = PetSkillTipsDlg.getInstanceNotCreate()
	if dlg then
		if dlg.willCheckTipsWnd then
			dlg.DestroyDialog()
		else
			dlg.willCheckTipsWnd = true
		end
	end
end

function CheckTipsWnd.CheckQianNengGuoSetDlg()
	local dlg = XiulianguoTipsDlg.getInstanceNotCreate()
	if dlg then
		if dlg.willCheckTipsWnd then
			dlg.DestroyDialog()
		else
			dlg.willCheckTipsWnd = true
		end
	end
end



function CheckTipsWnd.CheckNpcDialogTouch()
    local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
    local dlg = require "logic.npc.npcdialog".getInstanceNotCreate()
    if dlg then
        local guiSystem = CEGUI.System:getSingleton()
        local pWindow = guiSystem:getTargetWindow(mousePos, false)
        if pWindow == nil or (pWindow ~= dlg.m_pServersBox and pWindow ~= dlg.m_pNpcTalkBox )then
            if not dlg:isNormalType() then
                local p = require("protodef.fire.pb.npc.cgiveupquestion"):new()
                p.npckey = dlg.m_npcId
                p.questiontype = dlg.m_iQuestType
	            LuaProtocolManager:send(p)               
            end
            dlg.DestroyDialog()
            return true
        end
    end
    return false
end

function CheckTipsWnd.Check_UserAndPetIcon()
    local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        local guiSystem = CEGUI.System:getSingleton()
	    if dlg.m_friendHead and dlg.m_friendHead:isVisible() then
		    local pWindow = guiSystem:getTargetWindow(mousePos, false)
		    if  pWindow == nil or (pWindow ~= dlg.m_friendHead and not pWindow:isAncestor(dlg.m_friendHead)) then
			    dlg.m_friendHead:setVisible(false)
		    end
	    end
    end

end

function CheckTipsWnd.CheckStallNormalSearchAdvice()
	local dlg = require("logic.shop.stallsearchdlg").getInstanceNotCreate()
	if dlg and dlg.normalSearch then
		if CheckTipsWnd.IsRelatedToButtonDownWnd(dlg.normalSearch.adviceBg) then
			return
		end
		if dlg.normalSearch.willCheckTipsWnd then
			local adviceBg = dlg.normalSearch.adviceBg
			if adviceBg and adviceBg:isVisible() and not check(adviceBg) then
				adviceBg:setVisible(false)
			end
		else
			dlg.normalSearch.willCheckTipsWnd = true
		end
	end
end

function CheckTipsWnd.CheckStallSearchMenuDlg()
	local dlg = require("logic.shop.stallsearchmenudlg").getInstanceNotCreate()
	if dlg then
		if CheckTipsWnd.IsRelatedToButtonDownWnd(dlg:GetWindow()) then
			return
		end
		if dlg.willCheckTipsWnd then
			if not check(dlg:GetWindow()) then
				dlg.DestroyDialog()
			end
		else
			dlg.willCheckTipsWnd = true
		end
	end
end

function CheckTipsWnd.CheckStallEquipPreviewTip()
	local dlg = require("logic.shop.stallequippreviewtip").getInstanceNotCreate()
	if dlg then
		dlg.DestroyDialog()
	end
end

function CheckTipsWnd.CheckStallPetPreviewTip()
	local dlg = require("logic.shop.stallpetpreviewtip").getInstanceNotCreate()
	if dlg then
		dlg.DestroyDialog()
	end
end

function CheckTipsWnd.Check_gaiMingKa()
	local dlg = require("logic.gaimingka").getInstanceNotCreate()
    if dlg and  not check(dlg.frameWindow) then
            dlg.DestroyDialog()
    end
end

-- ��������ɸѡ����
function CheckTipsWnd.Check_YaoQingShaiXuan()
    local dlg = require("logic.family.familyyaoqingshaixuan").getInstanceNotCreate()
    if dlg then
        CheckTipsWnd.CheckWnd(dlg);
    end
end

-- ��������Ӵ򿪵Ķ�����Ϣ����
function CheckTipsWnd.Check_ShowTeamInfoByClickLink()
    local dlg = require("logic.team.showteaminfobyclicklink").getInstanceNotCreate()
    if dlg then
        CheckTipsWnd.CheckWnd(dlg);
    end
end


function CheckTipsWnd.Check_selpicDialog()
	local dlg = require("logic.space.spaceselpicdialog").getInstanceNotCreate()
    if not dlg then
        return
    end
    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if  targetWnd == dlg.btnCamera 
        or targetWnd == dlg.btnPhoto
        or targetWnd == dlg.btnDelPic
        then
         return
    end
    if not check(dlg:GetWindow()) then
          dlg.DestroyDialog()
    end
end


function CheckTipsWnd.Check_recordVoiceSpaceDialog()
	local dlg = require("logic.space.spacerecorddialog").getInstanceNotCreate()
    if not dlg then
        return
    end

    if not check(dlg:GetWindow()) then
            dlg.DestroyDialog()
    end
end


function CheckTipsWnd.Check_anyeTip()
    local dlg = require("logic.anye.anyemaxituandialog").getInstanceNotCreate()
    if not dlg then
        return
    end

    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if  targetWnd == dlg.btnRenxing 
        or targetWnd == dlg.btnCallHelp
        or targetWnd == dlg.btnRenxingStone
        or targetWnd == dlg.btnRenxingShengwang
        or targetWnd == dlg.btnCallHelpShijie
        or targetWnd == dlg.btnCallHelpGonghui
    then
        return
    end
    dlg:hideTipBtn()
    
end

function  CheckTipsWnd.Check_familyFightInfoTip()
	local dlg = require("logic.family.familyfightinfo").getInstanceNotCreate()
    if not dlg then
        return
    end
    if not check(dlg.bg)  then
            dlg.DestroyDialog()
    end
end

function CheckTipsWnd.CheckSelAddressListTip()
    
    local dlg = require("logic.space.spaceseladdresslistdialog").getInstanceNotCreate()
    if not dlg then
        return
    end

    local setDlg = require("logic.space.spacesetaddressdialog").getInstanceNotCreate()
    if not setDlg then
        return
    end

    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if  targetWnd == setDlg.btnProvince 
        or targetWnd == setDlg.btnCountry
    then
        return
    end

    if not check(dlg.m_pMainFrame)  then
           require("logic.space.spaceseladdresslistdialog").DestroyDialog()
    end
end


