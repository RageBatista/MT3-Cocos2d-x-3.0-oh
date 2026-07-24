
package xbean;

public interface SRRedPackNum extends mkdb.Bean {
	public SRRedPackNum copy(); // 深拷贝
	public SRRedPackNum toData(); // 一个 Data 实例
	public SRRedPackNum toBean(); // 一个 Bean 实例
	public SRRedPackNum toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public SRRedPackNum toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getModeltype(); // 红包类型(不要用)
	public int getRedpacksendnum(); // 发红包数量
	public int getRedpackreceivenum(); // 收红包数量
	public int getRedpacksendfushinum(); // 发红包符石总数

	public void setModeltype(int _v_); // 红包类型(不要用)
	public void setRedpacksendnum(int _v_); // 发红包数量
	public void setRedpackreceivenum(int _v_); // 收红包数量
	public void setRedpacksendfushinum(int _v_); // 发红包符石总数
}
