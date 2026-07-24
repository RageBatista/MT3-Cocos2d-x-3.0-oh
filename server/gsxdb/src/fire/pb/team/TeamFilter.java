//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team;

public abstract class TeamFilter {
    public abstract boolean checkActive(long var1);

    protected abstract boolean checkEnterTeam(long var1, long var3);

    protected boolean checkInviteJoin(long inviterId, long roleId) {
        return this.checkEnterTeam(inviterId, roleId);
    }

    protected boolean checkRequestJoin(long leaderId, long roleId) {
        return this.checkEnterTeam(leaderId, roleId);
    }
}
