require "utils.tableutil"
SPlayXianJingCG = {}
SPlayXianJingCG.__index = SPlayXianJingCG



SPlayXianJingCG.PROTOCOL_TYPE = 805544

function SPlayXianJingCG.Create()
	print("enter SPlayXianJingCG create")
	return SPlayXianJingCG:new()
end
function SPlayXianJingCG:new()
	local self = {}
	setmetatable(self, SPlayXianJingCG)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SPlayXianJingCG:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPlayXianJingCG:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SPlayXianJingCG:unmarshal(_os_)
	return _os_
end

return SPlayXianJingCG
