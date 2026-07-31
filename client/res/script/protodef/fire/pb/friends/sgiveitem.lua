require "utils.tableutil"
SGiveItem = {}
SGiveItem.__index = SGiveItem



SGiveItem.PROTOCOL_TYPE = 806636

function SGiveItem.Create()
	print("enter SGiveItem create")
	return SGiveItem:new()
end
function SGiveItem:new()
	local self = {}
	setmetatable(self, SGiveItem)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.itemnum = 0

	return self
end
function SGiveItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGiveItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_char(self.itemnum)
	return _os_
end

function SGiveItem:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.itemnum = _os_:unmarshal_char()
	return _os_
end

return SGiveItem
