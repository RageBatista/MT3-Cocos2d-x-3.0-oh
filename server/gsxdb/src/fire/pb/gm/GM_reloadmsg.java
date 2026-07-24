//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.log.Module;

public class GM_reloadmsg extends GMCommand {
    public GM_reloadmsg() {
    }

    public boolean exec(String[] args) {
        try {
            Module module = new Module();
            module.init();
        } catch (Exception var3) {
            Exception e = var3;
            this.sendToGM("reload error");
            e.printStackTrace();
        }

        this.sendToGM("重新加载禁言字符成功。");
        return true;
    }

    public String usage() {
        return null;
    }
}
