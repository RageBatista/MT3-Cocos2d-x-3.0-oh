
package xbean;

public interface TransfromByItemData extends mkdb.Bean {
	public TransfromByItemData copy(); // 深拷贝
	public TransfromByItemData toData(); // 一个 Data 实例
	public TransfromByItemData toBean(); // 一个 Bean 实例
	public TransfromByItemData toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public TransfromByItemData toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getUseitemid(); // 
	public int getTransformid(); // 
	public long getValiddate(); // 

	public void setUseitemid(int _v_); // 
	public void setTransformid(int _v_); // 
	public void setValiddate(long _v_); // 
}
