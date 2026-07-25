require "utils.tableutil"
SRecommendsNames = {}
SRecommendsNames.__index = SRecommendsNames



SRecommendsNames.PROTOCOL_TYPE = 786476

function SRecommendsNames.Create()
	print("enter SRecommendsNames create")
	return SRecommendsNames:new()
end
function SRecommendsNames:new()
	local self = {}
	setmetatable(self, SRecommendsNames)
	self.type = self.PROTOCOL_TYPE
	self.recommendnames = {}

	return self
end
function SRecommendsNames:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRecommendsNames:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.recommendnames))
	for k,v in ipairs(self.recommendnames) do
		_os_: marshal_octets(v)
	end

	return _os_
end

function SRecommendsNames:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_recommendnames=0,_os_null_recommendnames
	_os_null_recommendnames, sizeof_recommendnames = _os_: uncompact_uint32(sizeof_recommendnames)
	for k = 1,sizeof_recommendnames do
		self.recommendnames[k] = FireNet.Octets()
		_os_:unmarshal_octets(self.recommendnames[k])
	end
	return _os_
end

return SRecommendsNames
