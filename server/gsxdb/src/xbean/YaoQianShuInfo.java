
package xbean;

public interface YaoQianShuInfo extends mkdb.Bean {
	public YaoQianShuInfo copy(); // 深拷贝
	public YaoQianShuInfo toData(); // 一个 Data 实例
	public YaoQianShuInfo toBean(); // 一个 Bean 实例
	public YaoQianShuInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public YaoQianShuInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 植树人
	public java.util.List<Long> getLookroleids(); // 照顾过的玩家id
	public java.util.List<Long> getLookroleidsAsData(); // 照顾过的玩家id
	public int getMapid(); // 
	public int getPosx(); // 
	public int getPosy(); // 

	public void setRoleid(long _v_); // 植树人
	public void setMapid(int _v_); // 
	public void setPosx(int _v_); // 
	public void setPosy(int _v_); // 
}
