//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.zuoqi;

import mkdb.Procedure;
import xbean.Properties;
import xbean.User;

public class yongyou extends Procedure {
    private long roleId;

    public yongyou(long roleId) {
        this.roleId = roleId;
    }

    protected boolean process() {
        Properties prop = xtable.Properties.get(this.roleId);
        SZuoQiYongYou sshizhuang = new SZuoQiYongYou();
        sshizhuang.zuoqi.putAll(prop.getZuoqi());
        System.err.println(prop.getUserid());
        User user = xtable.User.get(prop.getUserid());
        Procedure.psendWhileCommit(this.roleId, sshizhuang);
        return true;
    }
}
