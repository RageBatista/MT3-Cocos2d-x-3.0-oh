require "utils.tableutil"
SFreshRepairData = {}
SFreshRepairData.__index = SFreshRepairData



SFreshRepairData.PROTOCOL_TYPE = 787756

function SFreshRepairData.Create()
	print("enter SFreshRepairData create")
	return SFreshRepairData:new()
end
function SFreshRepairData:new()
	local self = {}
	setmetatable(self, SFreshRepairData)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SFreshRepairData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFreshRepairData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SFreshRepairData:unmarshal(_os_)
	return _os_
end

return SFreshRepairData
