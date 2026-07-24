
package xbean;

public interface ChangeSchoolRecord extends mkdb.Bean {
	public ChangeSchoolRecord copy(); // 深拷贝
	public ChangeSchoolRecord toData(); // 一个 Data 实例
	public ChangeSchoolRecord toBean(); // 一个 Bean 实例
	public ChangeSchoolRecord toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ChangeSchoolRecord toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getShape(); // 造型
	public int getSchool(); // 职业
	public long getTime(); // 转职时间

	public void setShape(int _v_); // 造型
	public void setSchool(int _v_); // 职业
	public void setTime(long _v_); // 转职时间
}
