package fire.pb.item;


public class SWenShiItemShuXing implements mytools.ConvMain.Checkable ,Comparable<SWenShiItemShuXing>{

	public int compareTo(SWenShiItemShuXing o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SWenShiItemShuXing(){
		super();
	}
	public SWenShiItemShuXing(SWenShiItemShuXing arg){
		this.id=arg.id ;
		this.icon=arg.icon ;
		this.level=arg.level ;
		this.naijiu=arg.naijiu ;
		this.wenshitype=arg.wenshitype ;
		this.shuxingid1=arg.shuxingid1 ;
		this.shuxingid2=arg.shuxingid2 ;
		this.shuxingid3=arg.shuxingid3 ;
		this.shuxingzhi1=arg.shuxingzhi1 ;
		this.shuxingzhi2=arg.shuxingzhi2 ;
		this.shuxingzhi3=arg.shuxingzhi3 ;
		this.hecheng=arg.hecheng ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
	}
	/**
	 * id
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
	public int icon  = 0  ;
	
	public int getIcon(){
		return this.icon;
	}
	
	public void setIcon(int v){
		this.icon=v;
	}
	
	/**
	 * 
	 */
	public int level  = 0  ;
	
	public int getLevel(){
		return this.level;
	}
	
	public void setLevel(int v){
		this.level=v;
	}
	
	/**
	 * 
	 */
	public int naijiu  = 0  ;
	
	public int getNaijiu(){
		return this.naijiu;
	}
	
	public void setNaijiu(int v){
		this.naijiu=v;
	}
	
	/**
	 * 
	 */
	public int wenshitype  = 0  ;
	
	public int getWenshitype(){
		return this.wenshitype;
	}
	
	public void setWenshitype(int v){
		this.wenshitype=v;
	}
	
	/**
	 * 
	 */
	public int shuxingid1  = 0  ;
	
	public int getShuxingid1(){
		return this.shuxingid1;
	}
	
	public void setShuxingid1(int v){
		this.shuxingid1=v;
	}
	
	/**
	 * 
	 */
	public int shuxingid2  = 0  ;
	
	public int getShuxingid2(){
		return this.shuxingid2;
	}
	
	public void setShuxingid2(int v){
		this.shuxingid2=v;
	}
	
	/**
	 * 
	 */
	public int shuxingid3  = 0  ;
	
	public int getShuxingid3(){
		return this.shuxingid3;
	}
	
	public void setShuxingid3(int v){
		this.shuxingid3=v;
	}
	
	/**
	 * 
	 */
	public int shuxingzhi1  = 0  ;
	
	public int getShuxingzhi1(){
		return this.shuxingzhi1;
	}
	
	public void setShuxingzhi1(int v){
		this.shuxingzhi1=v;
	}
	
	/**
	 * 
	 */
	public int shuxingzhi2  = 0  ;
	
	public int getShuxingzhi2(){
		return this.shuxingzhi2;
	}
	
	public void setShuxingzhi2(int v){
		this.shuxingzhi2=v;
	}
	
	/**
	 * 
	 */
	public int shuxingzhi3  = 0  ;
	
	public int getShuxingzhi3(){
		return this.shuxingzhi3;
	}
	
	public void setShuxingzhi3(int v){
		this.shuxingzhi3=v;
	}
	
	/**
	 * 
	 */
	public int hecheng  = 0  ;
	
	public int getHecheng(){
		return this.hecheng;
	}
	
	public void setHecheng(int v){
		this.hecheng=v;
	}
	
	
};