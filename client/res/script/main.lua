--lua main entry
require "logic.switchaccountdialog"
require "logic.selectserverentry"
require "logic.windowsexplain"
--require "logic.logintipdlg"
require "config"

--avoid memory leak
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)----声音文件应该是

function main()
    --清除所有的message
    if GetCTipsManager() then
        GetCTipsManager():clearMessages()
    end
    local acc = gGetLoginManager():GetAccount()
	local pwd = gGetLoginManager():GetPassword()
	if (not acc or #acc == 0) or (not pwd or #pwd == 0) then
        --if Config.CUR_3RD_PLATFORM == "app" then
            --gGetLoginManager():LoginAgain()
        --else
    	    SwitchAccountDialog.getInstanceAndShow()
        --end
	else
		local dlg = SelectServerEntry.getInstanceAndShow()
        if dlg then
            dlg:SetYingyongBaoVisible(false)
            dlg:SetEnterGameVisible(true)
        end
        if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
            if gGetLoginManager():isFirstEnter() then
                windowsexplain.getInstanceAndShow()
            end
        end
	end
end

main()

function setCur3rdPlatform(str)
    Config.CUR_3RD_PLATFORM  = str
end
