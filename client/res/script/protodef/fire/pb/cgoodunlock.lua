require "utils.tableutil"
CGoodUnLock = {}
CGoodUnLock.__index = CGoodUnLock



CGoodUnLock.PROTOCOL_TYPE = 786582

function CGoodUnLock.Create()
	print("enter CGoodUnLock create")
	return CGoodUnLock:new()
end
function CGoodUnLock:new()
	local self = {}
	setmetatable(self, CGoodUnLock)
	self.type = self.PROTOCOL_TYPE
	self.password = "" 

	return self
end
function CGoodUnLock:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGoodUnLock:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.password)
	return _os_
end

function CGoodUnLock:unmarshal(_os_)
	self.password = _os_:unmarshal_wstring(self.password)
	return _os_
end

return CGoodUnLock
