require "utils.tableutil"
CTradingSpotCardView = {}
CTradingSpotCardView.__index = CTradingSpotCardView



CTradingSpotCardView.PROTOCOL_TYPE = 812637

function CTradingSpotCardView.Create()
	print("enter CTradingSpotCardView create")
	return CTradingSpotCardView:new()
end
function CTradingSpotCardView:new()
	local self = {}
	setmetatable(self, CTradingSpotCardView)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CTradingSpotCardView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTradingSpotCardView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CTradingSpotCardView:unmarshal(_os_)
	return _os_
end

return CTradingSpotCardView
