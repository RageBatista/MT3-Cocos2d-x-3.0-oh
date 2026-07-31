require "utils.tableutil"
CPutOnEquip = {}
CPutOnEquip.__index = CPutOnEquip



CPutOnEquip.PROTOCOL_TYPE = 787445

function CPutOnEquip.Create()
	print("enter CPutOnEquip create")
	return CPutOnEquip:new()
end
function CPutOnEquip:new()
	local self = {}
	setmetatable(self, CPutOnEquip)
	self.type = self.PROTOCOL_TYPE
	self.packkey = 0
	self.dstpos = 0

	return self
end
function CPutOnEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPutOnEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packkey)
	_os_:marshal_int32(self.dstpos)
	return _os_
end

function CPutOnEquip:unmarshal(_os_)
	self.packkey = _os_:unmarshal_int32()
	self.dstpos = _os_:unmarshal_int32()
	return _os_
end

return CPutOnEquip
