require "utils.tableutil"
CBattleFieldRankList = {}
CBattleFieldRankList.__index = CBattleFieldRankList



CBattleFieldRankList.PROTOCOL_TYPE = 808538

function CBattleFieldRankList.Create()
	print("enter CBattleFieldRankList create")
	return CBattleFieldRankList:new()
end
function CBattleFieldRankList:new()
	local self = {}
	setmetatable(self, CBattleFieldRankList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBattleFieldRankList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBattleFieldRankList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBattleFieldRankList:unmarshal(_os_)
	return _os_
end

return CBattleFieldRankList
