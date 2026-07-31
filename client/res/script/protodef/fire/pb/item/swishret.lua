require "utils.tableutil"
SWishRet = {}
SWishRet.__index = SWishRet



SWishRet.PROTOCOL_TYPE = 810021

function SWishRet.Create()
	print("enter SWishRet create")
	return SWishRet:new()
end
function SWishRet:new()
	local self = {}
	setmetatable(self, SWishRet)
	self.type = self.PROTOCOL_TYPE
	self.datas = {}

	return self
end
function SWishRet:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SWishRet:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.datas))
	for k,v in ipairs(self.datas) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SWishRet:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_datas=0,_os_null_datas
	_os_null_datas, sizeof_datas = _os_: uncompact_uint32(sizeof_datas)
	for k = 1,sizeof_datas do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.datas[newkey] = newvalue
	end
	return _os_
end

return SWishRet
