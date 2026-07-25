require "logic.dialog"
require "utils.commonutil"

local s_ItemFlyTime = 0.6   -- 道具飞入时间
local s_ItemStayTime = 0.6  -- 道具停留时间

AddNewItemsEffect = {
    pCell,
    -- itemcell
    xSpeed = 0,
    -- x方向移动速度
    ySpeed = 0,-- y方向移动速冻
    m_iStartTime,-- 开始时间
    m_iDestXPos,-- 目的x坐标，也就是包裹按钮的x屏幕坐标
    m_iDestYPos,
    -- 目的y坐标，也就是包裹按钮的y屏幕坐标
    m_bDrawEffectNow = false,
    -- 目前是否在播特效
    m_vNewItems = { },
    -- 新添加的道具list
    m_bHasItemUnit = false,
    m_Time = 0.0,
    --[[
        int icon
        int num
		int nItemId
    ]]
}
-- 清理数据
function AddNewItemsEffect.Clear()
    if not AddNewItemsEffect.pCell then
        return
    end
    local obj = AddNewItemsEffect
    if not obj then
        return
    end
    obj.pCell:Clear()
    obj.pCell:setAlwaysOnTop(false)
    obj.pCell:setVisible(false)
    CEGUI.WindowManager:getSingleton():destroyWindow(obj.pCell)
    obj.pCell = nil

    obj.m_bHasItemUnit = false 
    obj.xSpeed = 0
    obj.ySpeed = 0
end

-- 销毁
function AddNewItemsEffect.Destroy()
    if not AddNewItemsEffect.pCell then
        return
    end
    if (not AddNewItemsEffect.xSpeed) or(not AddNewItemsEffect.ySpeed) then
        return
    end
    CEGUI.WindowManager:getSingleton():destroyWindow(AddNewItemsEffect.pCell)
    AddNewItemsEffect.pCell = nil
    AddNewItemsEffect.xSpeed = 0
    AddNewItemsEffect.ySpeed = 0
    AddNewItemsEffect.m_bHasItemUnit = false
    AddNewItemsEffect.m_vNewItems = {}
    AddNewItemsEffect.m_bDrawEffectNow = false
end
-- 运行
function AddNewItemsEffect.Run(deltaTime)
    local obj = AddNewItemsEffect
    if not obj then
        return
    end
    local len = #(obj.m_vNewItems)
    if len == 0 then
        return
    end

    obj.m_iStartTime = obj.m_iStartTime - deltaTime
    if obj.m_iStartTime <= 0 then
        local dlg = MainControl.getInstanceNotCreate()
        if dlg then
            dlg.SetPackBtnFlash()
            table.remove(obj.m_vNewItems, 1)
            obj.CheckPlayNextEffect()
        end
    elseif obj.m_iStartTime <(s_ItemStayTime * 1000) and obj.pCell then
        obj.RefreshPos(deltaTime)
    end
end
function AddNewItemsEffect.RefreshPos(deltaTime)
    local obj = AddNewItemsEffect
    if not obj then
        return
    end
    if (not obj.xSpeed) or(not obj.ySpeed) then
        return
    end
    if obj.pCell and obj.pCell:isVisible() then
        local x = obj.pCell:getPosition().x.offset
        local y = obj.pCell:getPosition().y.offset
        local newXPos = CEGUI.UDim(0, x + deltaTime * obj.xSpeed)
        local newYPos = CEGUI.UDim(0, y + deltaTime * obj.ySpeed)
        obj.pCell:setPosition(CEGUI.UVector2(newXPos, newYPos))
    else
        obj.Clear()
    end
end
function AddNewItemsEffect.CheckPlayNextEffect()
    local obj = AddNewItemsEffect
    if not obj then
        return
    end
    if not obj.m_vNewItems then
        return
    end
    obj.m_bDrawEffectNow = false
    local len = #obj.m_vNewItems
    if len == 0 then
          obj.ClearUnit()
        return
    else
        obj.m_bDrawEffectNow = true
        obj.StartPlayEffect(obj.m_vNewItems[1])
    end
end
function AddNewItemsEffect.ClearUnit()
    local obj = AddNewItemsEffect
    if not obj then
        return
    end
    obj.Clear()
    obj.m_iStartTime = obj.GetSumTime()
end
-- 播放特效
function AddNewItemsEffect.PlayAddItemsEffect(itemicons, itemnums, vItemId)
    local obj = AddNewItemsEffect
    if not obj then
        return
    end
    local entry = { }
    local cell = { }
    cell.icon = itemicons
    cell.num = itemnums
    cell.nItemId = vItemId
    table.insert(entry, cell)
    table.insert(obj.m_vNewItems, entry)
    if obj.m_bDrawEffectNow == false then
        obj.m_bDrawEffectNow = true
        obj.StartPlayEffect(entry)
    end
end

function AddNewItemsEffect.StartPlayEffect(icons)
    local obj = AddNewItemsEffect
    if not obj then
        return
    end
    local pRootWindow = CEGUI.System:getSingleton():getGUISheet()
    if not pRootWindow then
        return
    end
    local len = #icons
    if not len then
        return
    end
    if len == 0 then
        return
    end
    obj.ClearUnit()
    local mode = Nuclear.GetEngine():GetRenderer():GetDisplayMode()
    local winMgr = CEGUI.WindowManager:getSingleton()
    if not mode then
        return
    end
    if not winMgr then
        return
    end
    if not winMgr:isWindowPresent(MHSD_UTILS.get_msgtipstring(144956)) then
        return
    end
    local pPackWindow = winMgr:getWindow(MHSD_UTILS.get_msgtipstring(144956))
    if not pPackWindow then
        return
    end
    local EndPoint = Nuclear.NuclearFPoint(pPackWindow:GetScreenPos().x, pPackWindow:GetScreenPos().y)
    obj.m_iDestXPos = EndPoint.x
    obj.m_iDestYPos = EndPoint.y
    local xPos = 0
    if mode.width == 800 then
        xPos =(mode.width - 46) / 2 - 50
    else
        xPos =(mode.width - 46) / 2
    end
    local yPos = mode.height - 200
    if obj.m_bHasItemUnit == false then
        obj.m_bHasItemUnit = true
        local name = "AddItem_ItemCell_"
        obj.pCell = CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell", name))
        CEGUI.System:getSingleton():getGUISheet():addChildWindow(obj.pCell)
        obj.pCell:setMousePassThroughEnabled(true)
    end
    obj.pCell:setVisible(true)
    obj.pCell:setAlwaysOnTop(true)
    obj.pCell:setAlpha(1.0)
    obj.pCell:setXPosition(CEGUI.UDim(0, xPos))
    obj.pCell:setYPosition(CEGUI.UDim(0, yPos))
    obj.pCell:SetImage(gGetIconManager():GetItemIconByID(icons[1].icon))
    obj.pCell:setSize(CEGUI.UVector2(CEGUI.UDim(0, 77), CEGUI.UDim(0, 77)))
    obj.pCell:EnableAllowModalState(true)
    local attr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(icons[1].nItemId)
    if not attr then
        return
    end
    local huobanType = GetNumberValueForStrKey("ITEM_TYPE_HUOBAN")
    if not huobanType then
        return
    end
    if attr.itemtypeid == huobanType then
        obj.pCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
    end
    local nQuality = attr.nquality
    SetItemCellBoundColorByQulityItemtm(obj.pCell, nQuality)
    local notfound = true
    if icons[1].num > 1 then
        local platsufix = MT3.ChannelManager:GetPlatformLoginSuffix()
        local Text = ""
        if platsufix~= "" then 
        end
    end
    obj.xSpeed =(obj.m_iDestXPos - xPos) /(1000 * s_ItemFlyTime)
    obj.ySpeed =(obj.m_iDestYPos - yPos) / 1000
    obj.m_iStartTime = obj.GetSumTime()
end
function AddNewItemsEffect.GetSumTime()
    return(s_ItemFlyTime + s_ItemStayTime) * 1000
end
return AddNewItemsEffect
