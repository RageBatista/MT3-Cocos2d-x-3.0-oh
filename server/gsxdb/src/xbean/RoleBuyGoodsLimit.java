
package xbean;

public interface RoleBuyGoodsLimit extends mkdb.Bean {
	public RoleBuyGoodsLimit copy(); // 深拷贝
	public RoleBuyGoodsLimit toData(); // 一个 Data 实例
	public RoleBuyGoodsLimit toBean(); // 一个 Bean 实例
	public RoleBuyGoodsLimit toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleBuyGoodsLimit toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.NumberAndTime> getDaylimit(); // key=goodsid日限购
	public java.util.Map<Integer, xbean.NumberAndTime> getDaylimitAsData(); // key=goodsid日限购
	public java.util.Map<Integer, xbean.NumberAndTime> getWeeklimit(); // 周限购
	public java.util.Map<Integer, xbean.NumberAndTime> getWeeklimitAsData(); // 周限购
	public java.util.Map<Integer, xbean.NumberAndTime> getMonthlimit(); // 月限购
	public java.util.Map<Integer, xbean.NumberAndTime> getMonthlimitAsData(); // 月限购

}
