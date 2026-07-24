
package xbean;

public interface DynamicMapInfo2 extends mkdb.Bean {
	public DynamicMapInfo2 copy(); // 深拷贝
	public DynamicMapInfo2 toData(); // 一个 Data 实例
	public DynamicMapInfo2 toBean(); // 一个 Bean 实例
	public DynamicMapInfo2 toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public DynamicMapInfo2 toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getBasemapid(); // 

	public void setBasemapid(int _v_); // 
}
