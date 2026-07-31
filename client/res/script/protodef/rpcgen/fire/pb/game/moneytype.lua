require "utils.tableutil"
MoneyType = {
	MoneyType_None = 0,
	MoneyType_SilverCoin = 1,
	MoneyType_GoldCoin = 2,
	MoneyType_HearthStone = 3,
	MoneyType_ProfContribute = 4,
	MoneyType_RongYu = 5,
	MoneyType_FactionContribute = 6,
	MoneyType_ShengWang = 7,
	MoneyType_FestivalPoint = 8,
	MoneyType_GoodTeacherVal = 9,
	MoneyType_RoleExp = 10,
	MoneyType_Activity = 11,
	MoneyType_Energy = 12,
	MoneyType_EreditPoint = 13,
	MoneyType_Item = 99,
	MoneyType_Num = 15
}
MoneyType.__index = MoneyType


function MoneyType:new()
	local self = {}
	setmetatable(self, MoneyType)
	return self
end
function MoneyType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function MoneyType:unmarshal(_os_)
	return _os_
end

return MoneyType
