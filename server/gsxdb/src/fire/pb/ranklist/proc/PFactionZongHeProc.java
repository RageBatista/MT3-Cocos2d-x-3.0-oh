package fire.pb.ranklist.proc;

import fire.pb.ranklist.RankType;
import mkdb.Procedure;

/**
 * 工会综合实力排行，作者 changhao
 */
public class PFactionZongHeProc extends Procedure {
	private long clankey;
	private boolean reset; //是否重置为0，作者 changhao
	public PFactionZongHeProc(long clankey, boolean reset){
		this.clankey = clankey;
		this.reset = reset;
	}
	
	public boolean process(){
		
		xbean.ClanInfo clanInfo = xtable.Clans.select(clankey);
		if (clanInfo == null)
		{
			return true;
		}
		
		xbean.ClanZongHeRankRecord record = xbean.Pod.newClanZongHeRankRecord();
		record.setClankey(clankey);
		record.setClanname(clanInfo.getClanname());
		record.setLevel(clanInfo.getClanlevel()); //公会等级，作者 changhao
		record.setZonghe(clanInfo.getTotalscore()); //公会总评分，作者 changhao
		if (reset == true)
		{
			record.setZonghe(0);
		}
		
		xbean.ClanZongHeRankList list = xtable.Clanzonghelist.get(1);
		if (null == list)
		{
			list = xbean.Pod.newClanZongHeRankList();
			xtable.Clanzonghelist.insert(1, list);
		}
		
		RankListManager.getInstance().tryInsertRecord(
				RankType.FACTION_ZONGHE, list.getRecords(), record);
		
		return true;
	}

}
