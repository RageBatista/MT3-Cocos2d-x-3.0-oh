require "utils.tableutil"
CRoleTradingRecordView = {}
CRoleTradingRecordView.__index = CRoleTradingRecordView



CRoleTradingRecordView.PROTOCOL_TYPE = 812641

function CRoleTradingRecordView.Create()
	print("enter CRoleTradingRecordView create")
	return CRoleTradingRecordView:new()
end
function CRoleTradingRecordView:new()
	local self = {}
	setmetatable(self, CRoleTradingRecordView)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRoleTradingRecordView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRoleTradingRecordView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRoleTradingRecordView:unmarshal(_os_)
	return _os_
end

return CRoleTradingRecordView
