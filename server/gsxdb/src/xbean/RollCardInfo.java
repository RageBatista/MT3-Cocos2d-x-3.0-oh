
package xbean;

public interface RollCardInfo extends mkdb.Bean {
	public RollCardInfo copy(); // 深拷贝
	public RollCardInfo toData(); // 一个 Data 实例
	public RollCardInfo toBean(); // 一个 Bean 实例
	public RollCardInfo toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RollCardInfo toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getServiceid(); // 
	public int getTakeflag(); // 0没有领取 1=提取过
	public int getBasemoney(); // 
	public int getBasesmoney(); // 
	public int getBaseexp(); // 
	public int getIndex(); // 真正的卡
	public java.util.List<xbean.WheelItem> getWheelitems(); // 4张卡
	public java.util.List<xbean.WheelItem> getWheelitemsAsData(); // 4张卡

	public void setServiceid(int _v_); // 
	public void setTakeflag(int _v_); // 0没有领取 1=提取过
	public void setBasemoney(int _v_); // 
	public void setBasesmoney(int _v_); // 
	public void setBaseexp(int _v_); // 
	public void setIndex(int _v_); // 真正的卡
}
