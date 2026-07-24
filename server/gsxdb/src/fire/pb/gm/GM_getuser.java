//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import mkdb.Procedure;
import xbean.AUUserInfo;
import xbean.Properties;
import xtable.Auuserinfo;

public class GM_getuser extends GMCommand {
    public boolean exec(final String[] args) {
        if (args.length < 1) {
            this.sendToGM("参数格式错误：" + this.usage());
            return false;
        } else {
            (new Procedure() {
                protected boolean process() throws Exception {
                    Properties select = xtable.Properties.select(Long.parseLong(args[0]));
                    if (select != null) {
                        int userid = select.getUserid();
                        AUUserInfo auUserInfo = Auuserinfo.select(userid);
                        GM_getuser.this.sendToGM("当前userid" + userid);
                        String account = auUserInfo.getUsername().substring(6);
                        GM_getuser.this.sendToGM("查询的角色id:" + args[0] + "角色账号:" + account);
                        return true;
                    } else {
                        GM_getuser.this.sendToGM("当前角色不存在");
                        return true;
                    }
                }
            }).submit();
            return true;
        }
    }

    public String usage() {
        return "//getuser roleid";
    }
}
