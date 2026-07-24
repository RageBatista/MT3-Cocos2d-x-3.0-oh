
package xbean;

public interface HuoBanZhenrong extends mkdb.Bean {
	public HuoBanZhenrong copy(); // 深拷贝
	public HuoBanZhenrong toData(); // 一个 Data 实例
	public HuoBanZhenrong toBean(); // 一个 Bean 实例
	public HuoBanZhenrong toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public HuoBanZhenrong toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getCurrent(); // 当前阵容编号
	public java.util.Map<Integer, xbean.HuoBanZhenrongInfo> getZhenrong(); // key-阵容编号(1,2,3)
	public java.util.Map<Integer, xbean.HuoBanZhenrongInfo> getZhenrongAsData(); // key-阵容编号(1,2,3)

	public void setCurrent(int _v_); // 当前阵容编号
}
