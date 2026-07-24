
package xbean;

public interface RoleSaleGoodsLimit extends mkdb.Bean {
	public RoleSaleGoodsLimit copy(); // 深拷贝
	public RoleSaleGoodsLimit toData(); // 一个 Data 实例
	public RoleSaleGoodsLimit toBean(); // 一个 Bean 实例
	public RoleSaleGoodsLimit toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RoleSaleGoodsLimit toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.NumberAndTime> getDaylimit(); // 日限售
	public java.util.Map<Integer, xbean.NumberAndTime> getDaylimitAsData(); // 日限售
	public java.util.Map<Integer, xbean.NumberAndTime> getWeeklimit(); // 周限售
	public java.util.Map<Integer, xbean.NumberAndTime> getWeeklimitAsData(); // 周限售
	public java.util.Map<Integer, xbean.NumberAndTime> getMonthlimit(); // 月限售
	public java.util.Map<Integer, xbean.NumberAndTime> getMonthlimitAsData(); // 月限售

}
