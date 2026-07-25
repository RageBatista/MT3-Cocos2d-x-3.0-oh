require "utils.tableutil"
ArchiveInfo = {}
ArchiveInfo.__index = ArchiveInfo


function ArchiveInfo:new()
	local self = {}
	setmetatable(self, ArchiveInfo)
	self.archiveid = 0
	self.state = 0

	return self
end
function ArchiveInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.archiveid)
	_os_:marshal_int32(self.state)
	return _os_
end

function ArchiveInfo:unmarshal(_os_)
	self.archiveid = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	return _os_
end

return ArchiveInfo
