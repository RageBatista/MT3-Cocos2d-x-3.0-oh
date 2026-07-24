
package xbean;

public interface Jingmai extends mkdb.Bean {
	public Jingmai copy(); // 深拷贝
	public Jingmai toData(); // 一个 Data 实例
	public Jingmai toBean(); // 一个 Bean 实例
	public Jingmai toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public Jingmai toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getId(); // 装备等级
	public int getQianyuandan(); // 装备等级
	public int getQiankundan(); // 装备等级
	public int getFangan(); // 装备等级
	public int getState(); // 装备等级
	public java.util.Map<Integer, Integer> getJingmais(); // 潜能。未分配点数
	public java.util.Map<Integer, Integer> getJingmaisAsData(); // 潜能。未分配点数
	public java.util.Map<Integer, xbean.XingChenItem> getXingchen(); // 拥有的称谓列表
	public java.util.Map<Integer, xbean.XingChenItem> getXingchenAsData(); // 拥有的称谓列表

	public void setId(int _v_); // 装备等级
	public void setQianyuandan(int _v_); // 装备等级
	public void setQiankundan(int _v_); // 装备等级
	public void setFangan(int _v_); // 装备等级
	public void setState(int _v_); // 装备等级
}
