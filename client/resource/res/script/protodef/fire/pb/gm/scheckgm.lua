require "utils.tableutil"
SCheckGM = {}
SCheckGM.__index = SCheckGM



SCheckGM.PROTOCOL_TYPE = 791437

function SCheckGM.Create()
	print("enter SCheckGM create")
	return SCheckGM:new()
end
function SCheckGM:new()
	local self = {}
	setmetatable(self, SCheckGM)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SCheckGM:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCheckGM:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SCheckGM:unmarshal(_os_)
	return _os_
end

return SCheckGM
