/*
 * @作者：kevinsuperme kevinsuperme@users.noreply.github.com
 * @日期：2026-01-13 15:44:25
 * @LastEditors：kevinsuperme kevinsuperme@users.noreply.github.com
 * @LastEditTime: 2026-01-13 16:48:57
 * @FilePath: \gsxdb-Sq2build\src\fire\pb\gm\GM_changeschool.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

import fire.pb.school.change.PChangeSchool;

public class GM_changeschool extends GMCommand {
    boolean exec(String[] args) {
        if (args.length < 2) {
            this.sendToGM("参数格式错误：" + this.usage());
            return false;
        } else {
            int shapeId = Integer.parseInt(args[0]);
            int schoolId = Integer.parseInt(args[1]);
            PChangeSchool changeSchool = new PChangeSchool(this.getGmroleid(), shapeId, schoolId);
            changeSchool.submit();
            this.sendToGM("转职失败");
            return true;
        }
    }

    String usage() {
        return "//changeschool 造型id 职业id";
    }
}
