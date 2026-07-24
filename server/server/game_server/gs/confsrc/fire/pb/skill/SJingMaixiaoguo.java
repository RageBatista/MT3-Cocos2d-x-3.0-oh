package fire.pb.skill;


public class SJingMaixiaoguo implements mytools.ConvMain.Checkable ,Comparable<SJingMaixiaoguo>{

	public int compareTo(SJingMaixiaoguo o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SJingMaixiaoguo(){
		super();
	}
	public SJingMaixiaoguo(SJingMaixiaoguo arg){
		this.id=arg.id ;
		this.zhiye=arg.zhiye ;
		this.jingmaiid=arg.jingmaiid ;
		this.jingmais=arg.jingmais ;
		this.xingchens=arg.xingchens ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
			do{
				int tmprefvalue=id;
				
				if(tmprefvalue < 1) throw new RuntimeException("SJingMaixiaoguo.id="+tmprefvalue+",所以不满足条件 SJingMaixiaoguo.id < 1");
			}while(false);
	}
	/**
	 * 
	 */
	public int id  = 0  ;
	
	public int getId(){
		return this.id;
	}
	
	public void setId(int v){
		this.id=v;
	}
	
	/**
	 * 
	 */
	public int zhiye  = 0  ;
	
	public int getZhiye(){
		return this.zhiye;
	}
	
	public void setZhiye(int v){
		this.zhiye=v;
	}
	
	/**
	 * 
	 */
	public int jingmaiid  = 0  ;
	
	public int getJingmaiid(){
		return this.jingmaiid;
	}
	
	public void setJingmaiid(int v){
		this.jingmaiid=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> jingmais  ;
	
	public java.util.ArrayList<Integer> getJingmais(){
		return this.jingmais;
	}
	
	public void setJingmais(java.util.ArrayList<Integer> v){
		this.jingmais=v;
	}
	
	/**
	 * 
	 */
	public java.util.ArrayList<Integer> xingchens  ;
	
	public java.util.ArrayList<Integer> getXingchens(){
		return this.xingchens;
	}
	
	public void setXingchens(java.util.ArrayList<Integer> v){
		this.xingchens=v;
	}
	
	
};