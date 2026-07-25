require "utils.tableutil"
CRoleTradingView = {}
CRoleTradingView.__index = CRoleTradingView



CRoleTradingView.PROTOCOL_TYPE = 812639

function CRoleTradingView.Create()
	print("enter CRoleTradingView create")
	return CRoleTradingView:new()
end
function CRoleTradingView:new()
	local self = {}
	setmetatable(self, CRoleTradingView)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRoleTradingView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRoleTradingView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRoleTradingView:unmarshal(_os_)
	return _os_
end

return CRoleTradingView
