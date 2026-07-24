
package xbean;

public interface ChangeSchoolInfo extends mkdb.Bean {
	public ChangeSchoolInfo copy(); // 深拷贝
	public ChangeSchoolInfo toData(); // 一个 Data 实例
	public ChangeSchoolInfo toBean(); // 一个 Bean 实例
	public ChangeSchoolInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ChangeSchoolInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.ChangeSchoolRecord> getRecords(); // 转职记录列表
	public java.util.List<xbean.ChangeSchoolRecord> getRecordsAsData(); // 转职记录列表
	public int getChangeweaponcount(); // 当前转职后,转换武器的次数
	public int getChangegemcount(); // 当前转职后,转换宝石的次数

	public void setChangeweaponcount(int _v_); // 当前转职后,转换武器的次数
	public void setChangegemcount(int _v_); // 当前转职后,转换宝石的次数
}
