
package xbean;

public interface WinnerRoleRecord extends mkdb.Bean {
	public WinnerRoleRecord copy(); // 深拷贝
	public WinnerRoleRecord toData(); // 一个 Data 实例
	public WinnerRoleRecord toBean(); // 一个 Bean 实例
	public WinnerRoleRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WinnerRoleRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 
	public int getScore(); // 记录个人的成绩
	public long getTime(); // 记录成绩变化的时间
	public int getAwardflag(); // 是否领取过奖励的标记,0为没有领取   1为领取过了

	public void setRoleid(long _v_); // 
	public void setScore(int _v_); // 记录个人的成绩
	public void setTime(long _v_); // 记录成绩变化的时间
	public void setAwardflag(int _v_); // 是否领取过奖励的标记,0为没有领取   1为领取过了
}
