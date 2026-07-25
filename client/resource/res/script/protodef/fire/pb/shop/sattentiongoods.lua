require "utils.tableutil"
SAttentionGoods = {}
SAttentionGoods.__index = SAttentionGoods



SAttentionGoods.PROTOCOL_TYPE = 810659

function SAttentionGoods.Create()
	print("enter SAttentionGoods create")
	return SAttentionGoods:new()
end
function SAttentionGoods:new()
	local self = {}
	setmetatable(self, SAttentionGoods)
	self.type = self.PROTOCOL_TYPE
	self.attentype = 0
	self.id = 0
	self.attentiontype = 0
	self.itemtype = 0

	return self
end
function SAttentionGoods:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAttentionGoods:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.attentype)
	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.attentiontype)
	_os_:marshal_int32(self.itemtype)
	return _os_
end

function SAttentionGoods:unmarshal(_os_)
	self.attentype = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int64()
	self.attentiontype = _os_:unmarshal_int32()
	self.itemtype = _os_:unmarshal_int32()
	return _os_
end

return SAttentionGoods
