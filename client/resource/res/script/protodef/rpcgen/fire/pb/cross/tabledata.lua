require "utils.tableutil"
TableData = {}
TableData.__index = TableData


function TableData:new()
	local self = {}
	setmetatable(self, TableData)
	self.tablename = "" 
	self.valuedata = FireNet.Octets() 
	self.keydata = FireNet.Octets() 

	return self
end
function TableData:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.tablename)
	_os_: marshal_octets(self.valuedata)
	_os_: marshal_octets(self.keydata)
	return _os_
end

function TableData:unmarshal(_os_)
	self.tablename = _os_:unmarshal_wstring(self.tablename)
	_os_:unmarshal_octets(self.valuedata)
	_os_:unmarshal_octets(self.keydata)
	return _os_
end

return TableData
