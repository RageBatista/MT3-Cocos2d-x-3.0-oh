require "utils.tableutil"
CModifyDepotName = {}
CModifyDepotName.__index = CModifyDepotName



CModifyDepotName.PROTOCOL_TYPE = 787771

function CModifyDepotName.Create()
	print("enter CModifyDepotName create")
	return CModifyDepotName:new()
end
function CModifyDepotName:new()
	local self = {}
	setmetatable(self, CModifyDepotName)
	self.type = self.PROTOCOL_TYPE
	self.depotindex = 0
	self.depotname = "" 

	return self
end
function CModifyDepotName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CModifyDepotName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.depotindex)
	_os_:marshal_wstring(self.depotname)
	return _os_
end

function CModifyDepotName:unmarshal(_os_)
	self.depotindex = _os_:unmarshal_int32()
	self.depotname = _os_:unmarshal_wstring(self.depotname)
	return _os_
end

return CModifyDepotName
