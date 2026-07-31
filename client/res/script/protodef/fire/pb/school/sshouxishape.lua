require "utils.tableutil"
SShouxiShape = {}
SShouxiShape.__index = SShouxiShape



SShouxiShape.PROTOCOL_TYPE = 810438

function SShouxiShape.Create()
	print("enter SShouxiShape create")
	return SShouxiShape:new()
end
function SShouxiShape:new()
	local self = {}
	setmetatable(self, SShouxiShape)
	self.type = self.PROTOCOL_TYPE
	self.shouxikey = 0
	self.name = "" 
	self.shape = 0
	self.components = {}
	self.titleid = 0

	return self
end
function SShouxiShape:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SShouxiShape:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.shouxikey)
	_os_:marshal_wstring(self.name)
	_os_:marshal_int32(self.shape)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.titleid)
	return _os_
end

function SShouxiShape:unmarshal(_os_)
	self.shouxikey = _os_:unmarshal_int64()
	self.name = _os_:unmarshal_wstring(self.name)
	self.shape = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	self.titleid = _os_:unmarshal_int32()
	return _os_
end

return SShouxiShape
