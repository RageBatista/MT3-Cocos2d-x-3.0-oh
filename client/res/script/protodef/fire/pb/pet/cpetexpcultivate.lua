require "utils.tableutil"
CPetExpCultivate = {}
CPetExpCultivate.__index = CPetExpCultivate



CPetExpCultivate.PROTOCOL_TYPE = 788523

function CPetExpCultivate.Create()
	print("enter CPetExpCultivate create")
	return CPetExpCultivate:new()
end
function CPetExpCultivate:new()
	local self = {}
	setmetatable(self, CPetExpCultivate)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.itemid = 0
	self.itemnum = 0

	return self
end
function CPetExpCultivate:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetExpCultivate:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_char(self.itemnum)
	return _os_
end

function CPetExpCultivate:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.itemid = _os_:unmarshal_int32()
	self.itemnum = _os_:unmarshal_char()
	return _os_
end

return CPetExpCultivate
