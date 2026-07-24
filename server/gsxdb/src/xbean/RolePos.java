
package xbean;

public interface RolePos extends mkdb.Bean {
	public RolePos copy(); // 深拷贝
	public RolePos toData(); // 一个 Data 实例
	public RolePos toBean(); // 一个 Bean 实例
	public RolePos toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RolePos toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public final static int OUTDREAM = 1; // 不在幻境中
	public final static int INDREAM = 2; // 在幻境中
	public final static int ABSENTDREAM = 3; // 暂离幻境

	public int getMapid(); // 
	public int getPosx(); // 
	public int getPosy(); // 
	public long getOwnerid(); // 这个幻境是属于哪个玩家的
	public int getDynamicmap(); // 
	public int getDynamicposx(); // 
	public int getDynamicposy(); // 
	public int getStatus(); // 
	public int getHastask(); // 玩家是否有幻境任务 0没有,1有

	public void setMapid(int _v_); // 
	public void setPosx(int _v_); // 
	public void setPosy(int _v_); // 
	public void setOwnerid(long _v_); // 这个幻境是属于哪个玩家的
	public void setDynamicmap(int _v_); // 
	public void setDynamicposx(int _v_); // 
	public void setDynamicposy(int _v_); // 
	public void setStatus(int _v_); // 
	public void setHastask(int _v_); // 玩家是否有幻境任务 0没有,1有
}
