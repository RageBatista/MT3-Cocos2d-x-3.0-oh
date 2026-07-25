ChargeDataManager =
{
    m_ChargeReturnList = { }
}
--改变数据
function ChargeDataManager.ChangeData(id, status)
    for _, v in pairs(ChargeDataManager.m_ChargeReturnList) do
        if v.id == id then
            v.status = status
        end
    end
end
--更新红点状态
function ChargeDataManager.GetRedPointStatus()
    local redPoint = false
    for _,v in pairs(ChargeDataManager.m_ChargeReturnList) do
     if v.status == 1 then
      redPoint = true
      break
     end
    end
    return redPoint
end

return ChargeDataManager
