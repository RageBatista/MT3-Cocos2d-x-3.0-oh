require "utils.tableutil"
CPetDepotColumnAddCapacity = {}
CPetDepotColumnAddCapacity.__index = CPetDepotColumnAddCapacity



CPetDepotColumnAddCapacity.PROTOCOL_TYPE = 788524

function CPetDepotColumnAddCapacity.Create()
	print("enter CPetDepotColumnAddCapacity create")
	return CPetDepotColumnAddCapacity:new()
end
function CPetDepotColumnAddCapacity:new()
	local self = {}
	setmetatable(self, CPetDepotColumnAddCapacity)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CPetDepotColumnAddCapacity:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetDepotColumnAddCapacity:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CPetDepotColumnAddCapacity:unmarshal(_os_)
	return _os_
end

return CPetDepotColumnAddCapacity
