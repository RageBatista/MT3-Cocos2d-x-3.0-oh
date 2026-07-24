package test;

import mkdb.Mkdb;
import mkdb.MkdbConf;
import mkdb.Procedure;

public class TestMkdbMain {
    public static void main(String[] args) {
        Mkdb.getInstance().setConf(new MkdbConf("mkdb.xml"));
        Mkdb.getInstance().start();
        new Procedure() {
            @Override
            protected boolean process() {
                xtable.Table_int.insert(1, 42);
                Integer v = xtable.Table_int.get(1);
                System.out.println("table_int[1]=" + v);
                return true;
            }
        }.call();
        Mkdb.getInstance().stop();
    }
}
