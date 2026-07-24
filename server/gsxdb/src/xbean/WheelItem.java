
package xbean;

public interface WheelItem extends mkdb.Bean {
	public WheelItem copy(); // 深拷贝
	public WheelItem toData(); // 一个 Data 实例
	public WheelItem toBean(); // 一个 Bean 实例
	public WheelItem toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public WheelItem toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getItemtype(); // 1为物品,2为经验,3为金钱
	public int getItemid(); // 金钱和经验的id为0
	public int getNum(); // 数量
	public int getTimes(); // 倍数,为实际倍数的10倍
	public int getBind(); // 是否绑定,只对物品有效
	public int getLimit(); // 最大上限,只对物品有效
	public int getMsgid(); // 发公告,只对物品有效

	public void setItemtype(int _v_); // 1为物品,2为经验,3为金钱
	public void setItemid(int _v_); // 金钱和经验的id为0
	public void setNum(int _v_); // 数量
	public void setTimes(int _v_); // 倍数,为实际倍数的10倍
	public void setBind(int _v_); // 是否绑定,只对物品有效
	public void setLimit(int _v_); // 最大上限,只对物品有效
	public void setMsgid(int _v_); // 发公告,只对物品有效
}
