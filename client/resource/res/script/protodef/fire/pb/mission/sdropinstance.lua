require "utils.tableutil"
SDropInstance = {}
SDropInstance.__index = SDropInstance



SDropInstance.PROTOCOL_TYPE = 805549

function SDropInstance.Create()
	print("enter SDropInstance create")
	return SDropInstance:new()
end
function SDropInstance:new()
	local self = {}
	setmetatable(self, SDropInstance)
	self.type = self.PROTOCOL_TYPE
	self.messageid = 0
	self.landname = "" 

	return self
end
function SDropInstance:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDropInstance:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.messageid)
	_os_:marshal_wstring(self.landname)
	return _os_
end

function SDropInstance:unmarshal(_os_)
	self.messageid = _os_:unmarshal_int32()
	self.landname = _os_:unmarshal_wstring(self.landname)
	return _os_
end

return SDropInstance
