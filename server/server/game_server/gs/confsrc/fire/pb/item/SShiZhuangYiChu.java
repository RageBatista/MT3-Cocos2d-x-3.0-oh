package fire.pb.item;


public class SShiZhuangYiChu implements mytools.ConvMain.Checkable ,Comparable<SShiZhuangYiChu>{

	public int compareTo(SShiZhuangYiChu o){
		return this.id-o.id;
	}

	
	
	static class NeedId extends RuntimeException{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		
	}
	public SShiZhuangYiChu(){
		super();
	}
	public SShiZhuangYiChu(SShiZhuangYiChu arg){
		this.id=arg.id ;
		this.moxing=arg.moxing ;
		this.cailiao=arg.cailiao ;
		this.cailiaonum=arg.cailiaonum ;
		this.buff=arg.buff ;
	}
	public void checkValid(java.util.Map<String,java.util.Map<Integer,? extends Object> > objs){
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
	public int moxing  = 0  ;
	
	public int getMoxing(){
		return this.moxing;
	}
	
	public void setMoxing(int v){
		this.moxing=v;
	}
	
	/**
	 * 
	 */
	public int cailiao  = 0  ;
	
	public int getCailiao(){
		return this.cailiao;
	}
	
	public void setCailiao(int v){
		this.cailiao=v;
	}
	
	/**
	 * 
	 */
	public int cailiaonum  = 0  ;
	
	public int getCailiaonum(){
		return this.cailiaonum;
	}
	
	public void setCailiaonum(int v){
		this.cailiaonum=v;
	}
	
	/**
	 * 
	 */
	public int buff  = 0  ;
	
	public int getBuff(){
		return this.buff;
	}
	
	public void setBuff(int v){
		this.buff=v;
	}
	
	
};