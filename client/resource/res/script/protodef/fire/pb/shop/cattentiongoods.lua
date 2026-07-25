require "utils.tableutil"
CAttentionGoods = {}
CAttentionGoods.__index = CAttentionGoods



CAttentionGoods.PROTOCOL_TYPE = 810658

function CAttentionGoods.Create()
	print("enter CAttentionGoods create")
	return CAttentionGoods:new()
end
function CAttentionGoods:new()
	local self = {}
	setmetatable(self, CAttentionGoods)
	self.type = self.PROTOCOL_TYPE
	self.attentype = 0
	self.id = 0
	self.attentiontype = 0
	self.itemtype = 0

	return self
end
function CAttentionGoods:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAttentionGoods:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.attentype)
	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.attentiontype)
	_os_:marshal_int32(self.itemtype)
	return _os_
end

function CAttentionGoods:unmarshal(_os_)
	self.attentype = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int64()
	self.attentiontype = _os_:unmarshal_int32()
	self.itemtype = _os_:unmarshal_int32()
	return _os_
end

return CAttentionGoods
