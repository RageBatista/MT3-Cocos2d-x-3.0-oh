
package xbean;

public interface HuoBanShuxingLevel extends mkdb.Bean {
	public HuoBanShuxingLevel copy(); // 深拷贝
	public HuoBanShuxingLevel toData(); // 一个 Data 实例
	public HuoBanShuxingLevel toBean(); // 一个 Bean 实例
	public HuoBanShuxingLevel toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public HuoBanShuxingLevel toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public java.util.Map<Integer, xbean.HuoBanshuxing> getHuobans(); // key 为等级id,value为等级对应的伙伴信息
	public java.util.Map<Integer, xbean.HuoBanshuxing> getHuobansAsData(); // key 为等级id,value为等级对应的伙伴信息

}
