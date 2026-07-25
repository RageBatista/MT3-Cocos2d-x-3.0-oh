LeiTaiDataManager =
{
    m_FilterMode = - 1,
    -- 职业筛选
    m_LevelArea = 0,
    -- 筛选的角色等级区间 0表示全选
    m_EntryList = { },
    ModularType = 1,
    m_EntryList2 = { },
    m_Time = 0,
    m_IsTick = false,
}
function LeiTaiDataManager.Run(dt)
    if LeiTaiDataManager.m_IsTick then
        LeiTaiDataManager.m_Time = LeiTaiDataManager.m_Time + dt
        if LeiTaiDataManager.m_Time > 40000 then
            LeiTaiDataManager.m_IsTick = false
            LeiTaiDataManager.m_Time = 0 
            GetCTipsManager():AddMessageTipById(160425)
            return
        end
    end

end
return LeiTaiDataManager
