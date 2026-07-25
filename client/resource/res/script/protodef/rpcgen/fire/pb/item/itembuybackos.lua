require "utils.tableutil"
ItemBuyBackOs = {}
ItemBuyBackOs.__index = ItemBuyBackOs


function ItemBuyBackOs:new()
	local self = {}
	--(6,3,0,0,40013,珍珠,40013,1000,0,06:00:00,12:00:00,)
	setmetatable(self, ItemBuyBackOs)
	self.id = 0
	self.itemtype = 0
	self.timelimit = 0
	self.timelimitnum = 0
	self.itemid = 0
	self.itemname = ""
	self.recoveryprice = 0
	self.recoverynum = 0
	self.getstatus = 0
	self.starttime = ""
	self.endtime = ""

	return self
end
function ItemBuyBackOs:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.timelimit)
	_os_:marshal_int32(self.timelimitnum)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_wstring(self.itemname)
	_os_:marshal_int32(self.recoveryprice)
	_os_:marshal_int32(self.recoverynum)
	_os_:marshal_int32(self.getstatus)
	_os_:marshal_wstring(self.starttime)
	_os_:marshal_wstring(self.endtime)
	return _os_
end

function ItemBuyBackOs:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.itemtype = _os_:unmarshal_int32()
	self.timelimit = _os_:unmarshal_int32()
	self.timelimitnum = _os_:unmarshal_int32()
	self.itemid = _os_:unmarshal_int32()
	self.itemname = _os_:unmarshal_wstring(self.itemname)
	self.recoveryprice = _os_:unmarshal_int32()
	self.recoverynum = _os_:unmarshal_int32()
	self.getstatus = _os_:unmarshal_int32()
	self.starttime = _os_:unmarshal_wstring(self.starttime)
	self.endtime = _os_:unmarshal_wstring(self.endtime)
	return _os_
end

return ItemBuyBackOs
