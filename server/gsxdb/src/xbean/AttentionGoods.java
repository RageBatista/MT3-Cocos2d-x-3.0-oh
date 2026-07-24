
package xbean;

public interface AttentionGoods extends mkdb.Bean {
	public AttentionGoods copy(); // 深拷贝
	public AttentionGoods toData(); // 一个 Data 实例
	public AttentionGoods toBean(); // 一个 Bean 实例
	public AttentionGoods toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public AttentionGoods toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.List<xbean.AttentionGoodsBean> getBuyattentions(); // 购买关注,数据库表中的id,关注数量最多8个
	public java.util.List<xbean.AttentionGoodsBean> getBuyattentionsAsData(); // 购买关注,数据库表中的id,关注数量最多8个
	public java.util.List<xbean.AttentionGoodsBean> getPublicityattentions(); // 公示关注,数据库表中的id,关注数量最多8个
	public java.util.List<xbean.AttentionGoodsBean> getPublicityattentionsAsData(); // 公示关注,数据库表中的id,关注数量最多8个

}
