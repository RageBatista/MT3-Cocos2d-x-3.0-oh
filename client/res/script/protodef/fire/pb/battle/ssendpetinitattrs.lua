require "utils.tableutil"
SSendPetInitAttrs = {}
SSendPetInitAttrs.__index = SSendPetInitAttrs



SSendPetInitAttrs.PROTOCOL_TYPE = 793456

function SSendPetInitAttrs.Create()
	print("enter SSendPetInitAttrs create")
	return SSendPetInitAttrs:new()
end
function SSendPetInitAttrs:new()
	local self = {}
	setmetatable(self, SSendPetInitAttrs)
	self.type = self.PROTOCOL_TYPE
	self.petinitattrs = {}

	return self
end
function SSendPetInitAttrs:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendPetInitAttrs:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.petinitattrs))
	for k,v in pairs(self.petinitattrs) do
		_os_:marshal_int32(k)
		_os_:marshal_float(v)
	end

	return _os_
end

function SSendPetInitAttrs:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_petinitattrs=0,_os_null_petinitattrs
	_os_null_petinitattrs, sizeof_petinitattrs = _os_: uncompact_uint32(sizeof_petinitattrs)
	for k = 1,sizeof_petinitattrs do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_float()
		self.petinitattrs[newkey] = newvalue
	end
	return _os_
end

return SSendPetInitAttrs
