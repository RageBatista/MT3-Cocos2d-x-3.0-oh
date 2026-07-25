require "utils.tableutil"
RoleZongheRankRecord = {}
RoleZongheRankRecord.__index = RoleZongheRankRecord


function RoleZongheRankRecord:new()
	local self = {}
	setmetatable(self, RoleZongheRankRecord)
	self.rank = 0
	self.roleid = 0
	self.rolename = "" 
	self.school = 0
	self.score = 0
	self.rolelevel = 0
	self.Shape = 0
	self.color1 = 0
	self.color2 = 0
	self.components = {}
	return self
end
function RoleZongheRankRecord:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rank)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.score)
	_os_:marshal_int32(self.rolelevel)
	_os_:marshal_int32(self.Shape)
	_os_:marshal_int32(self.color1)
	_os_:marshal_int32(self.color2)
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end
	return _os_
end

function RoleZongheRankRecord:unmarshal(_os_)
	self.rank = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.school = _os_:unmarshal_int32()
	self.score = _os_:unmarshal_int32()
	self.rolelevel = _os_:unmarshal_int32()
	self.Shape = _os_:unmarshal_int32()
	self.color1 = _os_:unmarshal_int32()
	self.color2 = _os_:unmarshal_int32()
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	return _os_
end

return RoleZongheRankRecord
