
package xbean;

public interface ArchMap extends mkdb.Bean {
	public ArchMap copy(); // 深拷贝
	public ArchMap toData(); // 一个 Data 实例
	public ArchMap toBean(); // 一个 Bean 实例
	public ArchMap toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public ArchMap toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public int getMapid(); // 藏宝图上记录的地图id
	public int getPosx(); // 藏宝图上记录的x坐标
	public int getPosy(); // 藏宝图上记录的y坐标

	public void setMapid(int _v_); // 藏宝图上记录的地图id
	public void setPosx(int _v_); // 藏宝图上记录的x坐标
	public void setPosy(int _v_); // 藏宝图上记录的y坐标
}
