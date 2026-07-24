
package xbean;

public interface MedicItemList extends mkdb.Bean {
	public MedicItemList copy(); // 深拷贝
	public MedicItemList toData(); // 一个 Data 实例
	public MedicItemList toBean(); // 一个 Bean 实例
	public MedicItemList toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MedicItemList toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getMedicitemrefreshtime(); // 刷新时间
	public int getSelecttype(); // 选择几倍产药类型   0正常  1双倍    2三倍
	public java.util.Map<Integer, xbean.MedicItem> getMedicitems(); // 道具
	public java.util.Map<Integer, xbean.MedicItem> getMedicitemsAsData(); // 道具

	public void setMedicitemrefreshtime(long _v_); // 刷新时间
	public void setSelecttype(int _v_); // 选择几倍产药类型   0正常  1双倍    2三倍
}
