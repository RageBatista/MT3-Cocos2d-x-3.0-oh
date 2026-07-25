
-- 排序类型
SORT_UP       = 1       -- 升序
SORT_DOWN     = 2       -- 降序

-- 排序方式
eSort_None    = 0       -- 无排序
eSort_Name    = 1       -- 玩家名称排序
eSort_Sex     = 2       -- 玩家性别排序
eSort_Level   = 3       -- 玩家等级排序
eSort_ZhiYe   = 4       -- 玩家职业排序
eSort_PingJia = 5       -- 玩家综合战力排序
eSort_Vip     = 6       -- 玩家VIP排序

eZhiYe_ZhanShi  = 11    -- 战士
eZhiYe_QiShi    = 12    -- 圣骑
eZhiYe_LieRen   = 13    -- 猎人
eZhiYe_DeLuYi   = 14    -- 德鲁伊
eZhiYe_FaShi    = 15    -- 法师
eZhiYe_MuShi    = 16    -- 牧师
eZhiYe_SaMan    = 17    -- 萨满
eZhiYe_DaoZei   = 18    -- 盗贼
eZhiYe_ShuShi   = 19    -- 术士

eSex_Man        = 1     -- 男
eSex_Woman      = 2     -- 女

eResTipID_Man   = 1188  -- 男
eResTipID_Woman = 1187  -- 女

-- 职业筛选对照表
ZHIYE_SHAIXUAN =
{
    [eZhiYe_ZhanShi]    = 1,    -- 战士
    [eZhiYe_QiShi]      = 2,    -- 圣骑
    [eZhiYe_LieRen]     = 4,    -- 猎人
    [eZhiYe_DeLuYi]     = 8,    -- 德鲁伊
    [eZhiYe_FaShi]      = 16,   -- 法师
    [eZhiYe_MuShi]      = 32,   -- 牧师
    [eZhiYe_SaMan]      = 64,   -- 萨满
    [eZhiYe_DaoZei]     = 128,  -- 盗贼
    [eZhiYe_ShuShi]     = 256,  -- 术士
}

-------------------------------------------------------------------------------------------------------

FamilyYaoQingCommon =
{
    m_YaoQingList = {},         -- 邀请列表

    m_type_level = 1,           -- 等级筛选
    m_vec_type_school = {},     -- 职业筛选  代表选择的职业列表
    m_type_sex = -1,            -- 性别筛选  -1代表没有选择，也代表不进行筛选

    m_tmp_type_level = 1,       -- 临时等级筛选
    m_tmp_vec_type_school = {}, -- 临时职业筛选  代表选择的职业列表
    m_tmp_type_sex = -1,        -- 临时性别筛选  -1代表没有选择，也代表不进行筛选
}

-- 按照排序方式和排序类型进行排序
function FamilyYaoQingCommon.Sort(sortMode, sortType)
    -- 按玩家名称排序
    if sortMode == eSort_Name then
        if sortType == SORT_UP then
            -- 升序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.roleid < b.roleid end)
        elseif sortType == SORT_DOWN then
            -- 降序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.roleid > b.roleid end)
        end
    -- 按玩家性别排序
    elseif sortMode == eSort_Sex then
        if sortType == SORT_UP then
            -- 升序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.sex < b.sex end)
        elseif sortType == SORT_DOWN then
            -- 降序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.sex > b.sex end)
        end
    -- 按玩家等级排序
    elseif sortMode == eSort_Level then
        if sortType == SORT_UP then
            -- 升序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.level < b.level end)
        elseif sortType == SORT_DOWN then
            -- 降序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.level > b.level end)
        end
    -- 按玩家职业排序
    elseif sortMode == eSort_ZhiYe then
        if sortType == SORT_UP then
            -- 升序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.school < b.school end)
        elseif sortType == SORT_DOWN then
            -- 降序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.school > b.school end)
        end
    -- 按玩家综合战力排序
    elseif sortMode == eSort_PingJia then
        if sortType == SORT_UP then
            -- 升序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.fightvalue < b.fightvalue end)
        elseif sortType == SORT_DOWN then
            -- 降序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.fightvalue > b.fightvalue end)
        end
    -- 按玩家VIP排序
    elseif sortMode == eSort_Vip then
        if sortType == SORT_UP then
            -- 升序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.vip < b.vip end)
        elseif sortType == SORT_DOWN then
            -- 降序
            table.sort(FamilyYaoQingCommon.m_YaoQingList, function(a,b) return a.vip > b.vip end)
        end
    end
end

-------------------------------------------------------------------------------------------------------

-- 邀请列表请求结果刷新
function FamilyYaoQingCommon.RefreshYaoQingList(list)
    -- 刷新邀请列表
    FamilyYaoQingCommon.m_YaoQingList = {}
    if list then
        for i = 1, #list do
            local member = list[i]
            table.insert(FamilyYaoQingCommon.m_YaoQingList, list[i])
        end
    end

    -- 刷新界面
    if FamilyYaoQingDialog.getInstanceNotCreate() then
        FamilyYaoQingDialog.getInstanceNotCreate():InitListView()
    end
end

-- 邀请的搜索结果刷新
function FamilyYaoQingCommon.RefreshYaoQing(info)
    -- 刷新邀请列表
    FamilyYaoQingCommon.m_YaoQingList = {}
    if info then
        table.insert(FamilyYaoQingCommon.m_YaoQingList, info)
    end

    -- 刷新界面
    if FamilyYaoQingDialog.getInstanceNotCreate() then
        FamilyYaoQingDialog.getInstanceNotCreate():InitListView()
    end
end

-- 请求邀请列表
function FamilyYaoQingCommon.RequestYaoQingList()
    local p = require "protodef.fire.pb.clan.cclaninvitationview":new()
    p.type_level = FamilyYaoQingCommon.m_type_level
    p.type_school = FamilyYaoQingCommon.CalcTypeSchool()
    p.type_sex = FamilyYaoQingCommon.m_type_sex
    require "manager.luaprotocolmanager":send(p)
end

-------------------------------------------------------------------------------------------------------

-- 临时设置等级筛选
function FamilyYaoQingCommon.SetTmpTypeLevel(level)
    FamilyYaoQingCommon.m_tmp_type_level = level
end

-- 临时设置职业筛选
function FamilyYaoQingCommon.SetTmpTypeSchool(school)
    local bInVec = false
    for k,v in pairs(FamilyYaoQingCommon.m_tmp_vec_type_school) do
        if v == school then
            table.remove(FamilyYaoQingCommon.m_tmp_vec_type_school, k)
            bInVec = true
            break
        end
    end
    if not bInVec then
        table.insert(FamilyYaoQingCommon.m_tmp_vec_type_school, school)
    end
end

-- 计算职业筛选的值
function FamilyYaoQingCommon.CalcTypeSchool()
    if #FamilyYaoQingCommon.m_vec_type_school == 0 then
        return -1
    else
        local type_school = 0
        for _,v in pairs(FamilyYaoQingCommon.m_vec_type_school) do
            local value = ZHIYE_SHAIXUAN[v] or 0
            type_school = type_school + value
        end
        if type_school == 0 then
            return -1
        else
            return type_school
        end
    end
end

-- 临时设置性别筛选
function FamilyYaoQingCommon.SetTmpTypeSex(sex)
    if FamilyYaoQingCommon.m_tmp_type_sex == sex then
        FamilyYaoQingCommon.m_tmp_type_sex = -1
    else
        FamilyYaoQingCommon.m_tmp_type_sex = sex
    end
end

-- 重置临时筛选
function FamilyYaoQingCommon.ResetTmpShaiXuan()
    FamilyYaoQingCommon.m_tmp_type_level = FamilyYaoQingCommon.m_type_level

    FamilyYaoQingCommon.m_tmp_vec_type_school = {}
    for k,v in pairs(FamilyYaoQingCommon.m_vec_type_school) do
        table.insert(FamilyYaoQingCommon.m_tmp_vec_type_school, v)
    end

    FamilyYaoQingCommon.m_tmp_type_sex = FamilyYaoQingCommon.m_type_sex
end

-- 确认临时筛选
function FamilyYaoQingCommon.ConfirmTmpShaiXuan()
    FamilyYaoQingCommon.m_type_level = FamilyYaoQingCommon.m_tmp_type_level

    FamilyYaoQingCommon.m_vec_type_school = {}
    for k,v in pairs(FamilyYaoQingCommon.m_tmp_vec_type_school) do
        table.insert(FamilyYaoQingCommon.m_vec_type_school, v)
    end

    FamilyYaoQingCommon.m_type_sex = FamilyYaoQingCommon.m_tmp_type_sex
end

return FamilyYaoQingCommon