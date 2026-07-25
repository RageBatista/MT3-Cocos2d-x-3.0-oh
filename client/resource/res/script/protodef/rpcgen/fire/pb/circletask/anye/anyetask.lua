require "utils.tableutil"
AnYeTask = {}
AnYeTask.__index = AnYeTask


function AnYeTask:new()
	local self = {}
	setmetatable(self, AnYeTask)
	self.pos = 0
	self.id = 0
	self.kind = 0
	self.state = 0
	self.dstitemid = 0
	self.dstitemnum = 0
	self.dstnpckey = 0
	self.dstnpcid = 0
	self.legend = 0
	self.legendtime = 0
	self.legendend = 0

	return self
end
function AnYeTask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pos)
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.kind)
	_os_:marshal_int32(self.state)
	_os_:marshal_int32(self.dstitemid)
	_os_:marshal_int32(self.dstitemnum)
	_os_:marshal_int64(self.dstnpckey)
	_os_:marshal_int32(self.dstnpcid)
	_os_:marshal_int32(self.legend)
	_os_:marshal_int64(self.legendtime)
	_os_:marshal_int64(self.legendend)
	return _os_
end

function AnYeTask:unmarshal(_os_)
	self.pos = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int32()
	self.kind = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	self.dstitemid = _os_:unmarshal_int32()
	self.dstitemnum = _os_:unmarshal_int32()
	self.dstnpckey = _os_:unmarshal_int64()
	self.dstnpcid = _os_:unmarshal_int32()
	self.legend = _os_:unmarshal_int32()
	self.legendtime = _os_:unmarshal_int64()
	self.legendend = _os_:unmarshal_int64()
	return _os_
end

return AnYeTask
