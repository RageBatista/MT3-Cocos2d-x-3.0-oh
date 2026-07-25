require "utils.tableutil"
RefreshDataType = {
	STATE = 1,
	DEST_NPD_KEY = 2,
	DEST_NPD_ID = 3,
	DEST_MAP_ID = 4,
	DEST_XPOS = 5,
	DEST_YPOS = 6,
	DEST_ITEM_ID = 7,
	SUMNUM = 8,
	DEST_ITEM1_NUM = 9,
	DEST_ITEM2_ID = 10,
	DEST_ITEM2_NUM = 11,
	QUEST_TYPE = 12
}
RefreshDataType.__index = RefreshDataType


function RefreshDataType:new()
	local self = {}
	setmetatable(self, RefreshDataType)
	return self
end
function RefreshDataType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function RefreshDataType:unmarshal(_os_)
	return _os_
end

return RefreshDataType
