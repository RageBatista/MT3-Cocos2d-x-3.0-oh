require "utils.tableutil"
CSendElectorWords = {}
CSendElectorWords.__index = CSendElectorWords



CSendElectorWords.PROTOCOL_TYPE = 810435

function CSendElectorWords.Create()
	print("enter CSendElectorWords create")
	return CSendElectorWords:new()
end
function CSendElectorWords:new()
	local self = {}
	setmetatable(self, CSendElectorWords)
	self.type = self.PROTOCOL_TYPE
	self.electorwords = "" 

	return self
end
function CSendElectorWords:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendElectorWords:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.electorwords)
	return _os_
end

function CSendElectorWords:unmarshal(_os_)
	self.electorwords = _os_:unmarshal_wstring(self.electorwords)
	return _os_
end

return CSendElectorWords
