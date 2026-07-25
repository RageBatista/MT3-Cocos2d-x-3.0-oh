require "utils.tableutil"
SMemberSequence = {}
SMemberSequence.__index = SMemberSequence



SMemberSequence.PROTOCOL_TYPE = 794467

function SMemberSequence.Create()
	print("enter SMemberSequence create")
	return SMemberSequence:new()
end
function SMemberSequence:new()
	local self = {}
	setmetatable(self, SMemberSequence)
	self.type = self.PROTOCOL_TYPE
	self.teammemeberlist = {}

	return self
end
function SMemberSequence:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMemberSequence:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.teammemeberlist))
	for k,v in ipairs(self.teammemeberlist) do
		_os_:marshal_int64(v)
	end

	return _os_
end

function SMemberSequence:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_teammemeberlist=0 ,_os_null_teammemeberlist
	_os_null_teammemeberlist, sizeof_teammemeberlist = _os_: uncompact_uint32(sizeof_teammemeberlist)
	for k = 1,sizeof_teammemeberlist do
		self.teammemeberlist[k] = _os_:unmarshal_int64()
	end
	return _os_
end

return SMemberSequence
