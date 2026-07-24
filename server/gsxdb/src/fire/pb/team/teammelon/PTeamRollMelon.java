//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.team.teammelon;

import com.locojoy.base.Octets;
import fire.pb.activity.award.RolledAwardItem;
import fire.pb.item.ItemBase;
import fire.pb.item.ItemShuXing;
import fire.pb.item.Module;
import fire.pb.team.TeamManager;
import fire.pb.util.Misc;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import mkdb.Executor;
import mkdb.Procedure;
import xbean.ETeamMelon;
import xbean.Item;
import xbean.Pod;
import xbean.TeamMelon;
import xtable.Battlemelonid2melon;
import xtable.Locks;
import xtable.Roleid2battlemelonid;

public class PTeamRollMelon extends Procedure {
    private final List<RolledAwardItem> itemids;
    private final List<Long> fighterroleids;
    private final List<Long> watcherids;
    private static AtomicLong melonid = new AtomicLong(1L);
    private final int melontype;
    private final int dataid;
    private final long dataid2;
    private final long battleid;

    public PTeamRollMelon(List<RolledAwardItem> items, List<Long> roleids, long battleid, List<Long> watcherids) {
        this.itemids = items;
        this.fighterroleids = roleids;
        this.melontype = 0;
        this.dataid = 0;
        this.battleid = battleid;
        this.dataid2 = 0L;
        this.watcherids = watcherids;
    }

    public PTeamRollMelon(List<RolledAwardItem> items, List<Long> roleids, long dataid2, int melonType, int questid, long battleid, List<Long> watcherids) {
        this.itemids = items;
        this.fighterroleids = roleids;
        this.melontype = melonType;
        this.dataid = questid;
        this.battleid = battleid;
        this.dataid2 = dataid2;
        this.watcherids = watcherids;
    }

    protected boolean process() throws Exception {
        ETeamMelon eteammelon = Battlemelonid2melon.get(this.battleid);
        if (eteammelon != null) {
            return true;
        } else {
            eteammelon = Pod.newETeamMelon();
            Battlemelonid2melon.insert(this.battleid, eteammelon);
            eteammelon.setMelontype(this.melontype);
            eteammelon.setDataid(this.dataid);
            if (this.dataid2 != 0L) {
                eteammelon.setDataid2(this.dataid2);
            }

            ArrayList<Long> roleids = new ArrayList();
            Set<Long> sets = new HashSet();
            sets.addAll(this.fighterroleids);

            for(Long roleid : sets) {
                eteammelon.getMelonerlist().add(roleid);
                roleids.add(roleid);
            }

            this.lock(Locks.ROLELOCK, roleids);
            STeamRollMelon msg = new STeamRollMelon();

            for(RolledAwardItem award : this.itemids) {
                ItemShuXing attr = Module.getInstance().getItemManager().getAttr(award.itemid);
                if (attr == null) {
                    TeamManager.logger.debug("FAIL:PTeamRollMelon:道具ID不存在 " + award.itemid);
                } else {
                    TeamMelon teammelon = Pod.newTeamMelon();
                    teammelon.setItemid(award.itemid);
                    teammelon.setItemnum(award.itemnum);
                    teammelon.setMaxrollpoint(0);
                    teammelon.setOpnum(0);
                    teammelon.setAwardid(award.awardid);
                    int max = 0;

                    for(Long roleid : roleids) {
                        int r;
                        for(r = Misc.getRandomBetween(1, 100); r == max; r = Misc.getRandomBetween(1, 100)) {
                        }

                        if (r > max) {
                            max = r;
                        }

                        teammelon.getMelonroleids().put(roleid, r);
                    }

                    ItemBase item = Module.getInstance().getItemManager().genItemBase(teammelon.getItemid(), teammelon.getItemnum());
                    if (item == null) {
                        return false;
                    }

                    this.CopyItemData(teammelon.getItemdata(), item.getDataItem());
                    eteammelon.getMelonid2melons().put(melonid.get(), teammelon);
                    RollMelon rollmelon = new RollMelon();
                    rollmelon.itemid = award.itemid;
                    rollmelon.itemnum = award.itemnum;
                    rollmelon.melonid = melonid.get();
                    Octets itemdata = item.getTips();
                    if (itemdata != null) {
                        rollmelon.itemdata = item.getTips();
                    }

                    msg.melonlist.add(rollmelon);
                    melonid.addAndGet(1L);
                }
            }

            for(Long roleid : roleids) {
                Roleid2battlemelonid.insert(roleid, this.battleid);
                Procedure.psendWhileCommit(roleid, msg);
            }

            if (this.watcherids != null) {
                STeamRollMelon msg1 = new STeamRollMelon();
                msg1.watcher = 1;
                msg1.melonlist.addAll(msg.melonlist);

                for(Long roleid : this.watcherids) {
                    Procedure.psendWhileCommit(roleid, msg1);
                }

                eteammelon.getWatchmelonerlist().addAll(this.watcherids);
            }

            Executor.getInstance().schedule(new PEndMelonTask(this.battleid), 6000L, TimeUnit.MILLISECONDS);
            return true;
        }
    }

    public void CopyItemData(Item out, Item in) {
        out.setExtid(in.getExtid());
        out.setFlags(in.getFlags());
        out.setId(in.getId());
        out.setLoseeffecttime(in.getLoseeffecttime());
        out.setNumber(in.getNumber());
        out.setPosition(in.getPosition());
        out.setTimeout(in.getTimeout());
        out.setUniqueid(in.getUniqueid());
        out.getNumbermap().putAll(in.getNumbermap());
    }
}
