
package xbean;

public interface TeamMatch extends mkdb.Bean {
	public TeamMatch copy(); // 深拷贝
	public TeamMatch toData(); // 一个 Data 实例
	public TeamMatch toBean(); // 一个 Bean 实例
	public TeamMatch toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TeamMatch toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getRoleid(); // 角色ID，作者 changhao
	public int getMatchtype(); // 类型0是个人1是队伍，作者 changhao
	public int getTargetid(); // 目标ID，作者 changhao
	public int getLevelmin(); // 需要最小等级 个人匹配这个忽略，作者 changhao
	public int getLevelmax(); // 需要最大等级 个人匹配这个忽略，作者 changhao
	public long getOnekeytimestamp(); // 一键喊话时间戳，作者 changhao
	public long getTimestamp(); // 匹配后的时间戳，作者 changhao

	public void setRoleid(long _v_); // 角色ID，作者 changhao
	public void setMatchtype(int _v_); // 类型0是个人1是队伍，作者 changhao
	public void setTargetid(int _v_); // 目标ID，作者 changhao
	public void setLevelmin(int _v_); // 需要最小等级 个人匹配这个忽略，作者 changhao
	public void setLevelmax(int _v_); // 需要最大等级 个人匹配这个忽略，作者 changhao
	public void setOnekeytimestamp(long _v_); // 一键喊话时间戳，作者 changhao
	public void setTimestamp(long _v_); // 匹配后的时间戳，作者 changhao
}
