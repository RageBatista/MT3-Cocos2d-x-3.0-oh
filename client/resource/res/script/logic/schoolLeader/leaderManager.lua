leaderManager = {
    info = {
    },
    alreadyvote = 0,
    shouxikey = 0,
    selectedInfo = {}
}

function leaderManager:initData(info)
	self.info = info
end

function leaderManager:setSelectedInfo(info)
    self.selectedInfo = info
end

function leaderManager:getSelectedInfo()
    return self.selectedInfo
end

function leaderManager:initOtherInfo(alreadyvote, shouxikey)
    self.alreadyvote = alreadyvote
    self.shouxikey = shouxikey
end

function leaderManager:getDataInfo()
	return self.info
end

function leaderManager:getShouxikey()
    return self.shouxikey
end
function leaderManager:getInfoByIndex( index )
    if index <= 0 or index > #self.info then
        return 
    end
    return self.info[index]
end
return leaderManager
