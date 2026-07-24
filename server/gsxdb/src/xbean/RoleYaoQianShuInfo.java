
package xbean;

public interface RoleYaoQianShuInfo extends mkdb.Bean {
	public RoleYaoQianShuInfo copy(); // 深拷贝
	public RoleYaoQianShuInfo toData(); // 一个 Data 实例
	public RoleYaoQianShuInfo toBean(); // 一个 Bean 实例
	public RoleYaoQianShuInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleYaoQianShuInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<Long> getLookroleids(); // 照顾过的玩家id
	public java.util.List<Long> getLookroleidsAsData(); // 照顾过的玩家id
	public int getMapid(); // 
	public int getPosx(); // 
	public int getPosy(); // 

	public void setMapid(int _v_); // 
	public void setPosx(int _v_); // 
	public void setPosy(int _v_); // 
}
