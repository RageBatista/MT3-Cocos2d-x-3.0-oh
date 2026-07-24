
package xbean;

public interface NpcSaleBusiness extends mkdb.Bean {
	public NpcSaleBusiness copy(); // 深拷贝
	public NpcSaleBusiness toData(); // 一个 Data 实例
	public NpcSaleBusiness toBean(); // 一个 Bean 实例
	public NpcSaleBusiness toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public NpcSaleBusiness toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.GoodsBusiness> getGoodsmap(); // 密钥=商品ID
	public java.util.Map<Integer, xbean.GoodsBusiness> getGoodsmapAsData(); // 密钥=商品ID
	public short getIsactive(); // 是否统计,默认为0不启动,1是启动
	public long getTime(); // 最后统计时间

	public void setIsactive(short _v_); // 是否统计,默认为0不启动,1是启动
	public void setTime(long _v_); // 最后统计时间
}
