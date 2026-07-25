require "utils.tableutil"
SGiveName = {}
SGiveName.__index = SGiveName



SGiveName.PROTOCOL_TYPE = 786475

function SGiveName.Create()
	print("enter SGiveName create")
	return SGiveName:new()
end
function SGiveName:new()
	local self = {}
	setmetatable(self, SGiveName)
	self.type = self.PROTOCOL_TYPE
	self.rolename = "" 

	return self
end
function SGiveName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGiveName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.rolename)
	return _os_
end

function SGiveName:unmarshal(_os_)
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	return _os_
end

return SGiveName
