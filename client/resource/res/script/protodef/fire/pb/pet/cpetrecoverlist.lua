require "utils.tableutil"
CPetRecoverList = {}
CPetRecoverList.__index = CPetRecoverList



CPetRecoverList.PROTOCOL_TYPE = 788583

function CPetRecoverList.Create()
	print("enter CPetRecoverList create")
	return CPetRecoverList:new()
end
function CPetRecoverList:new()
	local self = {}
	setmetatable(self, CPetRecoverList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CPetRecoverList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetRecoverList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CPetRecoverList:unmarshal(_os_)
	return _os_
end

return CPetRecoverList
