require "utils.tableutil"
CGeneralSummonCommand = {}
CGeneralSummonCommand.__index = CGeneralSummonCommand



CGeneralSummonCommand.PROTOCOL_TYPE = 795506

function CGeneralSummonCommand.Create()
	print("enter CGeneralSummonCommand create")
	return CGeneralSummonCommand:new()
end
function CGeneralSummonCommand:new()
	local self = {}
	setmetatable(self, CGeneralSummonCommand)
	self.type = self.PROTOCOL_TYPE
	self.summontype = 0
	self.npckey = 0
	self.agree = 0

	return self
end
function CGeneralSummonCommand:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGeneralSummonCommand:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.summontype)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.agree)
	return _os_
end

function CGeneralSummonCommand:unmarshal(_os_)
	self.summontype = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.agree = _os_:unmarshal_int32()
	return _os_
end

return CGeneralSummonCommand
