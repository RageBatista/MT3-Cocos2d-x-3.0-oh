require "utils.tableutil"
SGetRankModel = {}
SGetRankModel.__index = SGetRankModel

SGetRankModel.PROTOCOL_TYPE = 810243

function SGetRankModel.Create()
	print("enter SGetRankModel create")
	return SGetRankModel:new()
end
function SGetRankModel:new()
	local self = {}
	setmetatable(self, SGetRankModel)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.rolename = "" 
	self.model = 0
	self.rownum = 0  
	self.ranktype = 0  -- 添加新的变量 ranktype
	self.components = {}

	return self
end
function SGetRankModel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetRankModel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.model)
	_os_:marshal_int32(self.rownum)  
	_os_:marshal_int32(self.ranktype)  -- 编码 ranktype

	-- marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SGetRankModel:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.model = _os_:unmarshal_int32()
	self.rownum = _os_:unmarshal_int32()  
	self.ranktype = _os_:unmarshal_int32()  -- 解码 ranktype

	-- unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	return _os_
end

return SGetRankModel
