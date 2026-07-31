require "utils.tableutil"
UseFormBook = {}
UseFormBook.__index = UseFormBook


function UseFormBook:new()
	local self = {}
	setmetatable(self, UseFormBook)
	self.bookid = 0
	self.num = 0

	return self
end
function UseFormBook:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.bookid)
	_os_:marshal_int32(self.num)
	return _os_
end

function UseFormBook:unmarshal(_os_)
	self.bookid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return UseFormBook
