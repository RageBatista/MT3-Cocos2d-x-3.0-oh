//
// 由 IntelliJ IDEA 根据 .class 文件还原的源代码
// （由 FernFlower 反编译器生成）
//

package fire.pb.instancezone.bingfeng;

import fire.log.enums.YYLoggerTuJingEnum;
import fire.pb.StateCommon;
import fire.pb.circletask.PAbandonCircleTask;
import fire.pb.clan.ClanUtils;
import fire.pb.clan.PRefreshRoleClanKey;
import fire.pb.clan.PUpdateMemberDataProc;
import fire.pb.clan.SFireMember;
import fire.pb.clan.SLeaveClan;
import fire.pb.clan.srv.PClanUpdateMemberNum;
import fire.pb.item.ItemMaps;
import fire.pb.item.Module;
import fire.pb.item.Pack;
import fire.pb.main.ModuleManager;
import fire.pb.map.Role;
import fire.pb.map.RoleManager;
import fire.pb.ranklist.proc.PFactionZongHeProc;
import fire.pb.ranklist.proc.PRoleZongheRankProc;
import fire.pb.talk.MessageMgr;
import fire.pb.util.BagUtil;
import fire.pb.util.FireProp;
import gnet.link.Onlines;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.GroupLayout.Alignment;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.table.DefaultTableModel;
import mkdb.Procedure;
import mkdb.util.AutoKey;
import xbean.ClanInfo;
import xbean.ClanMemberInfo;
import xbean.Properties;
import xtable.Clans;
import xtable.Roleid2userid;
import xtable.Roleidclan;
import xtable.User;

public class GMTool extends JFrame {
    private static final long serialVersionUID = 1L;
    boolean notFind = true;
    private AutoKey<Long> maxId = null;
    private JButton jButton1;
    private JButton jButton2;
    private JButton jButton3;
    private JButton jButton4;
    private JButton jButton5;
    private JButton jButton6;
    private JButton jButton7;
    private JButton jButton8;
    private JLabel jLabel1;
    private JLabel jLabel2;
    private JLabel jLabel3;
    private JLabel jLabel4;
    private JScrollPane jScrollPane2;
    private JTable jTable1;
    private JTextField jTextField1;
    private JTextField jTextField2;
    private JTextField jTextField3;
    private JTextField jTextField4;

    public GMTool() {
        this.initComponents();
    }

    private void initComponents() {
        this.jScrollPane2 = new JScrollPane();
        this.jTable1 = new JTable();
        this.jButton1 = new JButton();
        this.jButton2 = new JButton();
        this.jTextField1 = new JTextField();
        this.jLabel1 = new JLabel();
        this.jLabel2 = new JLabel();
        this.jTextField2 = new JTextField();
        this.jButton3 = new JButton();
        this.jButton3.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                GMTool.this.addequipitem();
            }
        });
        this.jButton4 = new JButton();
        this.jButton4.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                GMTool.this.addequipitemAll();
            }
        });
        this.jButton5 = new JButton();
        this.jLabel3 = new JLabel();
        this.jTextField3 = new JTextField();
        this.jButton6 = new JButton();
        this.jButton6.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                GMTool.this.getRoleDetail();
            }
        });
        this.jLabel4 = new JLabel();
        this.jTextField4 = new JTextField();
        this.jButton7 = new JButton();
        this.jButton7.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                GMTool.this.recharge();
            }
        });
        this.jButton8 = new JButton();
        this.jButton8.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                GMTool.this.rechargeAll();
            }
        });
        this.setDefaultCloseOperation(3);
        this.setTitle("MT3_GM工具 By CB V1.2正式版");
        this.setResizable(false);
        this.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent evt) {
                GMTool.this.formWindowClosing(evt);
            }
        });
        this.jTable1.setModel(new DefaultTableModel(new Object[0][], new String[]{"角色ID", "角色名称", "绑定手机", "等级", "战力", "是否在线"}) {
            boolean[] canEdit = new boolean[6];

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return this.canEdit[columnIndex];
            }
        });
        this.jScrollPane2.setViewportView(this.jTable1);
        this.jButton1.setText("删除角色");
        this.jButton1.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                GMTool.this.jButton1ActionPerformed(evt);
            }
        });
        this.jButton2.setText("强制踢出角色");
        this.jButton2.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                GMTool.this.jButton2ActionPerformed(evt);
            }
        });
        this.jTextField1.setToolTipText("");
        this.jTextField1.setName("");
        this.jLabel1.setText("物品ID:");
        this.jLabel2.setText("数量:");
        this.jButton3.setText("发送");
        this.jButton4.setText("全服发送");
        this.jButton5.setText("查询在线人数");
        this.jButton5.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                GMTool.this.jButton5ActionPerformed(evt);
            }
        });
        this.jLabel3.setText("角色ID:");
        this.jButton6.setText("查询角色");
        this.jLabel4.setText("充值符石数量:");
        this.jButton7.setText("充值符石");
        this.jButton8.setText("全服充值");
        GroupLayout layout = new GroupLayout(this.getContentPane());
        this.getContentPane().setLayout(layout);
        layout.setHorizontalGroup(layout.createParallelGroup(Alignment.LEADING).addGroup(layout.createSequentialGroup().addContainerGap().addGroup(layout.createParallelGroup(Alignment.LEADING).addComponent(this.jScrollPane2).addGroup(layout.createSequentialGroup().addGap(14, 14, 14).addGroup(layout.createParallelGroup(Alignment.TRAILING).addGroup(layout.createSequentialGroup().addComponent(this.jButton5).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jButton2).addPreferredGap(ComponentPlacement.UNRELATED).addComponent(this.jButton1, -2, 105, -2).addGap(0, 19, 32767)).addGroup(layout.createSequentialGroup().addGap(0, 0, 32767).addComponent(this.jLabel3).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jTextField3, -2, 97, -2).addGap(0, 0, 0))).addGroup(layout.createParallelGroup(Alignment.TRAILING).addGroup(layout.createSequentialGroup().addComponent(this.jLabel1).addGap(2, 2, 2).addComponent(this.jTextField1, -2, 94, -2).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jLabel2).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jTextField2, -2, 75, -2).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jButton3, -2, 84, -2).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jButton4, -2, 100, -2)).addGroup(layout.createSequentialGroup().addComponent(this.jButton6).addPreferredGap(ComponentPlacement.RELATED, 27, 32767).addComponent(this.jLabel4).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jTextField4, -2, 75, -2).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jButton7, -2, 85, -2).addPreferredGap(ComponentPlacement.RELATED).addComponent(this.jButton8, -2, 99, -2))).addGap(55, 55, 55))).addContainerGap()));
        layout.setVerticalGroup(layout.createParallelGroup(Alignment.LEADING).addGroup(Alignment.TRAILING, layout.createSequentialGroup().addContainerGap(20, 32767).addGroup(layout.createParallelGroup(Alignment.BASELINE).addComponent(this.jButton1).addComponent(this.jButton2).addComponent(this.jLabel1).addComponent(this.jTextField1, -2, -1, -2).addComponent(this.jLabel2).addComponent(this.jTextField2, -2, -1, -2).addComponent(this.jButton3).addComponent(this.jButton4).addComponent(this.jButton5)).addGap(18, 18, 18).addGroup(layout.createParallelGroup(Alignment.BASELINE).addComponent(this.jLabel4).addComponent(this.jTextField4, -2, -1, -2).addComponent(this.jButton7).addComponent(this.jButton8).addComponent(this.jButton6).addComponent(this.jTextField3, -2, -1, -2).addComponent(this.jLabel3)).addPreferredGap(ComponentPlacement.UNRELATED).addComponent(this.jScrollPane2, -2, 496, -2).addContainerGap()));
        this.jButton1.getAccessibleContext().setAccessibleName("jButton1_删除角色");
        this.setSize(new Dimension(916, 639));
        this.setLocationRelativeTo((Component)null);
    }

    private void formWindowClosing(WindowEvent evt) {
        int result = JOptionPane.showConfirmDialog(this, "退出后服务器将停止运行，确认退出？", "信息", 0);
        if (result == 0) {
            System.exit(0);
        } else {
            this.setDefaultCloseOperation(0);
        }

    }

    private void jButton5ActionPerformed(ActionEvent evt) {
        this.getRoleNum();
    }

    private void jButton2ActionPerformed(ActionEvent evt) {
        this.removeUser();
    }

    private void jButton1ActionPerformed(ActionEvent evt) {
        this.deleteRole();
    }

    private void getRoleNum() {
        int val = RoleManager.getInstance().getRoles().size();
        JOptionPane.showMessageDialog(this, "当前在线人数：" + val, "信息", 1);
    }

    private void removeUser() {
        int count = this.jTable1.getSelectedRow();
        if (-1 == count) {
            JOptionPane.showMessageDialog(this, "请选择要踢出的角色！", "信息", 1);
        } else {
            String roleID = this.jTable1.getValueAt(count, 0).toString();
            Integer userID = Roleid2userid.select(Long.valueOf(roleID));

            try {
                if (userID != null) {
                    if (StateCommon.isOnline(Long.valueOf(roleID))) {
                        Properties prop = xtable.Properties.select(Long.valueOf(roleID));
                        if (prop == null) {
                            int msgid = FireProp.getIntValue(MessageMgr.msgprop, "gm.checkroleid.unexist");
                            MessageMgr.sendMsgNotify(Long.valueOf(roleID), msgid, (List)null);
                            return;
                        }

                        Onlines.getInstance().kick(Long.valueOf(roleID), 2049);
                        int msgid = FireProp.getIntValue(MessageMgr.msgprop, "gm.kick.succ");
                        MessageMgr.sendMsgNotify(Long.valueOf(roleID), msgid, (List)null);
                    } else {
                        Onlines.getInstance().getConnectedUsers().remove(userID);
                    }
                }

                JOptionPane.showMessageDialog(this, "踢出角色成功！", "信息", 1);
            } catch (Exception var6) {
                JOptionPane.showMessageDialog(this, "踢出角色失败！", "信息", 1);
            }

        }
    }

    private void deleteRole() {
        int result = JOptionPane.showConfirmDialog(this, "该功能未完全测试，可能会出现未知问题，确认删除角色？", "信息", 0);
        if (result == 0) {
            int count = this.jTable1.getSelectedRow();
            if (-1 == count) {
                JOptionPane.showMessageDialog(this, "请选择要删除的角色！", "信息", 1);
                return;
            }

            final long roleID = Long.valueOf(this.jTable1.getValueAt(count, 0).toString());

            try {
                (new Procedure() {
                    protected boolean process() {
                        Integer userID = Roleid2userid.select(roleID);
                        if (userID != null) {
                            if (StateCommon.isOnline(Long.valueOf(roleID))) {
                                Properties prop = xtable.Properties.select(roleID);
                                if (prop == null) {
                                    int msgid = FireProp.getIntValue(MessageMgr.msgprop, "gm.checkroleid.unexist");
                                    MessageMgr.sendMsgNotify(Long.valueOf(roleID), msgid, (List)null);
                                    return false;
                                }

                                Onlines.getInstance().kick(roleID, 2049);
                                int msgid = FireProp.getIntValue(MessageMgr.msgprop, "gm.kick.succ");
                                MessageMgr.sendMsgNotify(Long.valueOf(roleID), msgid, (List)null);
                            } else {
                                Onlines.getInstance().getConnectedUsers().remove(userID);
                            }
                        }

                        Long clankey = xtable.Properties.selectClankey(roleID);
                        if (clankey != null) {
                            ClanInfo clanInfo = Clans.get(clankey);
                            if (clankey != null) {
                                Long masterId = clanInfo.getClanmaster();
                                GMTool.this.exitClan(roleID, masterId, clanInfo, 3);
                            }
                        }

                        RoleManager.getInstance().removeRoleByID(roleID);
                        User.remove(xtable.Properties.selectUserid(roleID));
                        xtable.Properties.remove(roleID);
                        return true;
                    }
                }).submit();
                this.getRoleDetail();
                JOptionPane.showMessageDialog(this, "删除角色成功！", "信息", 1);
            } catch (Exception var6) {
                JOptionPane.showMessageDialog(this, "删除角色失败！", "信息", 1);
            }
        }

    }

    private void exitClan(long roleId, long masterId, ClanInfo claninfo, int reason) {
        ClanMemberInfo fmi = (ClanMemberInfo)claninfo.getMembers().get(roleId);
        int position = fmi.getClanposition();
        ClanUtils.removeClanTitleByPosition(roleId, position);
        claninfo.getMembers().remove(roleId);
        Properties prop = xtable.Properties.get(roleId);
        prop.setClankey(0L);
        if (reason == 1) {
            prop.setExitstate(1);
        } else if (reason == 2) {
            prop.setExitstate(1);
        } else if (reason == 3) {
            prop.setExitstate(2);
        }

        prop.setOldclankey(claninfo.getKey());
        Roleidclan.remove(roleId);
        if (reason == 1) {
            Procedure.psendWhileCommit(roleId, new SLeaveClan(roleId));
        } else if (reason == 2 || reason == 3) {
            SFireMember sFireMember = new SFireMember();
            sFireMember.memberroleid = roleId;
            if (masterId > 0L) {
                Procedure.psendWhileCommit(masterId, sFireMember);
            }

            Procedure.psendWhileCommit(roleId, sFireMember);
        }

        Procedure.pexecuteWhileCommit(new PRoleZongheRankProc(roleId));
        claninfo.setTotalscore(claninfo.getTotalscore() - prop.getRolezonghemaxscore());
        Procedure.pexecuteWhileCommit(new PFactionZongHeProc(claninfo.getKey(), false));
        Procedure.pexecuteWhileCommit(new PClanUpdateMemberNum(claninfo.getKey(), claninfo.getMembers().size()));
        Procedure.pexecuteWhileCommit(new PAbandonCircleTask(roleId, 1060000));
        Procedure.pexecuteWhileCommit(new PUpdateMemberDataProc(roleId));
        Procedure.pexecuteWhileCommit(new PRefreshRoleClanKey(roleId));
    }

    private void getRoleDetail() {
        List<Properties> roles = new ArrayList();

        for(int i = 0; (long)i <= this.getMaxId(); ++i) {
            Properties role = xtable.Properties.select((long)i);
            if (role != null) {
                role.setUserid(i);
                roles.add(role);
            }
        }

        DefaultTableModel tableModel = (DefaultTableModel)this.jTable1.getModel();
        if ("".equals(this.jTextField3.getText().trim())) {
            tableModel.setRowCount(0);

            for(Properties role : roles) {
                String[] arr = new String[]{String.valueOf(role.getUserid()), role.getRolename(), String.valueOf(role.getBindtel()), String.valueOf(role.getLevel()), String.valueOf(role.getRolezonghemaxscore()), null};
                Role onlineRole = RoleManager.getInstance().getRoleByID((long)role.getUserid());
                if (onlineRole == null) {
                    arr[5] = "离线";
                } else {
                    arr[5] = "在线";
                }

                tableModel.addRow(arr);
            }

            this.jTable1.invalidate();
        } else {
            tableModel.setRowCount(0);

            for(Properties role : roles) {
                String[] arr = new String[6];
                if (Integer.valueOf(this.jTextField3.getText().trim()) == role.getUserid()) {
                    arr[0] = String.valueOf(role.getUserid());
                    arr[1] = role.getRolename();
                    arr[2] = String.valueOf(role.getBindtel());
                    arr[3] = String.valueOf(role.getLevel());
                    arr[4] = String.valueOf(role.getRolezonghemaxscore());
                    Role onlineRole = RoleManager.getInstance().getRoleByID((long)role.getUserid());
                    if (onlineRole == null) {
                        arr[5] = "离线";
                    } else {
                        arr[5] = "在线";
                    }

                    tableModel.addRow(arr);
                    break;
                }
            }

            this.jTable1.invalidate();
        }

    }

    private void addequipitem() {
        int count = this.jTable1.getSelectedRow();
        if (-1 == count) {
            JOptionPane.showMessageDialog(this, "请选择要发送的角色！", "信息", 2);
        } else {
            String roleID = this.jTable1.getValueAt(count, 0).toString();
            if (!"".equals(this.jTextField1.getText().trim().toString()) && this.jTextField1.getText().trim().toString() != null && !"".equals(this.jTextField2.getText().trim().toString()) && this.jTextField2.getText().trim().toString() != null) {
                if (Integer.valueOf(this.jTextField2.getText()) < 100 && Integer.valueOf(this.jTextField2.getText()) > 0) {
                    Module itemmodule = (Module)ModuleManager.getInstance().getModuleByName("item");
                    if (itemmodule != null) {
                        (new PAddItem(Long.valueOf(roleID), itemmodule, Integer.valueOf(this.jTextField1.getText()), Integer.valueOf(this.jTextField2.getText()), 1)).submit();
                        if (this.notFind) {
                            JOptionPane.showMessageDialog(this, "发送成功！", "信息", 1);
                        } else {
                            JOptionPane.showMessageDialog(this, "发送失败,请检查物品ID是否正确！", "信息", 1);
                            this.notFind = true;
                        }
                    }

                } else {
                    JOptionPane.showMessageDialog(this, "物品数量不能小于0或大于99！", "信息", 2);
                }
            } else {
                JOptionPane.showMessageDialog(this, "物品id或数量不能为空！", "信息", 2);
            }
        }
    }

    private String getMACAddress() {
        InetAddress ia = null;

        try {
            ia = InetAddress.getLocalHost();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }

        byte[] mac = (byte[])null;

        try {
            mac = NetworkInterface.getByInetAddress(ia).getHardwareAddress();
        } catch (SocketException e) {
            e.printStackTrace();
        }

        StringBuffer sb = new StringBuffer();

        for(int i = 0; i < mac.length; ++i) {
            if (i != 0) {
                sb.append("-");
            }

            String s = Integer.toHexString(mac[i] & 255);
            sb.append(s.length() == 1 ? 0 + s : s);
        }

        return sb.toString().toUpperCase();
    }

    private void recharge() {
        int count = this.jTable1.getSelectedRow();
        if (-1 == count) {
            JOptionPane.showMessageDialog(this, "请选择要充值的角色！", "信息", 2);
        } else {
            final String roleID = this.jTable1.getValueAt(count, 0).toString();
            if (!"".equals(this.jTextField4.getText().trim().toString()) && this.jTextField4.getText().trim().toString() != null) {
                if (Integer.valueOf(this.jTextField4.getText()) <= 99999999 && Integer.valueOf(this.jTextField4.getText()) > 0) {
                    int moneyType = 3;
                    final long money = Long.valueOf(this.jTextField4.getText());
                    if (money != 0L && money <= 1152921504606846976L && money >= -1152921504606846976L) {
                        try {
                            (new Procedure() {
                                protected boolean process() {
                                    Pack bag = new Pack(Long.valueOf(roleID), false);
                                    bag.addSysCurrency(money, 3, "GM指令 加货币", YYLoggerTuJingEnum.GM, 0);
                                    return true;
                                }
                            }).submit();
                            JOptionPane.showMessageDialog(this, "充值成功！！", "信息", 1);
                        } catch (Exception var7) {
                            JOptionPane.showMessageDialog(this, "充值失败！", "信息", 1);
                        }

                    } else {
                        JOptionPane.showMessageDialog(this, "请输入正确的符石数量！", "信息", 2);
                    }
                } else {
                    JOptionPane.showMessageDialog(this, "符石数量不能小于0或大于99999999！", "信息", 2);
                }
            } else {
                JOptionPane.showMessageDialog(this, "请输入正确的符石数量！", "信息", 2);
            }
        }
    }

    private void rechargeAll() {
        try {
            if ("".equals(this.jTextField4.getText().trim().toString()) || this.jTextField4.getText().trim().toString() == null) {
                JOptionPane.showMessageDialog(this, "请输入正确的符石数量！", "信息", 2);
                return;
            }

            if (Integer.valueOf(this.jTextField4.getText()) > 99999999 || Integer.valueOf(this.jTextField4.getText()) <= 0) {
                JOptionPane.showMessageDialog(this, "符石数量不能小于0或大于99999999！", "信息", 2);
                return;
            }

            for(int i = 0; (long)i <= this.getMaxId(); ++i) {
                Properties role = xtable.Properties.select((long)i);
                if (role != null) {
                    final Long roleID = (long)i;
                    int moneyType = 3;
                    final long money = Long.valueOf(this.jTextField4.getText());
                    if (money == 0L || money > 1152921504606846976L || money < -1152921504606846976L) {
                        JOptionPane.showMessageDialog(this, "请输入正确的符石数量！", "信息", 2);
                        break;
                    }

                    (new Procedure() {
                        protected boolean process() {
                            Pack bag = new Pack(Long.valueOf(roleID), false);
                            bag.addSysCurrency(money, 3, "GM指令 加货币", YYLoggerTuJingEnum.GM, 0);
                            return true;
                        }
                    }).submit();
                }
            }

            JOptionPane.showMessageDialog(this, "充值成功！！", "信息", 1);
        } catch (Exception var7) {
            JOptionPane.showMessageDialog(this, "充值失败！", "信息", 1);
        }

    }

    private void addequipitemAll() {
        if (!"".equals(this.jTextField1.getText().trim().toString()) && this.jTextField1.getText().trim().toString() != null && !"".equals(this.jTextField2.getText().trim().toString()) && this.jTextField2.getText().trim().toString() != null) {
            if (Integer.valueOf(this.jTextField2.getText()) < 100 && Integer.valueOf(this.jTextField2.getText()) > 0) {
                for(int i = 0; (long)i <= this.getMaxId(); ++i) {
                    Properties role = xtable.Properties.select((long)i);
                    if (role != null) {
                        Long roleID = (long)i;
                        Module itemmodule = (Module)ModuleManager.getInstance().getModuleByName("item");
                        if (itemmodule != null) {
                            if (!this.notFind) {
                                break;
                            }

                            (new PAddItem(Long.valueOf(roleID), itemmodule, Integer.valueOf(this.jTextField1.getText()), Integer.valueOf(this.jTextField2.getText()), 1)).submit();
                        }
                    }
                }

                if (this.notFind) {
                    JOptionPane.showMessageDialog(this, "发送成功！", "信息", 1);
                } else {
                    JOptionPane.showMessageDialog(this, "发送失败,请检查物品ID是否正确！", "信息", 1);
                    this.notFind = true;
                }

            } else {
                JOptionPane.showMessageDialog(this, "物品数量不能小于0或大于99！", "信息", 2);
            }
        } else {
            JOptionPane.showMessageDialog(this, "物品id或数量不能为空！", "信息", 2);
        }
    }

    private long getMaxId() {
        (new Procedure() {
            protected boolean process() {
                GMTool.this.maxId = xtable.Properties.getAutoKey();
                return true;
            }
        }).submit();
        return (Long)this.maxId.current();
    }

    class PAddItem extends Procedure {
        private final int id;
        private final int number;
        private final int bagid;
        private final long roleid;

        PAddItem(long roleid, Module itemmodule, int id, int number, int bagid) {
            this.roleid = roleid;
            this.id = id;
            this.bagid = bagid;
            this.number = number;
        }

        protected boolean process() {
            ItemMaps ic = Module.getInstance().getItemMaps(this.roleid, this.bagid, false);
            boolean isSucc = false;

            try {
                isSucc = ic != null && BagUtil.addItem(this.roleid, this.id, this.number, "GM添加物品", YYLoggerTuJingEnum.GM, this.id) > 0;
                return isSucc;
            } catch (Exception var4) {
                GMTool.this.notFind = false;
                return false;
            }
        }
    }
}
