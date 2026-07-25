require "utils.tableutil"
CNpctiaozhansl = {}
CNpctiaozhansl.__index = CNpctiaozhansl



CNpctiaozhansl.PROTOCOL_TYPE = 800099

function CNpctiaozhansl.Create()
	print("enter CNpctiaozhansl create")
	return CNpctiaozhansl:new()
end
function CNpctiaozhansl:new()
	local self = {}
	setmetatable(self, CNpctiaozhansl)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CNpctiaozhansl:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CNpctiaozhansl:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CNpctiaozhansl:unmarshal(_os_)
	return _os_
end

return CNpctiaozhansl
