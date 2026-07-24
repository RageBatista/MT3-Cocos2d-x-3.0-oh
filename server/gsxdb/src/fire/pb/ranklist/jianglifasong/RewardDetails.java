//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.ranklist.jianglifasong;

import java.util.List;
import xbean.SingleCompensationAward;

public class RewardDetails {
    private int roleId;
    private String dayImage;
    private int rank;
    private int platformCurrency;
    private List<SingleCompensationAward> awards;

    public int getRoleId() {
        return this.roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getDayImage() {
        return this.dayImage;
    }

    public void setDayImage(String dayImage) {
        this.dayImage = dayImage;
    }

    public int getRank() {
        return this.rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public int getPlatformCurrency() {
        return this.platformCurrency;
    }

    public void setPlatformCurrency(int platformCurrency) {
        this.platformCurrency = platformCurrency;
    }

    public List<SingleCompensationAward> getAwards() {
        return this.awards;
    }

    public void setAwards(List<SingleCompensationAward> awards) {
        this.awards = awards;
    }
}
