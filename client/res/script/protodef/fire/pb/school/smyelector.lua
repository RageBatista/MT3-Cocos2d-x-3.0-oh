require "utils.tableutil"
SMyElector = {}
SMyElector.__index = SMyElector



SMyElector.PROTOCOL_TYPE = 810443

function SMyElector.Create()
	print("enter SMyElector create")
	return SMyElector:new()
end
function SMyElector:new()
	local self = {}
	setmetatable(self, SMyElector)
	self.type = self.PROTOCOL_TYPE
	self.electorwords = "" 

	return self
end
function SMyElector:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMyElector:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.electorwords)
	return _os_
end

function SMyElector:unmarshal(_os_)
	self.electorwords = _os_:unmarshal_wstring(self.electorwords)
	return _os_
end

return SMyElector
