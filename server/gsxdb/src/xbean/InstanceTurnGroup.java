
package xbean;

public interface InstanceTurnGroup extends mkdb.Bean {
	public InstanceTurnGroup copy(); // 深拷贝
	public InstanceTurnGroup toData(); // 一个 Data 实例
	public InstanceTurnGroup toBean(); // 一个 Bean 实例
	public InstanceTurnGroup toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public InstanceTurnGroup toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getTurngroup(); // 轮换组id
	public int getTurnindex(); // 轮换组当前id
	public int getTurntype(); // 轮换类型

	public void setTurngroup(int _v_); // 轮换组id
	public void setTurnindex(int _v_); // 轮换组当前id
	public void setTurntype(int _v_); // 轮换类型
}
