
package xbean;

public interface CurrApprent extends mkdb.Bean {
	public CurrApprent copy(); // 深拷贝
	public CurrApprent toData(); // 一个 Data 实例
	public CurrApprent toBean(); // 一个 Bean 实例
	public CurrApprent toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public CurrApprent toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getTitleid(); // 徒弟的当前称谓
	public int getLevel(); // 拜师时候的等级
	public xbean.HasApprent getApprentinfo(); // 徒弟的基本信息
	public java.util.Map<Integer, xbean.ApprentceChieve> getAchievement(); // 徒弟的各项成就
	public java.util.Map<Integer, xbean.ApprentceChieve> getAchievementAsData(); // 徒弟的各项成就
	public int getMastercomment(); // 师傅对徒弟的评价
	public int getApprentcomment(); // 徒弟对师傅的评价
	public long getBaishitime(); // 

	public void setTitleid(int _v_); // 徒弟的当前称谓
	public void setLevel(int _v_); // 拜师时候的等级
	public void setMastercomment(int _v_); // 师傅对徒弟的评价
	public void setApprentcomment(int _v_); // 徒弟对师傅的评价
	public void setBaishitime(long _v_); // 
}
