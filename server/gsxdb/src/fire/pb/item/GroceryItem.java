package fire.pb.item;


public class GroceryItem extends ItemBase {
	
	public GroceryItem( ItemMgr im, int itemid ) {
		super( im, itemid );
	}
	
	public GroceryItem( ItemMgr im, xbean.Item item ) {
		super( im, item );
	}



	@Override
	public void onDeleted() {
		// TODO 自动生成的方法存根

	}

	@Override
	public void onInserted() {
		// TODO 自动生成的方法存根

	}
	
	public int getLevel()
	{
		if (itemAttr != null)
			return itemAttr.getLevel();
		
		return 1;
	}

}
