
package xbean;

public interface RedPack extends mkdb.Bean {
	public RedPack copy(); // 深拷贝
	public RedPack toData(); // 一个 Data 实例
	public RedPack toBean(); // 一个 Bean 实例
	public RedPack toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public RedPack toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getWorldredpack(); // 

	public void setWorldredpack(long _v_); // 
}
