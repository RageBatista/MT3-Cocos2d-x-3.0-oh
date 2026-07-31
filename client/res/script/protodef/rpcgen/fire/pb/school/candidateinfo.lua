require "utils.tableutil"
CandidateInfo = {}
CandidateInfo.__index = CandidateInfo


function CandidateInfo:new()
	local self = {}
	setmetatable(self, CandidateInfo)
	self.roleid = 0
	self.rolename = "" 
	self.tickets = 0
	self.words = "" 
	self.shape = 0
	self.components = {}

	return self
end
function CandidateInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.tickets)
	_os_:marshal_wstring(self.words)
	_os_:marshal_int32(self.shape)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function CandidateInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.tickets = _os_:unmarshal_int32()
	self.words = _os_:unmarshal_wstring(self.words)
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
	return _os_
end

return CandidateInfo
