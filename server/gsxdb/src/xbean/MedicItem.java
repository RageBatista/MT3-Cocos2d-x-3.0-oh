
package xbean;

public interface MedicItem extends mkdb.Bean {
	public MedicItem copy(); // 深拷贝
	public MedicItem toData(); // 一个 Data 实例
	public MedicItem toBean(); // 一个 Bean 实例
	public MedicItem toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public MedicItem toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getItemid(); // 药品id
	public int getItemnum(); // 药品数量

	public void setItemid(int _v_); // 药品id
	public void setItemnum(int _v_); // 药品数量
}
