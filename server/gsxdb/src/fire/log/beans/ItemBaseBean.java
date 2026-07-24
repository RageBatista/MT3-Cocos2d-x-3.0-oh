package fire.log.beans;

public class ItemBaseBean {
	private int ItemId;//工具编号
	private int amt;//道具数量
	
	public ItemBaseBean(int ItemId,int amt){
		this.ItemId=ItemId;//工具编号
		this.amt=amt;//道具数量
	}
	
	
	public int getItemId() {
		return ItemId;
	}
	public void setItemId(int itemId) {
		ItemId = itemId;
	}
	public int getAmt() {
		return amt;
	}
	public void setAmt(int amt) {
		this.amt = amt;
	}
		 

}
