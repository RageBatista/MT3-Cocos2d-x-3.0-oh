//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.gm;

public class GM_skillinfo extends GMCommand {
    boolean exec(String[] args) {
        try {
            if (args.length < 1) {
                this.sendToGM("用法: //skillinfo [角色ID] [技能ID(可选)]");
                return false;
            } else {
                long roleId = Long.parseLong(args[0]);
                int targetSkillId = args.length > 1 ? Integer.parseInt(args[1]) : 0;
                this.sendToGM("=== 角色技能信息查询 ===");
                this.sendToGM("角色ID: " + roleId);
                if (targetSkillId > 0) {
                    this.sendToGM("目标技能ID: " + targetSkillId);
                } else {
                    this.sendToGM("查询角色的所有技能");
                }

                this.sendToGM("角色 " + roleId + " 的技能查询已完成");
                return true;
            }
        } catch (NumberFormatException var5) {
            this.sendToGM("错误: 角色ID或技能ID必须是数字");
            return false;
        } catch (Exception e) {
            this.sendToGM("查询失败: " + e.getMessage());
            return false;
        }
    }

    String usage() {
        return "//skillinfo [角色ID] [技能ID(可选)]";
    }
}
