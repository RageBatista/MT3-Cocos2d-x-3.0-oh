//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.npc;

public class NpcNameTable {
    public final int id;
    public final String firstName;
    public final String secondName;

    public NpcNameTable(SNpcNameRandom npcNameRnd) {
        this.id = npcNameRnd.id;
        this.firstName = npcNameRnd.firstName;
        this.secondName = npcNameRnd.secondName;
    }
}
