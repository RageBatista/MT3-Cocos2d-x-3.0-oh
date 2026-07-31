require "utils.tableutil"
CFaBaoDuiHuan = {}
CFaBaoDuiHuan.__index = CFaBaoDuiHuan



CFaBaoDuiHuan.PROTOCOL_TYPE = 800095

function CFaBaoDuiHuan.Create()
	print("enter CFaBaoDuiHuan create")
	return CFaBaoDuiHuan:new()
end
function CFaBaoDuiHuan:new()
	local self = {}
	setmetatable(self, CFaBaoDuiHuan)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.gezi = 0
	return self
end
function CFaBaoDuiHuan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFaBaoDuiHuan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.gezi)
	return _os_
end

function CFaBaoDuiHuan:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.gezi = _os_:unmarshal_int32()
	return _os_
end

return CFaBaoDuiHuan
