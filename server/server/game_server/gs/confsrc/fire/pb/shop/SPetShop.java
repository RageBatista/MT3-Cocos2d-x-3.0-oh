package fire.pb.shop;


public class SPetShop implements mytools.ConvMain.Checkable ,Comparable<SPetShop>{

	public int compareTo(SPetShop o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SPetShop(){
		super();
	}
	public SPetShop(SPetShop arg){
		this.id=arg.id ;
		this.limitLookLv=arg.limitLookLv ;
		this.goodsids=arg.goodsids ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SPetShop.id="+tmprefvalue+",所以不满足条件 SPetShop.id < 1");
			}while(false);
	}
	/**
	 * 页签显示
	 */
	public int id  = 0  ;
	
	public int getId(){
		return this.id;
	}
	
	public void setId(int v){
		this.id=v;
	}
	
	/**
	 * 可见页签等级
	 */
	public int limitLookLv  = 0  ;
	
	public int getLimitLookLv(){
		return this.limitLookLv;
	}
	
	public void setLimitLookLv(int v){
		this.limitLookLv=v;
	}
	
	/**
	 * 商品ID1,商品ID2,商品ID3,商品ID4,商品ID5,商品ID6
	 */
	public java.util.ArrayList<Integer> goodsids  ;
	
	public java.util.ArrayList<Integer> getGoodsids(){
		return this.goodsids;
	}
	
	public void setGoodsids(java.util.ArrayList<Integer> v){
		this.goodsids=v;
	}
	
	
};