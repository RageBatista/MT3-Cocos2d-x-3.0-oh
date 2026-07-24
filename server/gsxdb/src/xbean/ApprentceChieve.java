
package xbean;

public interface ApprentceChieve extends mkdb.Bean {
	public ApprentceChieve copy(); // 深拷贝
	public ApprentceChieve toData(); // 一个 Data 实例
	public ApprentceChieve toBean(); // 一个 Bean 实例
	public ApprentceChieve toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ApprentceChieve toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getCurrnumber(); // 当前次数
	public int getTotal(); // 当前总量
	public int getFlag(); // 0=未完成 1=完成 2=已经领奖
	public int getContent(); // 记录一个数值

	public void setCurrnumber(int _v_); // 当前次数
	public void setTotal(int _v_); // 当前总量
	public void setFlag(int _v_); // 0=未完成 1=完成 2=已经领奖
	public void setContent(int _v_); // 记录一个数值
}
