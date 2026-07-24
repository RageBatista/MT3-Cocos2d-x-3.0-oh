
package xbean;

public interface PetEquipItem extends mkdb.Bean {
	public PetEquipItem copy(); // 深拷贝
	public PetEquipItem toData(); // 一个 Data 实例
	public PetEquipItem toBean(); // 一个 Bean 实例
	public PetEquipItem toDataIf(); // 如果需要则返回一个 Data 实例，否则返回 this
	public PetEquipItem toBeanIf(); // 如果需要则返回一个 Bean 实例，否则返回 this

	public long getId(); // 主键id
	public int getItemid(); // 工具编号
	public int getPos(); // 宠物装备位置
	public int getTaozhuangid(); // 套装ID
	public java.util.Map<Integer, Integer> getPro(); // 宠物装备属性
	public java.util.Map<Integer, Integer> getProAsData(); // 宠物装备属性
	public java.util.Map<Integer, Integer> getSkill(); // 宠物装备技能
	public java.util.Map<Integer, Integer> getSkillAsData(); // 宠物装备技能

	public void setId(long _v_); // 主键id
	public void setItemid(int _v_); // 工具编号
	public void setPos(int _v_); // 宠物装备位置
	public void setTaozhuangid(int _v_); // 套装ID
}
