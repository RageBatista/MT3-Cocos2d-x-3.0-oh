require "utils.tableutil"
SRefreshPetData = {}
SRefreshPetData.__index = SRefreshPetData



SRefreshPetData.PROTOCOL_TYPE = 799433

function SRefreshPetData.Create()
	print("enter SRefreshPetData create")
	return SRefreshPetData:new()
end
function SRefreshPetData:new()
	local self = {}
	setmetatable(self, SRefreshPetData)
	self.type = self.PROTOCOL_TYPE
	self.columnid = 0
	self.petkey = 0
	self.datas = {}

	return self
end
function SRefreshPetData:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPetData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.columnid)
	_os_:marshal_int32(self.petkey)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.datas))
	for k,v in pairs(self.datas) do
		_os_:marshal_int32(k)
		_os_:marshal_float(v)
	end

	return _os_
end

function SRefreshPetData:unmarshal(_os_)
	self.columnid = _os_:unmarshal_int32()
	self.petkey = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_datas=0,_os_null_datas
	_os_null_datas, sizeof_datas = _os_: uncompact_uint32(sizeof_datas)
	for k = 1,sizeof_datas do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_float()
		self.datas[newkey] = newvalue
	end
	return _os_
end

return SRefreshPetData
