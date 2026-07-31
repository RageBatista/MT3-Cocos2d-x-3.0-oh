require "utils.tableutil"
ImpExamBean = {}
ImpExamBean.__index = ImpExamBean


function ImpExamBean:new()
	local self = {}
	setmetatable(self, ImpExamBean)
	self.questionid = 0
	self.questionnum = 0
	self.righttimes = 0
	self.remaintime = 0
	self.lastright = 0
	self.accuexp = 0
	self.accumoney = 0
	self.delwrongval = 0
	self.chorightval = 0
	self.helpcnt = 0

	return self
end
function ImpExamBean:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questionid)
	_os_:marshal_int32(self.questionnum)
	_os_:marshal_int32(self.righttimes)
	_os_:marshal_int64(self.remaintime)
	_os_:marshal_char(self.lastright)
	_os_:marshal_int32(self.accuexp)
	_os_:marshal_int32(self.accumoney)
	_os_:marshal_int32(self.delwrongval)
	_os_:marshal_int32(self.chorightval)
	_os_:marshal_int32(self.helpcnt)
	return _os_
end

function ImpExamBean:unmarshal(_os_)
	self.questionid = _os_:unmarshal_int32()
	self.questionnum = _os_:unmarshal_int32()
	self.righttimes = _os_:unmarshal_int32()
	self.remaintime = _os_:unmarshal_int64()
	self.lastright = _os_:unmarshal_char()
	self.accuexp = _os_:unmarshal_int32()
	self.accumoney = _os_:unmarshal_int32()
	self.delwrongval = _os_:unmarshal_int32()
	self.chorightval = _os_:unmarshal_int32()
	self.helpcnt = _os_:unmarshal_int32()
	return _os_
end

return ImpExamBean
