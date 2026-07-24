//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.state;

import gnet.link.Onlines;
import gnet.link.Role;
import org.apache.log4j.Logger;
import xbean.Properties;
import xtable.Roleonoffstate;

public class StateDebugUtil {
    private static final Logger logger = Logger.getLogger("SYSTEM");

    public static void diagnoseRoleState(long roleId, String context) {
        try {
            logger.info("=== 角色状态诊断开始 [" + roleId + "] 上下文: " + context + " ===");
            Integer memoryState = Roleonoffstate.get(roleId);
            Integer dbState = Roleonoffstate.select(roleId);
            logger.info("角色[" + roleId + "] 内存状态=" + memoryState + ", 数据库状态=" + dbState);
            Properties prop = xtable.Properties.select(roleId);
            if (prop != null) {
                logger.info("角色[" + roleId + "] 基本信息: 名称=" + prop.getRolename() + ", 等级=" + prop.getLevel() + ", 删除时间=" + prop.getDeletetime() + ", 用户ID=" + prop.getUserid());
            } else {
                logger.error("角色[" + roleId + "] Properties数据为空");
            }

            Role linkRole = Onlines.getInstance().find(roleId);
            if (linkRole != null) {
                logger.info("角色[" + roleId + "] 在线状态: 用户ID=" + linkRole.getUserid() + ", 会话=" + linkRole.getLinkSession());
            } else {
                logger.info("角色[" + roleId + "] 不在在线列表中");
            }

            if (memoryState != null && dbState != null && !memoryState.equals(dbState)) {
                logger.warn("角色[" + roleId + "] 状态不一致！内存=" + memoryState + ", 数据库=" + dbState);
            }

            logger.info("=== 角色状态诊断结束 [" + roleId + "] ===");
        } catch (Exception e) {
            logger.error("角色[" + roleId + "] 状态诊断异常: " + e.getMessage(), e);
        }

    }

    public static boolean fixRoleState(long roleId, int expectedState) {
        try {
            logger.info("开始修复角色[" + roleId + "]状态，目标状态=" + expectedState);
            diagnoseRoleState(roleId, "状态修复前");
            Roleonoffstate.remove(roleId);
            Roleonoffstate.add(roleId, expectedState);
            Integer newState = Roleonoffstate.get(roleId);
            if (newState != null && newState == expectedState) {
                logger.info("角色[" + roleId + "]状态修复成功，新状态=" + newState);
                return true;
            } else {
                logger.error("角色[" + roleId + "]状态修复失败，期望=" + expectedState + ", 实际=" + newState);
                return false;
            }
        } catch (Exception e) {
            logger.error("角色[" + roleId + "]状态修复异常: " + e.getMessage(), e);
            return false;
        }
    }

    public static String getStateName(Integer state) {
        if (state == null) {
            return "NULL";
        } else {
            switch (state) {
                case 0:
                    return "UnEntryState";
                case 1:
                    return "PreEntryState";
                case 2:
                    return "EntryState";
                case 3:
                    return "PreOfflineProtectState";
                case 4:
                    return "OfflineProtectState";
                case 5:
                    return "BreakOfflineProtectState";
                case 6:
                    return "EndOfflineProtectState";
                case 7:
                    return "PreTrusteeShipState";
                case 8:
                    return "TrusteeShipState";
                case 9:
                    return "BreakTrusteeShipState";
                case 10:
                    return "EndTrusteeShipState";
                default:
                    return "Unknown(" + state + ")";
            }
        }
    }

    public static boolean isValidTransition(int fromState, int toState, int trigger) {
        switch (toState) {
            case 1:
                return trigger == 0 && fromState == 0;
            case 2:
                return trigger == 3 && (fromState == 1 || fromState == 5 || fromState == 9);
            default:
                return false;
        }
    }
}
