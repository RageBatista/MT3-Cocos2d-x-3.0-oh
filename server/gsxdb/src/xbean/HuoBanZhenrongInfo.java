
package xbean;

public interface HuoBanZhenrongInfo extends mkdb.Bean {
	public HuoBanZhenrongInfo copy(); // 深拷贝
	public HuoBanZhenrongInfo toData(); // 一个 Data 实例
	public HuoBanZhenrongInfo toBean(); // 一个 Bean 实例
	public HuoBanZhenrongInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public HuoBanZhenrongInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getZhenfa(); // 阵容光环编号
	public java.util.List<Integer> getHuoban(); // value-伙伴id
	public java.util.List<Integer> getHuobanAsData(); // value-伙伴id

	public void setZhenfa(int _v_); // 阵容光环编号
}
