package fire.script; 

import java.util.HashMap;
import java.util.Map;
import fire.pb.battle.Fighter;

public class JsFunManager
{
	static Map<String, Integer> funMap = new HashMap<String, Integer>();
	public JsFunManager(){InitFunMap();}
	static public float randfloat(int t, int t1) { return (float)(t1 > t ? Math.random()*(t1-t) + t : Math.random()*(t-t1) + t1) ; }
	static public int   randint(int t,int t1) {return (int)(t1 > t ? Math.round(Math.random()*(t1-t)) + t : Math.round(Math.random()*(t-t1)) + t1) ;}
	static public int GetFunID(String fun)	{  if(funMap.size() < 1) return -1;if(funMap.get(fun)!= null) return funMap.get(fun); else return -1; }
	static public void InitFunMap()
	{
		funMap.put("with(Math){ return -(max(phyattacka*1-defendb+1*gradea,phyattacka*0.1)+(havebuffa(509300)?(min(max(defendb-phyattackb,((pve)?(2*gradea):(10))),4*gradea)):(0)));}",0);
		funMap.put("with(Math){ return -(phyattacka*1-defendb+1*gradea);}",1);
		funMap.put("with(Math){ return quality*60+2000;}",2);
		funMap.put("with(Math){ return quality*0.6+10;}",3);
		funMap.put("with(Math){ return quality*32+1000;}",4);
		funMap.put("with(Math){ return quality;}",5);
		funMap.put("with(Math){ return quality*0.4+10;}",6);
		funMap.put("with(Math){ return 400*(havebuffa(508042)?(1.2):(1));}",7);
		funMap.put("with(Math){ return (quality*12+150)*(havebuffa(508042)?(1.2):(1));}",8);
		funMap.put("with(Math){ return (quality*5+50)*(havebuffa(508042)?(1.2):(1));}",9);
		funMap.put("with(Math){ return quality*3*(havebuffa(508042)?(1.2):(1));}",10);
		funMap.put("with(Math){ return (quality*5+100)*(havebuffa(508042)?(1.2):(1));}",11);
		funMap.put("with(Math){ return 100*(havebuffa(508042)?(1.2):(1));}",12);
		funMap.put("with(Math){ return -quality*3;}",13);
		funMap.put("with(Math){ return pve;}",14);
		funMap.put("with(Math){ return 200*(havebuffa(508042)?(1.2):(1));}",15);
		funMap.put("with(Math){ return 150*(havebuffa(508042)?(1.2):(1));}",16);
		funMap.put("with(Math){ return 300*(havebuffa(508042)?(1.2):(1));}",17);
		funMap.put("with(Math){ return 250*(havebuffa(508042)?(1.2):(1));}",18);
		funMap.put("with(Math){ return quality*12+150;}",19);
		funMap.put("with(Math){ return quality*5+50;}",20);
		funMap.put("with(Math){ return skilllevela*10;}",21);
		funMap.put("with(Math){ return 2.5*skilllevela;}",22);
		funMap.put("with(Math){ return 2*skilllevela;}",23);
		funMap.put("with(Math){ return 10+1.2*skilllevela;}",24);
		funMap.put("with(Math){ return -(phyattacka*1.05-defendb+1*skilllevela);}",25);
		funMap.put("with(Math){ return -(phyattacka*0.9-defendb+1*skilllevela);}",26);
		funMap.put("with(Math){ return -(phyattacka*0.75-defendb+1*skilllevela);}",27);
		funMap.put("with(Math){ return skilllevela>=70;}",28);
		funMap.put("with(Math){ return -(phyattacka*0.65-defendb+1*skilllevela);}",29);
		funMap.put("with(Math){ return (curhpa/maxhpa)>=0.5;}",30);
		funMap.put("with(Math){ return -(phyattacka*1.15-defendb+1*skilllevela);}",31);
		funMap.put("with(Math){ return -(phyattacka*1.25-defendb+1*skilllevela);}",32);
		funMap.put("with(Math){ return -(phyattacka*0.55-defendb+1*skilllevela);}",33);
		funMap.put("with(Math){ return min(-2.4*gradea+1.2*skilllevela,0);}",34);
		funMap.put("with(Math){ return -min((random()*(0.13-0.07)+0.07)*maxhpa,curhpa-1);}",35);
		funMap.put("with(Math){ return 0.15*maxhpb;}",36);
		funMap.put("with(Math){ return 1*skilllevela;}",37);
		funMap.put("with(Math){ return -(phyattacka*1-defendb+1*gradea)*(0.45+0.05*skilllevela);}",38);
		funMap.put("with(Math){ return (curhpa/maxhpa)<=0.8;}",39);
		funMap.put("with(Math){ return (curhpa/maxhpa)<=0.6;}",40);
		funMap.put("with(Math){ return (curhpa/maxhpa)<=0.4;}",41);
		funMap.put("with(Math){ return (curhpa/maxhpa)<=0.2;}",42);
		funMap.put("with(Math){ return -(phyattacka*1-defendb+1*gradea)*(0.25+0.05*skilllevela);}",43);
		funMap.put("with(Math){ return 0.5*skilllevela;}",44);
		funMap.put("with(Math){ return 10*skilllevela;}",45);
		funMap.put("with(Math){ return -(phyattacka*1.45-defendb+1*skilllevela);}",46);
		funMap.put("with(Math){ return -(phyattacka*0.85-defendb+1*skilllevela);}",47);
		funMap.put("with(Math){ return 9*skilllevela;}",48);
		funMap.put("with(Math){ return 3*skilllevela;}",49);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+2*skilllevela)*(0.5+0.05*(4-preaimcount));}",50);
		funMap.put("with(Math){ return ((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))*0.5;}",51);
		funMap.put("with(Math){ return -(magicattacka*1.2-magicdefb+2*skilllevela)*(0.5+0.05*(4-preaimcount));}",52);
		funMap.put("with(Math){ return ((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))+0.05;}",53);
		funMap.put("with(Math){ return -1.4*skilllevela;}",54);
		funMap.put("with(Math){ return min(-1*gradea+0.5*skilllevela,0);}",55);
		funMap.put("with(Math){ return ((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)));}",56);
		funMap.put("with(Math){ return -2*skilllevela;}",57);
		funMap.put("with(Math){ return (((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16)*(0.3+0.05*skilllevela)*0.5;}",58);
		funMap.put("with(Math){ return (((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16)*(0.3+0.05*skilllevela)*0.5/(1-(((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16)*(0.3+0.05*skilllevela)*0.5);}",59);
		funMap.put("with(Math){ return -(phyattacka*1.1-defendb+1*skilllevela);}",60);
		funMap.put("with(Math){ return -(phyattacka*1.1-defendb*0.9+1*skilllevela);}",61);
		funMap.put("with(Math){ return gradea*2;}",62);
		funMap.put("with(Math){ return effectpointa<2;}",63);
		funMap.put("with(Math){ return effectpointa>=2;}",64);
		funMap.put("with(Math){ return -(phyattacka*0.95-defendb+1*skilllevela);}",65);
		funMap.put("with(Math){ return -(phyattacka*0.45-defendb+1*skilllevela);}",66);
		funMap.put("with(Math){ return 16*skilllevela;}",67);
		funMap.put("with(Math){ return -(magicattacka*1.1-magicdefb+1*skilllevela);}",68);
		funMap.put("with(Math){ return -(phyattacka*1.1-defendb+1*skilllevela+max(0,medicala-medicalb)*0.5);}",69);
		funMap.put("with(Math){ return -min(0.1*curhpb,10*skilllevela)-3*skilllevela;}",70);
		funMap.put("with(Math){ return ((medicala*0.5+skilllevela*1.4)+abs(maindamage)*0.1)*(1+healrevisea)*(1+medicaljiashena/1000);}",71);
		funMap.put("with(Math){ return maindamage;}",72);
		funMap.put("with(Math){ return ((medicala*0.2+skilllevela*1.2)+abs(maindamage)*0.08)*(1+healrevisea)*(1+medicaljiashena/1000);}",73);
		funMap.put("with(Math){ return -(phyattacka*1.05-defendb+1*skilllevela+max(0,medicala-medicalb)*0.5);}",74);
		funMap.put("with(Math){ return -(phyattacka*1.15-defendb+1*skilllevela+max(0,medicala-medicalb)*0.5);}",75);
		funMap.put("with(Math){ return -0.1-(0.1+0.05*skilllevela)*(1-curmpb/maxmpb);}",76);
		funMap.put("with(Math){ return 10+2.4*skilllevela;}",77);
		funMap.put("with(Math){ return -(magicattacka*2.5-magicdefb+2*skilllevela)*0.5;}",78);
		funMap.put("with(Math){ return abs(maindamage)*0.35;}",79);
		funMap.put("with(Math){ return abs(maindamage)*1;}",80);
		funMap.put("with(Math){ return -magicattacka*0.2;}",81);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+2*gradea)*0.5*(1.2+(0.6+0.2*skilllevela)*(1-curmpb/maxmpb));}",82);
		funMap.put("with(Math){ return 10+2*skilllevela;}",83);
		funMap.put("with(Math){ return -(magicattacka*1.3-magicdefb+2*skilllevela)*(0.5+0.05*(4-preaimcount));}",84);
		funMap.put("with(Math){ return medicala+3*skilllevela;}",85);
		funMap.put("with(Math){ return (medicala+3*skilllevela)*0.4;}",86);
		funMap.put("with(Math){ return 1.4*skilllevela;}",87);
		funMap.put("with(Math){ return medicala+3*skilllevela*2;}",88);
		funMap.put("with(Math){ return 0.15+0.1*skilllevela;}",89);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+2*skilllevela)*(0.5+0.05*(3-preaimcount))*(havebuffa(506109)?((random()*(1.20-1.1))+1.1):((random()*(1.20-0.9))+0.9));}",90);
		funMap.put("with(Math){ return -(magicattacka*2.5-magicdefb+2*skilllevela)*0.5*(havebuffa(506109)?((random()*(1.20-1.1))+1.1):((random()*(1.20-0.9))+0.9));}",91);
		funMap.put("with(Math){ return -(magicattacka*1-magicdefb+2*skilllevela)*0.5;}",92);
		funMap.put("with(Math){ return -(magicattacka*2.5-magicdefb+2*skilllevela)*0.5*(havebuffa(506109)?((random()*(1.20-1.1))+1.1):((random()*(1.20-0.9))+0.9))*(1+(0.4+0.1*skilllevela)*(1-curhpa/maxhpa));}",93);
		funMap.put("with(Math){ return 20*skilllevela;}",94);
		funMap.put("with(Math){ return 2.1*skilllevela;}",95);
		funMap.put("with(Math){ return medicala+1.2*skilllevela;}",96);
		funMap.put("with(Math){ return (medicala+1.2*skilllevela)*0.4;}",97);
		funMap.put("with(Math){ return effectpointa>=3;}",98);
		funMap.put("with(Math){ return effectpointa>=4;}",99);
		funMap.put("with(Math){ return effectpointa>=5;}",100);
		funMap.put("with(Math){ return 2*skilllevela+50;}",101);
		funMap.put("with(Math){ return randint(1,2);}",102);
		funMap.put("with(Math){ return 0.7*maxhpb;}",103);
		funMap.put("with(Math){ return -(speeda*0.1+7*skilllevela)*1.1;}",104);
		funMap.put("with(Math){ return -(speeda*0.1+10*skilllevela)*1.1;}",105);
		funMap.put("with(Math){ return ((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16;}",106);
		funMap.put("with(Math){ return 10+1.3*skilllevela;}",107);
		funMap.put("with(Math){ return 4.5*skilllevela;}",108);
		funMap.put("with(Math){ return -(magicattacka*2.5-magicdefb+2*gradea)*1.1;}",109);
		funMap.put("with(Math){ return skilllevela>=60;}",110);
		funMap.put("with(Math){ return -(magicattacka*3.5-magicdefb+2*skilllevela)*1.1;}",111);
		funMap.put("with(Math){ return -(magicattacka*3.0-magicdefb+2*gradea)*1.1;}",112);
		funMap.put("with(Math){ return skilllevela>=90;}",113);
		funMap.put("with(Math){ return 10+1.4*skilllevela;}",114);
		funMap.put("with(Math){ return -(phyattacka*0.4+defenda*0.5-defendb+2*gradea);}",115);
		funMap.put("with(Math){ return -0.05+0.1*skilllevela;}",116);
		funMap.put("with(Math){ return (sealhita>=unsealb)?(0.98-0.38*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)*(0.3+0.05*skilllevela)):(0.6*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)*(0.3+0.05*skilllevela));}",117);
		funMap.put("with(Math){ return -(phyattacka*0.7-defendb+1*skilllevela);}",118);
		funMap.put("with(Math){ return -(magicattacka*0.9-magicdefb+3*skilllevela);}",119);
		funMap.put("with(Math){ return skilllevela>=50;}",120);
		funMap.put("with(Math){ return -(phyattacka*0.5+defenda*0.6-defendb+1*skilllevela);}",121);
		funMap.put("with(Math){ return -(magicattacka*1-magicdefb+3*skilllevela);}",122);
		funMap.put("with(Math){ return maxhpb*1;}",123);
		funMap.put("with(Math){ return skilllevela*1;}",124);
		funMap.put("with(Math){ return skilllevela*50;}",125);
		funMap.put("with(Math){ return skilllevela*8;}",126);
		funMap.put("with(Math){ return -(magicattacka*1.1-magicdefb+3*skilllevela);}",127);
		funMap.put("with(Math){ return -curhpa*1;}",128);
		funMap.put("with(Math){ return -curhpb*0.05;}",129);
		funMap.put("with(Math){ return -curhpb*0.1;}",130);
		funMap.put("with(Math){ return -curhpb*0.2;}",131);
		funMap.put("with(Math){ return -curhpb*0.5;}",132);
		funMap.put("with(Math){ return 3+min(floor(skilllevela/60),1);}",133);
		funMap.put("with(Math){ return -curhpb*0.7;}",134);
		funMap.put("with(Math){ return -maxhpb*2.5;}",135);
		funMap.put("with(Math){ return maxhpa*1;}",136);
		funMap.put("with(Math){ return maxhpb;}",137);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+2*skilllevela)*(0.5+0.05*(3-preaimcount));}",138);
		funMap.put("with(Math){ return -maxhpb*0.5;}",139);
		funMap.put("with(Math){ return maxhpb*0.5;}",140);
		funMap.put("with(Math){ return ((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))*0.4;}",141);
		funMap.put("with(Math){ return ((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))*0.3;}",142);
		funMap.put("with(Math){ return 4+min(floor(skilllevela/60),1)+min(floor(skilllevela/90),1);}",143);
		funMap.put("with(Math){ return -(phyattacka*1.05-defendb+1*gradea);}",144);
		funMap.put("with(Math){ return -curhpa*0.8;}",145);
		funMap.put("with(Math){ return -curhpb*0.8;}",146);
		funMap.put("with(Math){ return -curmpa*0.8;}",147);
		funMap.put("with(Math){ return -maxhpb*0.1;}",148);
		funMap.put("with(Math){ return -maxhpb*0.2;}",149);
		funMap.put("with(Math){ return -maxhpb*0.3;}",150);
		funMap.put("with(Math){ return -maxhpb*0.4;}",151);
		funMap.put("with(Math){ return -maxhpb*0.6;}",152);
		funMap.put("with(Math){ return -maxhpb*0.7;}",153);
		funMap.put("with(Math){ return -(phyattacka*10-defendb+1*gradea+max((phyattacka-phyattackb)*0.05,0));}",154);
		funMap.put("with(Math){ return 0.6+0.002*(skilllevela-gradeb)+(enhanceseala-resistsealb);}",155);
		funMap.put("with(Math){ return 2+min(floor(skilllevela/60),1);}",156);
		funMap.put("with(Math){ return -(phyattacka*1.40-defendb+1*skilllevela)*2.5;}",157);
		funMap.put("with(Math){ return -(phyattacka*1.45-defendb+1*skilllevela)*2.5;}",158);
		funMap.put("with(Math){ return -(phyattacka*1.50-defendb+1*skilllevela)*2.5;}",159);
		funMap.put("with(Math){ return -(phyattacka*1.55-defendb+1*skilllevela)*2.5;}",160);
		funMap.put("with(Math){ return -(phyattacka*1.60-defendb+1*skilllevela)*2.5;}",161);
		funMap.put("with(Math){ return -(phyattacka*1.10-defendb+1*skilllevela)*2.5;}",162);
		funMap.put("with(Math){ return -magicattacka*2;}",163);
		funMap.put("with(Math){ return -magicattacka*3;}",164);
		funMap.put("with(Math){ return -magicattacka*2.2;}",165);
		funMap.put("with(Math){ return -magicattacka*1.6;}",166);
		funMap.put("with(Math){ return gradea*0.8;}",167);
		funMap.put("with(Math){ return gradea*0.4;}",168);
		funMap.put("with(Math){ return gradea*0.9;}",169);
		funMap.put("with(Math){ return gradea*20;}",170);
		funMap.put("with(Math){ return gradea*1.6;}",171);
		funMap.put("with(Math){ return 3*gradea;}",172);
		funMap.put("with(Math){ return -(magicattacka*2.2-magicdefb+2*gradea)*0.5;}",173);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+2*gradea)*(0.5+0.05*(2-preaimcount));}",174);
		funMap.put("with(Math){ return gradea>=60;}",175);
		funMap.put("with(Math){ return -(phyattacka*1-defendb+3*gradea);}",176);
		funMap.put("with(Math){ return -(phyattacka*0.75-defendb+1*gradea);}",177);
		funMap.put("with(Math){ return -(phyattacka*0.45-defendb+1*gradea);}",178);
		funMap.put("with(Math){ return maindamage*0.33*((random()*(1.05-0.95))+0.95);}",179);
		funMap.put("with(Math){ return -(phyattacka*1.25-defendb+1*gradea+max((phyattacka-phyattackb)*0.25,0));}",180);
		funMap.put("with(Math){ return -(phyattacka*2-defendb+1*gradea);}",181);
		funMap.put("with(Math){ return phyattacka*1.25-defendb+1*gradea;}",182);
		funMap.put("with(Math){ return ((random()*(3-2))+2);}",183);
		funMap.put("with(Math){ return ((random()*(5-3))+3);}",184);
		funMap.put("with(Math){ return maindamage*0.2*((random()*(1.05-0.95))+0.95);}",185);
		funMap.put("with(Math){ return -maindamage;}",186);
		funMap.put("with(Math){ return -(magicattacka*0.5-magicdefb+2*gradea)*(0.5+0.05*(2-preaimcount));}",187);
		funMap.put("with(Math){ return -(magicattacka*0.8-magicdefb+2*gradea)*(0.5+0.05*(2-preaimcount));}",188);
		funMap.put("with(Math){ return -(phyattacka*0.55-defendb+1*gradea);}",189);
		funMap.put("with(Math){ return abs(maindamage)*0.20;}",190);
		funMap.put("with(Math){ return -(magicattacka*3.5-magicdefb+2*skilllevela)*0.5;}",191);
		funMap.put("with(Math){ return -(phyattacka*1-defendb+7*gradea);}",192);
		funMap.put("with(Math){ return -(magicattacka*3.5-magicdefb+2*skilllevela)*0.3;}",193);
		funMap.put("with(Math){ return gradea*0.16;}",194);
		funMap.put("with(Math){ return gradea*0.1;}",195);
		funMap.put("with(Math){ return gradea*0.2;}",196);
		funMap.put("with(Math){ return gradea*0.125;}",197);
		funMap.put("with(Math){ return gradea*0.24;}",198);
		funMap.put("with(Math){ return gradea*0.15;}",199);
		funMap.put("with(Math){ return gradea*0.28;}",200);
		funMap.put("with(Math){ return gradea*0.175;}",201);
		funMap.put("with(Math){ return gradea*0.32;}",202);
		funMap.put("with(Math){ return gradea*0.7;}",203);
		funMap.put("with(Math){ return gradea*0.87;}",204);
		funMap.put("with(Math){ return gradea*1.05;}",205);
		funMap.put("with(Math){ return gradea*1.22;}",206);
		funMap.put("with(Math){ return gradea*1.4;}",207);
		funMap.put("with(Math){ return gradea*0.0007;}",208);
		funMap.put("with(Math){ return gradea*0.000875;}",209);
		funMap.put("with(Math){ return gradea*0.00105;}",210);
		funMap.put("with(Math){ return gradea*0.001225;}",211);
		funMap.put("with(Math){ return gradea*0.0014;}",212);
		funMap.put("with(Math){ return gradea*0.08;}",213);
		funMap.put("with(Math){ return gradea*1;}",214);
		funMap.put("with(Math){ return gradea*0.12;}",215);
		funMap.put("with(Math){ return gradea*1.2;}",216);
		funMap.put("with(Math){ return gradea*0.14;}",217);
		funMap.put("with(Math){ return gradea*0.189;}",218);
		funMap.put("with(Math){ return gradea*0.2362;}",219);
		funMap.put("with(Math){ return gradea*0.2835;}",220);
		funMap.put("with(Math){ return gradea*0.3375;}",221);
		funMap.put("with(Math){ return gradea*0.378;}",222);
		funMap.put("with(Math){ return gradea*0.875;}",223);
		funMap.put("with(Math){ return gradea*1.225;}",224);
		funMap.put("with(Math){ return gradea*0.05;}",225);
		funMap.put("with(Math){ return gradea*0.5;}",226);
		funMap.put("with(Math){ return gradea*0.0625;}",227);
		funMap.put("with(Math){ return gradea*0.625;}",228);
		funMap.put("with(Math){ return gradea*0.075;}",229);
		funMap.put("with(Math){ return gradea*0.75;}",230);
		funMap.put("with(Math){ return gradea*0.0875;}",231);
		funMap.put("with(Math){ return gradea*0.65;}",232);
		funMap.put("with(Math){ return gradea*0.85;}",233);
		funMap.put("with(Math){ return gradea*0.3;}",234);
		funMap.put("with(Math){ return gradea*0.375;}",235);
		funMap.put("with(Math){ return gradea*0.45;}",236);
		funMap.put("with(Math){ return gradea*0.525;}",237);
		funMap.put("with(Math){ return gradea*0.6;}",238);
		funMap.put("with(Math){ return gradea*3;}",239);
		funMap.put("with(Math){ return gradea*3.25;}",240);
		funMap.put("with(Math){ return gradea*3.5;}",241);
		funMap.put("with(Math){ return gradea*3.75;}",242);
		funMap.put("with(Math){ return gradea*4;}",243);
		funMap.put("with(Math){ return -gradea*3;}",244);
		funMap.put("with(Math){ return -(phyattacka*1.2-defendb+1*gradea);}",245);
		funMap.put("with(Math){ return -(phyattacka*1.6-defendb+1*gradea);}",246);
		funMap.put("with(Math){ return maindamage*((random()*(1.05-0.95))+0.95);}",247);
		funMap.put("with(Math){ return -max(curhpa-maxhpa*0.1,0);}",248);
		funMap.put("with(Math){ return 0.05*maxhpb;}",249);
		funMap.put("with(Math){ return 0.3*maxhpb;}",250);
		funMap.put("with(Math){ return 0.35*maxhpb;}",251);
		funMap.put("with(Math){ return maxhpb*0.03+200;}",252);
		funMap.put("with(Math){ return maxhpb*0.06+400;}",253);
		funMap.put("with(Math){ return maxhpb*0.09+600;}",254);
		funMap.put("with(Math){ return maxmpb*0.1+150;}",255);
		funMap.put("with(Math){ return maxmpb*0.15+250;}",256);
		funMap.put("with(Math){ return min(maxhpb*0.25,gradeb*18);}",257);
		funMap.put("with(Math){ return min(maxhpb*0.50,gradeb*30);}",258);
		funMap.put("with(Math){ return -curmpa;}",259);
		funMap.put("with(Math){ return min(maxhpb*0.25,gradeb*12);}",260);
		funMap.put("with(Math){ return min(maxhpb*0.15,gradeb*12);}",261);
		funMap.put("with(Math){ return -(phyattacka*0.65-defendb+1*gradea);}",262);
		funMap.put("with(Math){ return -(phyattacka*0.8-defendb+1*gradea);}",263);
		funMap.put("with(Math){ return -(phyattacka*0.5-defendb+1*gradea);}",264);
		funMap.put("with(Math){ return gradea*1.5;}",265);
		funMap.put("with(Math){ return 10+1.2*gradea;}",266);
		funMap.put("with(Math){ return 0.08*maxhpb;}",267);
		funMap.put("with(Math){ return -(phyattacka*1.6-defendb+1*skilllevela);}",268);
		funMap.put("with(Math){ return -(phyattacka*1.05-min(defendb,magicdefb)+1*skilllevela);}",269);
		funMap.put("with(Math){ return -(phyattacka*1.15-min(defendb,magicdefb)+1*skilllevela);}",270);
		funMap.put("with(Math){ return -(phyattacka*1.25-min(defendb,magicdefb)+1*skilllevela);}",271);
		funMap.put("with(Math){ return -(phyattacka*1.6-min(defendb,magicdefb)+1*skilllevela);}",272);
		funMap.put("with(Math){ return -maxhpb*0.15;}",273);
		funMap.put("with(Math){ return -(phyattacka*1.1-defendb+1*skilllevela+max(0,speeda-speedb)*0.5);}",274);
		funMap.put("with(Math){ return -(phyattacka*1.2-defendb*0.9+1*skilllevela+max(0,speeda-speedb)*0.5);}",275);
		funMap.put("with(Math){ return -(phyattacka*1.05-defendb+1*skilllevela+max(0,speeda-speedb)*0.5);}",276);
		funMap.put("with(Math){ return -(phyattacka*0.95-defendb+1*skilllevela+max(0,speeda-speedb)*0.5);}",277);
		funMap.put("with(Math){ return -(phyattacka*0.85-defendb+1*skilllevela+max(0,speeda-speedb)*0.5);}",278);
		funMap.put("with(Math){ return -(phyattacka*0.75-defendb+1*skilllevela+max(0,speeda-speedb)*0.5);}",279);
		funMap.put("with(Math){ return speeda;}",280);
		funMap.put("with(Math){ return -(phyattacka*1.3-defendb+1*skilllevela);}",281);
		funMap.put("with(Math){ return 5*skilllevela;}",282);
		funMap.put("with(Math){ return 0.8*skilllevela;}",283);
		funMap.put("with(Math){ return 0.7*skilllevela;}",284);
		funMap.put("with(Math){ return 1.2*skilllevela;}",285);
		funMap.put("with(Math){ return -min(0.2*curhpb,10*skilllevela)-3*skilllevela;}",286);
		funMap.put("with(Math){ return ((medicala*0.7+skilllevela*1.4)+abs(maindamage)*0.1)*(1+healrevisea)*(1+medicaljiashena/1000);}",287);
		funMap.put("with(Math){ return 0.1*maxhpb;}",288);
		funMap.put("with(Math){ return medicala+3.5*skilllevela;}",289);
		funMap.put("with(Math){ return 0.6*skilllevela;}",290);
		funMap.put("with(Math){ return medicala+4*skilllevela;}",291);
		funMap.put("with(Math){ return medicala+1*skilllevela;}",292);
		funMap.put("with(Math){ return 6*skilllevela;}",293);
		funMap.put("with(Math){ return round((pow(1.02,skilllevela)-1)*1000);}",294);
		funMap.put("with(Math){ return round((1-pow(0.98,skilllevela))*1000);}",295);
		funMap.put("with(Math){ return -8*skilllevela;}",296);
		funMap.put("with(Math){ return ((medicala+3*skilllevela)*0.5+abs(maindamage)*0.5)*(1+healrevisea)*(1+medicaljiashena/1000);}",297);
		funMap.put("with(Math){ return 14*skilllevela;}",298);
		funMap.put("with(Math){ return -(phyattacka*1.1-defendb*0.9+2*skilllevela);}",299);
		funMap.put("with(Math){ return -curhpb;}",300);
		funMap.put("with(Math){ return skilllevela>=2;}",301);
		funMap.put("with(Math){ return skilllevela>=3;}",302);
		funMap.put("with(Math){ return skilllevela>=4;}",303);
		funMap.put("with(Math){ return survivala<survivalb;}",304);
		funMap.put("with(Math){ return 3+min(floor(skilllevela/60),1)+min(floor(skilllevela/90),1);}",305);
		funMap.put("with(Math){ return 3+min(floor(skilllevela/60),1)+min(floor(skilllevela/90),2);}",306);
		funMap.put("with(Math){ return 3+min(floor(skilllevela/60),1)+min(floor(skilllevela/90),3);}",307);
		funMap.put("with(Math){ return 3+min(floor(skilllevela/60),1)+min(floor(skilllevela/90),4);}",308);
		funMap.put("with(Math){ return 3+min(floor(skilllevela/60),1)+min(floor(skilllevela/90),5);}",309);
		funMap.put("with(Math){ return 3+min(floor(skilllevela/60),1)+min(floor(skilllevela/90),6);}",310);
		funMap.put("with(Math){ return -(phyattacka*1.1-defendb+1*gradea);}",311);
		funMap.put("with(Math){ return -(phyattacka*2.5-defendb+1*gradea);}",312);
		funMap.put("with(Math){ return phyattacka*2-defendb+1*gradea;}",313);
		funMap.put("with(Math){ return -(2*magicattacka+bodong80-200);}",314);
		funMap.put("with(Math){ return maxhpa*0.12;}",315);
		funMap.put("with(Math){ return (maxhpa*0.2)*0.4;}",316);
		funMap.put("with(Math){ return -magicattacka*1.2;}",317);
		funMap.put("with(Math){ return maxhpa*0.22;}",318);
		funMap.put("with(Math){ return -(phyattacka*2-defendb+1*skilllevela);}",319);
		funMap.put("with(Math){ return -phyattacka;}",320);
		funMap.put("with(Math){ return -magicattacka*1.7;}",321);
		funMap.put("with(Math){ return -magicattacka*10;}",322);
		funMap.put("with(Math){ return magicattacka*10;}",323);
		funMap.put("with(Math){ return medicala+skilllevela*10;}",324);
		funMap.put("with(Math){ return medicala*2+skilllevela*10;}",325);
		funMap.put("with(Math){ return cons>=600;}",326);
		funMap.put("with(Math){ return -(maxhp*0.1+2*gradea);}",327);
		funMap.put("with(Math){ return cons>=300;}",328);
		funMap.put("with(Math){ return (cons*2+3*gradea);}",329);
		funMap.put("with(Math){ return (cons*5+10*gradea);}",330);
		funMap.put("with(Math){ return (agi*0.5+3*gradea);}",331);
		funMap.put("with(Math){ return agi>=600;}",332);
		funMap.put("with(Math){ return -(magicattacka*2.2-magicdefb+2*gradea+max((magicattacka-magicattackb)*0.3,0));}",333);
		funMap.put("with(Math){ return abs(maindamage*0.2);}",334);
		funMap.put("with(Math){ return -speeda*0.5;}",335);
		funMap.put("with(Math){ return -magicattacka*0.1;}",336);
		funMap.put("with(Math){ return -speeda*2;}",337);
		funMap.put("with(Math){ return gradea*1.3;}",338);
		funMap.put("with(Math){ return phyattackb*0.1;}",339);
		funMap.put("with(Math){ return -(phyattacka*1-defendb+1*gradea)*0.5;}",340);
		funMap.put("with(Math){ return -(phyattacka*1-defendb+1*gradea)*0.9;}",341);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+1.5*gradea)*1.3;}",342);
		funMap.put("with(Math){ return -(phyattacka*1-defendb+1*gradea)*0.8;}",343);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+1.5*gradea)*1.2;}",344);
		funMap.put("with(Math){ return -magicattacka*0.7;}",345);
		funMap.put("with(Math){ return -min(0.1*curhpb,20*skilllevela);}",346);
		funMap.put("with(Math){ return -min(0.05*curmpb,10*skilllevela);}",347);
		funMap.put("with(Math){ return -(magicattacka*2-magicdefb+2*skilllevela)*0.5;}",348);
		funMap.put("with(Math){ return abs(maindamage*0.5);}",349);
		funMap.put("with(Math){ return -0.7*skilllevela;}",350);
		funMap.put("with(Math){ return -1*skilllevela;}",351);
		funMap.put("with(Math){ return (((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16)*0.6;}",352);
		funMap.put("with(Math){ return (((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16)*0.5;}",353);
		funMap.put("with(Math){ return (((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16)*0.4;}",354);
		funMap.put("with(Math){ return (((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16)*0.3;}",355);
		funMap.put("with(Math){ return (((sealhita>=unsealb)?(0.98-0.32*pow(0.95,(sealhita/10-unsealb/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)):(0.66*pow(0.9,(unsealb/10-sealhita/10))+(enhanceseala-resistsealb)+(kongzhijiachenga/1000-kongzhimianyib/1000)))-0.16)*0.2;}",356);
		funMap.put("with(Math){ return abs(maindamage)*0.30;}",357);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+2*skilllevela)*0.25;}",358);
		funMap.put("with(Math){ return -(magicattacka*1.5-magicdefb+2*skilllevela)*0.1;}",359);
		funMap.put("with(Math){ return magicattacka*0.1;}",360);
		funMap.put("with(Math){ return gradea*1.1;}",361);
		funMap.put("with(Math){ return gradea*2.3;}",362);
		funMap.put("with(Math){ return -(magicattacka*2.5-magicdefb+2*gradea)*0.5;}",363);
		funMap.put("with(Math){ return effectpointa>=1;}",364);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*160;}",365);
		funMap.put("with(Math){ return (1000*RoleLv*0.377*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",366);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*120;}",367);
		funMap.put("with(Math){ return (1000*RoleLv*0.5)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",368);
		funMap.put("with(Math){ return (1000*MonsterLv*0.019*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*IsDbPoint)*(random()*(1.02-0.98)+0.98);}",369);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*150;}",370);
		funMap.put("with(Math){ return (1000*RoleLv*0.5)*(random()*(1.02-0.98)+0.98);}",371);
		funMap.put("with(Math){ return (1000*RoleLv*0.1*(0.78+0.04*Ring))*(random()*(1.02-0.98)+0.98);}",372);
		funMap.put("with(Math){ return (1000*RoleLv*0.232*2)*(random()*(1.02-0.98)+0.98);}",373);
		funMap.put("with(Math){ return (1000*RoleLv*0.2)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",374);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*100;}",375);
		funMap.put("with(Math){ return 100*1;}",376);
		funMap.put("with(Math){ return (1000*RoleLv*0.377*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1))*0.5)*(random()*(1.02-0.98)+0.98);}",377);
		funMap.put("with(Math){ return (1+14*IsDbPoint+IsSerMul)*(StdMoney*1.5/74*(14*0.09+1))*(random()*(1.2-0.8)+0.8);}",378);
		funMap.put("with(Math){ return (1000*min(max(RoleLv,FuBenLv),FuBenLv+9)*0.2*(0.7+0.1*Ring))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",379);
		funMap.put("with(Math){ return (1000*RoleLv*0.232*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1))*0.5)*(random()*(1.02-0.98)+0.98);}",380);
		funMap.put("with(Math){ return (1000*RoleLv*0.232*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",381);
		funMap.put("with(Math){ return (1000*RoleLv*0.3)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",382);
		funMap.put("with(Math){ return (1000*RoleLv*0.215*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1))*0.5)*(random()*(1.02-0.98)+0.98);}",383);
		funMap.put("with(Math){ return (1000*min(max(RoleLv,FuBenLv),FuBenLv+9)*0.1*(0.7+0.1*Ring))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",384);
		funMap.put("with(Math){ return (1000*RoleLv*0.377*3)*(random()*(1.02-0.98)+0.98);}",385);
		funMap.put("with(Math){ return 3000+5000*random();}",386);
		funMap.put("with(Math){ return (1000*RoleLv*0.215*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",387);
		funMap.put("with(Math){ return (1000*TeamLv*0.075*(1-IsDbPoint)+1000*TeamLv*0.12*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",388);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*140;}",389);
		funMap.put("with(Math){ return (1000*MonsterLv*0.1)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",390);
		funMap.put("with(Math){ return (1000*RoleLv*0.4)*(random()*(1.02-0.98)+0.98);}",391);
		funMap.put("with(Math){ return (1000*TeamLv*0.038*(0.78+0.04*Ring)*(1-IsDbPoint)+1000*TeamLv*0.098*(0.78+0.04*Ring)*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",392);
		funMap.put("with(Math){ return 500*RoleLv;}",393);
		funMap.put("with(Math){ return 1000*RoleLv*0.194*(0.85+0.03*((Time-1)%9+1))*(0.9+0.1*(floor((Time-1)/9)+1))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",394);
		funMap.put("with(Math){ return (1000*RoleLv*0.4)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",395);
		funMap.put("with(Math){ return 200*RoleLv;}",396);
		funMap.put("with(Math){ return RoleLv*10;}",397);
		funMap.put("with(Math){ return (1000*RoleLv*0.1)*(random()*(1.02-0.98)+0.98)*0.5;}",398);
		funMap.put("with(Math){ return (StdMoney*3.15/8*((Ring-1)*0.3+1))*(random()*(1.05-0.95)+0.95);}",399);
		funMap.put("with(Math){ return (StdMoney*4.2/8*((Ring-1)*0.3+1))*(random()*(1.05-0.95)+0.95);}",400);
		funMap.put("with(Math){ return (1000*RoleLv*0.194*2)*(random()*(1.02-0.98)+0.98);}",401);
		funMap.put("with(Math){ return (1000*RoleLv*0.1*(0.79+0.02*AnswerCnt))*(random()*(1.02-0.98)+0.98);}",402);
		funMap.put("with(Math){ return StdMoney*0.4*((Ring-1)*0.09+1);}",403);
		funMap.put("with(Math){ return (StdMoney*2/15)*(random()*(1.05-0.95)+0.95);}",404);
		funMap.put("with(Math){ return (StdMoney*2/10)*(random()*(1.05-0.95)+0.95);}",405);
		funMap.put("with(Math){ return (1000*RoleLv*0.05*(0.79+0.02*AnswerCnt))*0.5*(random()*(1.02-0.98)+0.98);}",406);
		funMap.put("with(Math){ return 1000*min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)*0.35*(0.75+0.05*Saveid)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",407);
		funMap.put("with(Math){ return (1000*RoleLv*0.1)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",408);
		funMap.put("with(Math){ return (1000*RoleLv*0.2*(0.78+0.04*Ring))*(random()*(1.02-0.98)+0.98);}",409);
		funMap.put("with(Math){ return (StdMoney*2/5)*(random()*(1.05-0.95)+0.95);}",410);
		funMap.put("with(Math){ return (StdMoney*6/10)*(random()*(1.05-0.95)+0.95);}",411);
		funMap.put("with(Math){ return 1000*RoleLv*0.067*(0.74+0.02*Time)*(random()*(1.02-0.98)+0.98);}",412);
		funMap.put("with(Math){ return (15+random()*5)*RoleLv;}",413);
		funMap.put("with(Math){ return 100*RoleLv;}",414);
		funMap.put("with(Math){ return 9.5*RoleLv;}",415);
		funMap.put("with(Math){ return (1000*RoleLv*0.194*1.5)*(random()*(1.02-0.98)+0.98);}",416);
		funMap.put("with(Math){ return (1000*RoleLv*0.1*(0.89+0.02*AnswerCnt))*(random()*(1.02-0.98)+0.98);}",417);
		funMap.put("with(Math){ return 1000*min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)*0.35*(0.5+0.1*Saveid)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",418);
		funMap.put("with(Math){ return (1000*RoleLv*0.215*2)*(random()*(1.02-0.98)+0.98);}",419);
		funMap.put("with(Math){ return 1600*RoleLv*0.067*(0.74+0.02*Time)*(random()*(1.02-0.98)+0.98);}",420);
		funMap.put("with(Math){ return (1000*RoleLv*0.194*1)*(random()*(1.02-0.98)+0.98);}",421);
		funMap.put("with(Math){ return RoleLv*50;}",422);
		funMap.put("with(Math){ return (1000*RoleLv*0.1*(0.89+0.02*AnswerCnt))*0.5*(random()*(1.02-0.98)+0.98);}",423);
		funMap.put("with(Math){ return 5000*RoleLv;}",424);
		funMap.put("with(Math){ return (1000*RoleLv*0.1*(0.79+0.02*AnswerCnt))*0.5*(random()*(1.02-0.98)+0.98);}",425);
		funMap.put("with(Math){ return (StdMoney*2)*(random()*(1.05-0.95)+0.95);}",426);
		funMap.put("with(Math){ return 250*RoleLv*(random()*(1.02-0.98)+0.98);}",427);
		funMap.put("with(Math){ return (StdMoney*6/28.1*((Ring-1)*0.09+1))*(random()*(1.05-0.95)+0.95);}",428);
		funMap.put("with(Math){ return (1+14*IsDbPoint+IsSerMul)*(StdMoney*1.5/74*((Ring-1)*0.09+1))*(random()*(1.2-0.8)+0.8);}",429);
		funMap.put("with(Math){ return 4000+6000*random();}",430);
		funMap.put("with(Math){ return (1000*RoleLv*0.05*(0.79+0.02*AnswerCnt))*(random()*(1.02-0.98)+0.98);}",431);
		funMap.put("with(Math){ return (1*min(max(RoleLv,FuBenLv),FuBenLv+9)*5)*(random()*(1.02-0.98)+0.98);}",432);
		funMap.put("with(Math){ return (1*RoleLv*10)*(random()*(1.02-0.98)+0.98);}",433);
		funMap.put("with(Math){ return (1*RoleLv*1.256*2)*(random()*(1.02-0.98)+0.98);}",434);
		funMap.put("with(Math){ return (1*RoleLv*0.717*2*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",435);
		funMap.put("with(Math){ return (1*RoleLv*0.775*2*2)*(random()*(1.02-0.98)+0.98);}",436);
		funMap.put("with(Math){ return (1*RoleLv*6.66)*(random()*(1.02-0.98)+0.98);}",437);
		funMap.put("with(Math){ return RoleLv*1.7+20;}",438);
		funMap.put("with(Math){ return (1*min(max(RoleLv,FuBenLv),FuBenLv+9)*5)*(random()*(2.02-0.98)+0.98);}",439);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*2;}",440);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*5;}",441);
		funMap.put("with(Math){ return RoleLv*5;}",442);
		funMap.put("with(Math){ return (1*RoleLv*0.717*2)*(random()*(1.02-0.98)+0.98);}",443);
		funMap.put("with(Math){ return MonsterLv+20;}",444);
		funMap.put("with(Math){ return (1*TeamLv*0.196*(0.78+0.04*Ring)*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",445);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*3;}",446);
		funMap.put("with(Math){ return (1*RoleLv*0.94)*(random()*(1.02-0.98)+0.98);}",447);
		funMap.put("with(Math){ return (1*RoleLv*0.775*2*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",448);
		funMap.put("with(Math){ return (1*RoleLv*1.3)*(random()*(1.02-0.98)+0.98);}",449);
		funMap.put("with(Math){ return (1*RoleLv*1.256*2*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",450);
		funMap.put("with(Math){ return 1*RoleLv*0.667*2*(3.5+0.5*(floor((Time-1)/5)+1))*floor(1-(Time%5)*0.2)*(random()*(1.02-0.98)+0.98);}",451);
		funMap.put("with(Math){ return (MonsterLv-30)*0.2+4;}",452);
		funMap.put("with(Math){ return (1*RoleLv*0.775*2)*(random()*(1.02-0.98)+0.98);}",453);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*4;}",454);
		funMap.put("with(Math){ return (1*RoleLv*11)*(random()*(1.02-0.98)+0.98);}",455);
		funMap.put("with(Math){ return (1*RoleLv*2)*(random()*(1.02-0.98)+0.98);}",456);
		funMap.put("with(Math){ return (15)+(TeamNum-1)*15+RoleLv*1;}",457);
		funMap.put("with(Math){ return (1*RoleLv*1)*(random()*(1.02-0.98)+0.98);}",458);
		funMap.put("with(Math){ return (1*RoleLv*1.256*2*2)*(random()*(1.02-0.98)+0.98);}",459);
		funMap.put("with(Math){ return (IsDbPoint*(Ring-1)*1+6);}",460);
		funMap.put("with(Math){ return (1*RoleLv*4)*(random()*(1.02-0.98)+0.98);}",461);
		funMap.put("with(Math){ return (1*RoleLv*0.717*2*2)*(random()*(1.02-0.98)+0.98);}",462);
		funMap.put("with(Math){ return (1*RoleLv*5)*(random()*(1.02-0.98)+0.98);}",463);
		funMap.put("with(Math){ return (1*RoleLv*8)*(random()*(1.02-0.98)+0.98);}",464);
		funMap.put("with(Math){ return (1*RoleLv*1.333)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",465);
		funMap.put("with(Math){ return 2.5*RoleLv*(random()*(1.02-0.98)+0.98);}",466);
		funMap.put("with(Math){ return 2.22*RoleLv*(random()*(1.02-0.98)+0.98);}",467);
		funMap.put("with(Math){ return 3.4*RoleLv*(random()*(1.02-0.98)+0.98);}",468);
		funMap.put("with(Math){ return 1.38*RoleLv*(random()*(1.02-0.98)+0.98);}",469);
		funMap.put("with(Math){ return max(floor((Ring-4)/2),0);}",470);
		funMap.put("with(Math){ return (400*RoleLv*0.25*(0.89+0.02*AnswerCnt))*(random()*(1.02-0.98)+0.98);}",471);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+7*IsDbPoint+IsSerMul)*(StdExp*10/63*((Ring-1)*0.05+1));}",472);
		funMap.put("with(Math){ return (400*RoleLv*0.017)*(random()*(1.02-0.98)+0.98);}",473);
		funMap.put("with(Math){ return 2000*RoleLv;}",474);
		funMap.put("with(Math){ return (400*RoleLv*0.667)*(random()*(1.02-0.98)+0.98)*0.5;}",475);
		funMap.put("with(Math){ return (400*RoleLv*1.099*3)*(random()*(1.02-0.98)+0.98);}",476);
		funMap.put("with(Math){ return (1+IsSerMul)*(StdExp*5);}",477);
		funMap.put("with(Math){ return (1+IsSerMul)*(StdExp*13.333/28.867*((Ring-1)*0.08+1)+RoleLv*50-1000);}",478);
		funMap.put("with(Math){ return (400*RoleLv*0.5*(0.79+0.02*AnswerCnt))*0.5*(random()*(1.02-0.98)+0.98);}",479);
		funMap.put("with(Math){ return (400*TeamLv*0.3*(1-IsDbPoint)+400*TeamLv*1.244*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",480);
		funMap.put("with(Math){ return (400*RoleLv*0.678*2)*(random()*(1.02-0.98)+0.98);}",481);
		funMap.put("with(Math){ return (8000*RoleLv*1.8)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",482);
		funMap.put("with(Math){ return (StdExp*13.333/28.867*((Ring-1)*0.08+1)+RoleLv*50-1000);}",483);
		funMap.put("with(Math){ return (400*RoleLv*0.278*(0.78+0.04*Ring))*(random()*(1.02-0.98)+0.98);}",484);
		funMap.put("with(Math){ return 400*RoleLv*0.875*(0.91+0.02*((Ring-1)%8+1))*(0.58+0.04*(floor((Ring-1)/8)+1));}",485);
		funMap.put("with(Math){ return 4000*RoleLv;}",486);
		funMap.put("with(Math){ return (400*MonsterLv*0.011*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*(1-IsDbPoint)+400*MonsterLv*0.13*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*IsDbPoint)*(random()*(1.02-0.98)+0.98);}",487);
		funMap.put("with(Math){ return (400*RoleLv*1.099*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1))*0.5)*(random()*(1.02-0.98)+0.98);}",488);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+IsSerMul)*(StdExp*6.6667/8*((Ring-1)*0.3+1));}",489);
		funMap.put("with(Math){ return (175+random()*50)*RoleLv;}",490);
		funMap.put("with(Math){ return 400*RoleLv*1.215*(0.88+0.03);}",491);
		funMap.put("with(Math){ return (400*RoleLv*0.5)*(random()*(1.02-0.98)+0.98);}",492);
		funMap.put("with(Math){ return 500*RoleLv*1.215*(0.88+0.03);}",493);
		funMap.put("with(Math){ return (400*RoleLv*0.628*2)*(random()*(1.02-0.98)+0.98);}",494);
		funMap.put("with(Math){ return StdExp*0.83/14.5*((Ring-1)*0.1+1);}",495);
		funMap.put("with(Math){ return StdExp*7*2.86/168*8;}",496);
		funMap.put("with(Math){ return (400*RoleLv*1.25)*(random()*(1.02-0.98)+0.98);}",497);
		funMap.put("with(Math){ return 400*min(RoleLv,94)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",498);
		funMap.put("with(Math){ return (400*RoleLv*0.833)*(random()*(1.02-0.98)+0.98);}",499);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+IsSerMul)*(StdExp*6.7/5);}",500);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+IsSerMul)*(StdExp*6.7/10)*((TeamNum-1)*0.05+1);}",501);
		funMap.put("with(Math){ return 400*RoleLv*1*(0.74+0.02*Time)*(random()*(1.02-0.98)+0.98);}",502);
		funMap.put("with(Math){ return (400*RoleLv*0.678*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",503);
		funMap.put("with(Math){ return (400*RoleLv*0.628*0.6);}",504);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+IsSerMul)*(StdExp*2.14*7/8*((Ring-1)*0.3+1));}",505);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+IsSerMul)*(StdExp*6.7);}",506);
		funMap.put("with(Math){ return 400*min(RoleLv,74)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",507);
		funMap.put("with(Math){ return (400*RoleLv*0.678*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1))*0.5)*(random()*(1.02-0.98)+0.98);}",508);
		funMap.put("with(Math){ return (1+IsSerMul)*(StdExp*0.83/14.5*((Ring-1)*0.1+1));}",509);
		funMap.put("with(Math){ return 400*RoleLv*0.656*(0.82+0.04*((Ring-1)%8+1))*(0.58+0.04*(floor((Ring-1)/8)+1));}",510);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+IsSerMul)*(StdExp*6.7/15);}",511);
		funMap.put("with(Math){ return (1000*TeamLv*0.15*(0.78+0.04*Ring)*(1-IsDbPoint)+400*TeamLv*1.02*(0.78+0.04*Ring)*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(2+0.05*IsTL);}",512);
		funMap.put("with(Math){ return (400*RoleLv*1.099*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",513);
		funMap.put("with(Math){ return (400*RoleLv*0.628*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1)))*(random()*(1.02-0.98)+0.98);}",514);
		funMap.put("with(Math){ return (400*RoleLv*0.628*(0.95+0.05*(PVPCnt+1))*(0.95+0.05*(PVPTargetCnt+1))*0.5)*(random()*(1.02-0.98)+0.98);}",515);
		funMap.put("with(Math){ return (400*TeamLv*0.15*(0.78+0.04*Ring)*(1-IsDbPoint)+400*TeamLv*1.02*(0.78+0.04*Ring)*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",516);
		funMap.put("with(Math){ return 400*min(RoleLv,59)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",517);
		funMap.put("with(Math){ return (400*RoleLv*0.694*(0.78+0.04*Ring))*(random()*(1.02-0.98)+0.98);}",518);
		funMap.put("with(Math){ return (400*RoleLv*1)*(random()*(1.02-0.98)+0.98);}",519);
		funMap.put("with(Math){ return 400*min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)*0.35*(0.5+0.1*Saveid)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",520);
		funMap.put("with(Math){ return (1+IsSerMul)*(StdExp*0.2);}",521);
		funMap.put("with(Math){ return RoleLv*200;}",522);
		funMap.put("with(Math){ return (400*RoleLv*0.7)*(random()*(1.02-0.98)+0.98);}",523);
		funMap.put("with(Math){ return (400*RoleLv*1.215*1)*(random()*(1.02-0.98)+0.98);}",524);
		funMap.put("with(Math){ return RoleLv*100;}",525);
		funMap.put("with(Math){ return 400*RoleLv*1.215*(0.85+0.03*((Time-1)%9+1))*(0.9+0.1*(floor((Time-1)/9)+1))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",526);
		funMap.put("with(Math){ return (500*TeamLv*0.15*(0.78+0.04*Ring)*(1-IsDbPoint)+400*TeamLv*1.02*(0.78+0.04*Ring)*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",527);
		funMap.put("with(Math){ return (400*RoleLv*1.099*0.6);}",528);
		funMap.put("with(Math){ return (400*RoleLv*2.5)*(random()*(1.02-0.98)+0.98);}",529);
		funMap.put("with(Math){ return (400*min(max(RoleLv,FuBenLv),FuBenLv+9)*2*(0.7+0.1*Ring))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",530);
		funMap.put("with(Math){ return 400*min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)*0.35*(0.75+0.05*Saveid)*(random()*(1.02-0.98)+0.98);}",531);
		funMap.put("with(Math){ return 400*min(RoleLv,49)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",532);
		funMap.put("with(Math){ return 400*min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)*0.35*(0.75+0.05*Saveid)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",533);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+IsSerMul)*(StdExp*6);}",534);
		funMap.put("with(Math){ return (400*RoleLv*0.25*(0.89+0.02*AnswerCnt))*0.5*(random()*(1.02-0.98)+0.98);}",535);
		funMap.put("with(Math){ return 400*min(RoleLv,84)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",536);
		funMap.put("with(Math){ return (400*RoleLv*0.25*(0.79+0.02*AnswerCnt))*(random()*(1.02-0.98)+0.98);}",537);
		funMap.put("with(Math){ return 400*min(RoleLv,89)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",538);
		funMap.put("with(Math){ return (105+random()*30)*RoleLv;}",539);
		funMap.put("with(Math){ return 400*min(RoleLv,99)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",540);
		funMap.put("with(Math){ return 3000*RoleLv;}",541);
		funMap.put("with(Math){ return 400*min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)*0.0392*(0.4+0.1*Saveid);}",542);
		funMap.put("with(Math){ return (400*RoleLv*1.215*2)*(random()*(1.02-0.98)+0.98);}",543);
		funMap.put("with(Math){ return (400*MonsterLv*0.017*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*(1-IsDbPoint)+400*MonsterLv*0.13*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*IsDbPoint)*(random()*(1.02-0.98)+0.98);}",544);
		funMap.put("with(Math){ return (7000*RoleLv*1.8)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",545);
		funMap.put("with(Math){ return (400*RoleLv*1.215*1.5)*(random()*(1.02-0.98)+0.98);}",546);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+7*IsDbPoint+IsSerMul)*(StdExp*10/63*(14*0.05+1));}",547);
		funMap.put("with(Math){ return StdExp*5/10*(random()*(1.2-0.8)+0.8);}",548);
		funMap.put("with(Math){ return (400*min(max(RoleLv,FuBenLv),FuBenLv+9)*1*(0.7+0.1*Ring))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",549);
		funMap.put("with(Math){ return 400*min(RoleLv,79)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",550);
		funMap.put("with(Math){ return (400*RoleLv*0.5*(0.79+0.02*AnswerCnt))*(random()*(1.02-0.98)+0.98);}",551);
		funMap.put("with(Math){ return (7500*RoleLv*1.8)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",552);
		funMap.put("with(Math){ return (400*RoleLv*0.678*0.6);}",553);
		funMap.put("with(Math){ return (400*RoleLv*0.25*(0.79+0.02*AnswerCnt))*0.5*(random()*(1.02-0.98)+0.98);}",554);
		funMap.put("with(Math){ return (1000*RoleLv*1.8)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",555);
		funMap.put("with(Math){ return (400*RoleLv*2.222)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",556);
		funMap.put("with(Math){ return 400*min(RoleLv,69)*0.35*(0.75+0.05*10)*(random()*(1.02-0.98)+0.98);}",557);
		funMap.put("with(Math){ return Ring+1;}",558);
		funMap.put("with(Math){ return Ring+5;}",559);
		funMap.put("with(Math){ return 2200+floor(min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)/10)*440+(200+floor(min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)/10)*40*Saveid);}",560);
		funMap.put("with(Math){ return 2200+floor(RoleLv/10)*440+(200+floor(RoleLv/10)*40*(Ring-1));}",561);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,74)/10)*440+(200+floor(min(RoleLv,74)/10)*40*10))*2;}",562);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,84)/10)*440+(200+floor(min(RoleLv,84)/10)*40*10))*2;}",563);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,99)/10)*440+(200+floor(min(RoleLv,99)/10)*40*10))*2;}",564);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)/10)*440+(200+floor(min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)/10)*40*Saveid))*2;}",565);
		funMap.put("with(Math){ return 105800+floor(RoleLv/10)*440+(200+floor(RoleLv/10)*40*(Ring-1));}",566);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,89)/10)*440+(200+floor(min(RoleLv,89)/10)*40*10))*2;}",567);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,79)/10)*440+(200+floor(min(RoleLv,79)/10)*40*10))*2;}",568);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,69)/10)*440+(200+floor(min(RoleLv,69)/10)*40*10))*2;}",569);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,49)/10)*440+(200+floor(min(RoleLv,49)/10)*40*10))*2;}",570);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,94)/10)*440+(200+floor(min(RoleLv,94)/10)*40*10))*2;}",571);
		funMap.put("with(Math){ return (2200+floor(min(RoleLv,59)/10)*440+(200+floor(min(RoleLv,59)/10)*40*10))*2;}",572);
		funMap.put("with(Math){ return SwXs*1;}",573);
		funMap.put("with(Math){ return (5000*RoleLv*0.05)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",574);
		funMap.put("with(Math){ return (5000*min(max(RoleLv,FuBenLv),FuBenLv+9)*0.2*(0.7+0.1*Ring))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",575);
		funMap.put("with(Math){ return (5000*MonsterLv*0.05)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",576);
		funMap.put("with(Math){ return (5000*TeamLv*0.05*(1-IsDbPoint)+5000*TeamLv*0.124*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",577);
		funMap.put("with(Math){ return (5000*RoleLv*0.049*1.5)*(random()*(1.02-0.98)+0.98);}",578);
		funMap.put("with(Math){ return (5000*RoleLv*0.1)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",579);
		funMap.put("with(Math){ return (5000*RoleLv*0.05*(0.78+0.04*Ring))*(random()*(1.02-0.98)+0.98);}",580);
		funMap.put("with(Math){ return (1+IsSerMul)*(5000*RoleLv*0.5/20);}",581);
		funMap.put("with(Math){ return (5000*RoleLv*0.05)*(random()*(1.02-0.98)+0.98)*0.5;}",582);
		funMap.put("with(Math){ return (1+0.05*IsTL)*(1+1.5*IsDbPoint+IsSerMul)*(5000*RoleLv*1.25/50);}",583);
		funMap.put("with(Math){ return (5000*min(max(RoleLv,FuBenLv),FuBenLv+9)*0.1*(0.7+0.1*Ring))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",584);
		funMap.put("with(Math){ return (5000*MonsterLv*0.011*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*(1-IsDbPoint)+5000*MonsterLv*0.02*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*IsDbPoint)*(random()*(1.02-0.98)+0.98);}",585);
		funMap.put("with(Math){ return 5000*RoleLv*0.1*(0.74+0.02*Time)*(random()*(1.02-0.98)+0.98);}",586);
		funMap.put("with(Math){ return 5000*min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)*0.058*(0.5+0.1*Saveid)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",587);
		funMap.put("with(Math){ return (5000*RoleLv*0.111)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",588);
		funMap.put("with(Math){ return (5000*TeamLv*0.025*(0.78+0.04*Ring)*(1-IsDbPoint)+5000*TeamLv*0.102*(0.78+0.04*Ring)*IsDbPoint)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15)*(1+0.05*IsTL);}",589);
		funMap.put("with(Math){ return RoleLv*100*30/5;}",590);
		funMap.put("with(Math){ return (5000*MonsterLv*0.017*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*(1-IsDbPoint)+5000*MonsterLv*0.02*(MonsterNum*0.083+MasterNum*0.1245)*min(max(1-0.2*floor(abs(MonsterLv-RoleLv)/5),0.1),1)*IsDbPoint)*(random()*(1.02-0.98)+0.98);}",591);
		funMap.put("with(Math){ return 5000*min(RoleLv,FuBenId*10-1051-floor(FuBenId/113)*5)*0.058*(0.75+0.05*Saveid)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",592);
		funMap.put("with(Math){ return (5000*RoleLv*0.1)*(random()*(1.02-0.98)+0.98);}",593);
		funMap.put("with(Math){ return (5000*RoleLv*0.15)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",594);
		funMap.put("with(Math){ return (5000*RoleLv*0.075)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",595);
		funMap.put("with(Math){ return (500*RoleLv*0.05)*(random()*(1.02-0.98)+0.98)*0.5;}",596);
		funMap.put("with(Math){ return 5000*RoleLv*0.049*(0.85+0.03*((Time-1)%9+1))*(0.9+0.1*(floor((Time-1)/9)+1))*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",597);
		funMap.put("with(Math){ return (5000*RoleLv*0.049*1)*(random()*(1.02-0.98)+0.98);}",598);
		funMap.put("with(Math){ return (5000*RoleLv*0.125)*(random()*(1.02-0.98)+0.98)*(1-min(5-TeamNum,2)*0.15);}",599);
		funMap.put("with(Math){ return (5000*RoleLv*0.049*2)*(random()*(1.02-0.98)+0.98);}",600);
		funMap.put("with(Math){ return min(max(rolenum*0.004,8),16);}",601);
		funMap.put("with(Math){ return min(max(rolenum*0.001,2),4)+(ServerLv-50)*0.2;}",602);
		funMap.put("with(Math){ return floor((min(max(floor((ServerLv-40)*0.2),0),4)*3+6)*min(max(rolenum*0.0005,1),2));}",603);
		funMap.put("with(Math){ return null;}",604);
		funMap.put("with(Math){ return floor((min(max(floor((ServerLv-50)*0.2),0),3)*2+3)*min(max(rolenum*0.0005,1),2));}",605);
		funMap.put("with(Math){ return _94023_>=1;}",606);
		funMap.put("with(Math){ return _94024_>=1;}",607);
		funMap.put("with(Math){ return _94029_>=1;}",608);
		funMap.put("with(Math){ return _94033_>=2;}",609);
		funMap.put("with(Math){ return _94034_<1;}",610);
		funMap.put("with(Math){ return _94046_<1&&_94045_>=3;}",611);
		funMap.put("with(Math){ return _94031_>=3;}",612);
		funMap.put("with(Math){ return _94035_>=1;}",613);
		funMap.put("with(Math){ return _94027_>=1&&_94053_<1;}",614);
		funMap.put("with(Math){ return _94036_>=2;}",615);
		funMap.put("with(Math){ return _94040_<1;}",616);
		funMap.put("with(Math){ return _94039_>=1;}",617);
		funMap.put("with(Math){ return _94038_>=2||_94028_>=1;}",618);
		funMap.put("with(Math){ return _94056_>=2;}",619);
		funMap.put("with(Math){ return _94054_>=1;}",620);
		funMap.put("with(Math){ return _94026_>=1;}",621);
		funMap.put("with(Math){ return _94001_>=1;}",622);
		funMap.put("with(Math){ return _94002_>=1;}",623);
		funMap.put("with(Math){ return _94003_>=1;}",624);
		funMap.put("with(Math){ return _94004_>=1;}",625);
		funMap.put("with(Math){ return _94005_>=5;}",626);
		funMap.put("with(Math){ return _94005_>=3;}",627);
		funMap.put("with(Math){ return _94005_>=1;}",628);
		funMap.put("with(Math){ return _94006_<3;}",629);
		funMap.put("with(Math){ return _94007_>=2&&_94011_>=1;}",630);
		funMap.put("with(Math){ return _94007_>=2;}",631);
		funMap.put("with(Math){ return _94008_>=1;}",632);
		funMap.put("with(Math){ return _94009_<1;}",633);
		funMap.put("with(Math){ return _94012_>=2;}",634);
		funMap.put("with(Math){ return _94013_>=1;}",635);
		funMap.put("with(Math){ return _94016_>=1;}",636);
		funMap.put("with(Math){ return _94014_>=1;}",637);
		funMap.put("with(Math){ return _94015_>=1;}",638);
		funMap.put("with(Math){ return _94017_<1;}",639);
		funMap.put("with(Math){ return _94006_<3&&_94005_>=1;}",640);
		funMap.put("with(Math){ return _94003_>=1&&_94006_>=3;}",641);
		funMap.put("with(Math){ return _94003_>=1&&_94006_<3;}",642);
		funMap.put("with(Math){ return _94019_<1;}",643);
		funMap.put("with(Math){ return effectpointa>=0;}",644);
		funMap.put("with(Math){ return _94020_>=1;}",645);
		funMap.put("with(Math){ return _94021_>=1;}",646);
		funMap.put("with(Math){ return _94022_>=1;}",647);
		funMap.put("with(Math){ return _94025_>=1&&_99075_>=1;}",648);
		funMap.put("with(Math){ return _94026_>=1&&_99075_>=1;}",649);
		funMap.put("with(Math){ return _99076_>=1&&_99075_>=1;}",650);
		funMap.put("with(Math){ return _94025_>=1&&_94030_>=3;}",651);
		funMap.put("with(Math){ return _94025_>=1&&_94030_==2;}",652);
		funMap.put("with(Math){ return _94025_>=1&&_94030_==1;}",653);
		funMap.put("with(Math){ return _99076_>=1;}",654);
		funMap.put("with(Math){ return _94030_>=3;}",655);
		funMap.put("with(Math){ return _94030_==2&&_94029_>=1;}",656);
		funMap.put("with(Math){ return _94030_==2;}",657);
		funMap.put("with(Math){ return _94030_==1;}",658);
		funMap.put("with(Math){ return _94044_>=1&&_94057_<1;}",659);
		funMap.put("with(Math){ return _94044_>=1&&_94057_>=1;}",660);
		funMap.put("with(Math){ return _94037_>=1;}",661);
		funMap.put("with(Math){ return _94038_>=2;}",662);
		funMap.put("with(Math){ return _94028_>=1;}",663);
		funMap.put("with(Math){ return effectpointa<1;}",664);
		funMap.put("with(Math){ return _99065_>=4;}",665);
		funMap.put("with(Math){ return _94044_>=1;}",666);
		funMap.put("with(Math){ return _95001_>=1;}",667);
		funMap.put("with(Math){ return _95002_==1;}",668);
		funMap.put("with(Math){ return _95009_==1;}",669);
		funMap.put("with(Math){ return _95013_==1;}",670);
		funMap.put("with(Math){ return _95010_>=1;}",671);
		funMap.put("with(Math){ return _95003_<=1;}",672);
		funMap.put("with(Math){ return _95017_==1;}",673);
		funMap.put("with(Math){ return _95018_<=1;}",674);
		funMap.put("with(Math){ return _95020_==1;}",675);
		funMap.put("with(Math){ return _95021_==1;}",676);
		funMap.put("with(Math){ return _95024_<=0;}",677);
		funMap.put("with(Math){ return _95028_==1;}",678);
		funMap.put("with(Math){ return _95025_==1;}",679);
		funMap.put("with(Math){ return _95030_>=1;}",680);
		funMap.put("with(Math){ return _95035_>=1;}",681);
		funMap.put("with(Math){ return _95036_>=1;}",682);
		funMap.put("with(Math){ return _95039_<1;}",683);
		funMap.put("with(Math){ return _95038_>=1;}",684);
		funMap.put("with(Math){ return _95037_>=2||_95040_>=1;}",685);
		funMap.put("with(Math){ return _95041_>=2;}",686);
		funMap.put("with(Math){ return _95042_>=1;}",687);
		funMap.put("with(Math){ return _95043_>=3;}",688);
		funMap.put("with(Math){ return _95044_>=1;}",689);
		funMap.put("with(Math){ return _95045_>=1;}",690);
		funMap.put("with(Math){ return _95046_<=2;}",691);
		funMap.put("with(Math){ return _95047_>=2;}",692);
		funMap.put("with(Math){ return _95048_>=1;}",693);
		funMap.put("with(Math){ return _95049_>=2||_95054_>=1;}",694);
		funMap.put("with(Math){ return _95050_>=1;}",695);
		funMap.put("with(Math){ return _95051_>=2;}",696);
		funMap.put("with(Math){ return _95052_>=2;}",697);
		funMap.put("with(Math){ return _95053_==1;}",698);
		funMap.put("with(Math){ return _95041_>=3;}",699);
		funMap.put("with(Math){ return _95055_>=1;}",700);
		funMap.put("with(Math){ return _95058_>=1;}",701);
		funMap.put("with(Math){ return _95059_>=1;}",702);
		funMap.put("with(Math){ return _95052_>=1;}",703);
		funMap.put("with(Math){ return _95060_>=1;}",704);
		funMap.put("with(Math){ return _95018_==1;}",705);
		funMap.put("with(Math){ return _95057_==1;}",706);
		funMap.put("with(Math){ return _95062_==1;}",707);
		funMap.put("with(Math){ return _95073_==1;}",708);
		funMap.put("with(Math){ return _95063_==1;}",709);
		funMap.put("with(Math){ return _95057_<1;}",710);
		funMap.put("with(Math){ return _95064_>=2;}",711);
		funMap.put("with(Math){ return _95065_>=3;}",712);
		funMap.put("with(Math){ return _95074_==1;}",713);
		funMap.put("with(Math){ return _95075_==1;}",714);
		funMap.put("with(Math){ return _95076_==1;}",715);
		funMap.put("with(Math){ return _95046_<=1;}",716);
		funMap.put("with(Math){ return _95077_>=2;}",717);
		funMap.put("with(Math){ return _95078_<1;}",718);
		funMap.put("with(Math){ return _95080_==1;}",719);
		funMap.put("with(Math){ return _95079_<1;}",720);
		funMap.put("with(Math){ return _95081_<1;}",721);
		funMap.put("with(Math){ return _95082_>=2;}",722);
		funMap.put("with(Math){ return _95086_>=1;}",723);
		funMap.put("with(Math){ return _95083_==1;}",724);
		funMap.put("with(Math){ return _95084_<1;}",725);
		funMap.put("with(Math){ return _95085_>=2&&_95089_<1;}",726);
		funMap.put("with(Math){ return _95086_>=1&&_95087_<1;}",727);
		funMap.put("with(Math){ return _95082_>=3;}",728);
		funMap.put("with(Math){ return _95057_>=1;}",729);
		funMap.put("with(Math){ return _95088_<=0;}",730);
		funMap.put("with(Math){ return _96001_/_96002_>=0.2;}",731);
		funMap.put("with(Math){ return _96001_/_96002_<0.2;}",732);
		funMap.put("with(Math){ return _96004_>=4;}",733);
		funMap.put("with(Math){ return _96003_>=1;}",734);
		funMap.put("with(Math){ return _96124_<=0.01;}",735);
		funMap.put("with(Math){ return _96015_==1;}",736);
		funMap.put("with(Math){ return _96016_>=1||_96018_>=1;}",737);
		funMap.put("with(Math){ return _96016_<1&&_96018_<1;}",738);
		funMap.put("with(Math){ return _96017_<1;}",739);
		funMap.put("with(Math){ return _96107_>=1;}",740);
		funMap.put("with(Math){ return _96103_>=1;}",741);
		funMap.put("with(Math){ return _96108_>=1;}",742);
		funMap.put("with(Math){ return _96106_>=1;}",743);
		funMap.put("with(Math){ return _96104_>=1;}",744);
		funMap.put("with(Math){ return _96105_>=1;}",745);
		funMap.put("with(Math){ return _96109_>=1;}",746);
		funMap.put("with(Math){ return _96110_>=1;}",747);
		funMap.put("with(Math){ return _96111_>=1;}",748);
		funMap.put("with(Math){ return _96101_==1;}",749);
		funMap.put("with(Math){ return _96102_>=1;}",750);
		funMap.put("with(Math){ return _96113_<1;}",751);
		funMap.put("with(Math){ return _96120_>=1;}",752);
		funMap.put("with(Math){ return _96121_>=1;}",753);
		funMap.put("with(Math){ return _96122_<1;}",754);
		funMap.put("with(Math){ return _96123_>=1;}",755);
		funMap.put("with(Math){ return _99002_<1;}",756);
		funMap.put("with(Math){ return _96301_>=1;}",757);
		funMap.put("with(Math){ return _96302_>=1;}",758);
		funMap.put("with(Math){ return _96301_>=1&&_96307_<1;}",759);
		funMap.put("with(Math){ return _96301_>=1&&_96308_<1;}",760);
		funMap.put("with(Math){ return _96301_>=1&&_96309_<1;}",761);
		funMap.put("with(Math){ return _96301_>=1&&_96310_<1;}",762);
		funMap.put("with(Math){ return _96301_>=1&&_96311_<1;}",763);
		funMap.put("with(Math){ return _96301_>=1&&_96362_<1;}",764);
		funMap.put("with(Math){ return _96301_>=1&&_96363_<1;}",765);
		funMap.put("with(Math){ return _96301_>=1&&_96364_<1;}",766);
		funMap.put("with(Math){ return _96301_>=1&&_96365_<1;}",767);
		funMap.put("with(Math){ return _96301_>=1&&_96366_<1;}",768);
		funMap.put("with(Math){ return _96304_<1;}",769);
		funMap.put("with(Math){ return _96351_>=1;}",770);
		funMap.put("with(Math){ return _96352_>=1;}",771);
		funMap.put("with(Math){ return _96351_>=1&&_96357_<1;}",772);
		funMap.put("with(Math){ return _96351_>=1&&_96358_<1;}",773);
		funMap.put("with(Math){ return _96351_>=1&&_96359_<1;}",774);
		funMap.put("with(Math){ return _96351_>=1&&_96360_<1;}",775);
		funMap.put("with(Math){ return _96351_>=1&&_96361_<1;}",776);
		funMap.put("with(Math){ return _96351_>=1&&_96362_<1;}",777);
		funMap.put("with(Math){ return _96351_>=1&&_96363_<1;}",778);
		funMap.put("with(Math){ return _96351_>=1&&_96364_<1;}",779);
		funMap.put("with(Math){ return _96351_>=1&&_96365_<1;}",780);
		funMap.put("with(Math){ return _96351_>=1&&_96366_<1;}",781);
		funMap.put("with(Math){ return _96354_<1;}",782);
		funMap.put("with(Math){ return _96401_==1;}",783);
		funMap.put("with(Math){ return _96402_>=1||_96403_>=1;}",784);
		funMap.put("with(Math){ return _97001_/_97002_>=0.2;}",785);
		funMap.put("with(Math){ return _97001_/_97002_<0.2;}",786);
		funMap.put("with(Math){ return _97003_>=1;}",787);
		funMap.put("with(Math){ return _97004_>=4;}",788);
		funMap.put("with(Math){ return _97005_==1;}",789);
		funMap.put("with(Math){ return _96200_>=4;}",790);
		funMap.put("with(Math){ return _96201_>=4;}",791);
		funMap.put("with(Math){ return _96202_>=4;}",792);
		funMap.put("with(Math){ return _96203_>=4;}",793);
		funMap.put("with(Math){ return _96204_>=1;}",794);
		funMap.put("with(Math){ return _96205_>=1;}",795);
		funMap.put("with(Math){ return _96206_>=4;}",796);
		funMap.put("with(Math){ return _96207_>=4;}",797);
		funMap.put("with(Math){ return _96208_<3;}",798);
		funMap.put("with(Math){ return _96209_>=1;}",799);
		funMap.put("with(Math){ return _96210_<3;}",800);
		funMap.put("with(Math){ return _96211_>=1;}",801);
		funMap.put("with(Math){ return _96212_>=1;}",802);
		funMap.put("with(Math){ return _96213_>=3;}",803);
		funMap.put("with(Math){ return _96215_>=4;}",804);
		funMap.put("with(Math){ return _96216_<=3;}",805);
		funMap.put("with(Math){ return _96217_<3;}",806);
		funMap.put("with(Math){ return _96218_>=1;}",807);
		funMap.put("with(Math){ return _96125_>1;}",808);
		funMap.put("with(Math){ return _99001_<1;}",809);
		funMap.put("with(Math){ return _99001_<1&&_99030_==1;}",810);
		funMap.put("with(Math){ return _99001_<1&&_99004_==1;}",811);
		funMap.put("with(Math){ return _99003_>=1&&_96124_<=0.01;}",812);
		funMap.put("with(Math){ return _99031_>=1;}",813);
		funMap.put("with(Math){ return _99032_>=1;}",814);
		funMap.put("with(Math){ return _99033_>=1;}",815);
		funMap.put("with(Math){ return _99034_>=1;}",816);
		funMap.put("with(Math){ return _99001_<1&&_99010_>=1;}",817);
		funMap.put("with(Math){ return _99001_<1&&_99011_>=1;}",818);
		funMap.put("with(Math){ return _99001_<1&&_99012_>=1;}",819);
		funMap.put("with(Math){ return _99001_<1&&_99013_>=1;}",820);
		funMap.put("with(Math){ return _99001_<1&&_99014_>=1;}",821);
		funMap.put("with(Math){ return _99001_<1&&_99015_>=1;}",822);
		funMap.put("with(Math){ return _99001_<1&&_99016_>=1;}",823);
		funMap.put("with(Math){ return _99001_<1&&_99017_>=1;}",824);
		funMap.put("with(Math){ return _99001_<1&&_99018_>=1;}",825);
		funMap.put("with(Math){ return _99001_<1&&_99019_>=1;}",826);
		funMap.put("with(Math){ return _94056_>=1;}",827);
		funMap.put("with(Math){ return _99036_>=1;}",828);
		funMap.put("with(Math){ return _99037_>=1;}",829);
		funMap.put("with(Math){ return _99038_>=1;}",830);
		funMap.put("with(Math){ return _99039_>=1;}",831);
		funMap.put("with(Math){ return _94056_>=4;}",832);
		funMap.put("with(Math){ return _95003_<=2;}",833);
		funMap.put("with(Math){ return _95003_<=3;}",834);
		funMap.put("with(Math){ return _95003_<=4;}",835);
		funMap.put("with(Math){ return _95003_<=5;}",836);
		funMap.put("with(Math){ return _95003_<=6;}",837);
		funMap.put("with(Math){ return _95003_<=7;}",838);
		funMap.put("with(Math){ return _95003_<=8;}",839);
		funMap.put("with(Math){ return _95003_<=9;}",840);
		funMap.put("with(Math){ return _95003_<=10;}",841);
		funMap.put("with(Math){ return _96232_>=1;}",842);
		funMap.put("with(Math){ return _96234_>=1;}",843);
		funMap.put("with(Math){ return _95003_=3;}",844);
		funMap.put("with(Math){ return _97001_>=4;}",845);
		funMap.put("with(Math){ return _99040_>=2;}",846);
		funMap.put("with(Math){ return _95003_=4;}",847);
		funMap.put("with(Math){ return _95003_=5;}",848);
		funMap.put("with(Math){ return _95003_=6;}",849);
		funMap.put("with(Math){ return _95003_=7;}",850);
		funMap.put("with(Math){ return _95003_=8;}",851);
		funMap.put("with(Math){ return _95003_=9;}",852);
		funMap.put("with(Math){ return _99041_>=3;}",853);
		funMap.put("with(Math){ return _99042_>=3;}",854);
		funMap.put("with(Math){ return _99043_>=1;}",855);
		funMap.put("with(Math){ return _99044_<1;}",856);
		funMap.put("with(Math){ return _99045_<1;}",857);
		funMap.put("with(Math){ return _99047_>=1;}",858);
		funMap.put("with(Math){ return _99048_>=1;}",859);
		funMap.put("with(Math){ return _94056_>=3;}",860);
		funMap.put("with(Math){ return _99049_>=1;}",861);
		funMap.put("with(Math){ return _99052_>=1;}",862);
		funMap.put("with(Math){ return _94014_>=7;}",863);
		funMap.put("with(Math){ return _99053_>=1;}",864);
		funMap.put("with(Math){ return _99054_>=1;}",865);
		funMap.put("with(Math){ return _99055_>=1;}",866);
		funMap.put("with(Math){ return _99056_>=1;}",867);
		funMap.put("with(Math){ return _99057_>=1;}",868);
		funMap.put("with(Math){ return _99058_>=1;}",869);
		funMap.put("with(Math){ return _99059_>=1;}",870);
		funMap.put("with(Math){ return _99060_>=1;}",871);
		funMap.put("with(Math){ return _99061_>=1;}",872);
		funMap.put("with(Math){ return _99053_<1;}",873);
		funMap.put("with(Math){ return _99054_<1;}",874);
		funMap.put("with(Math){ return _99055_<1;}",875);
		funMap.put("with(Math){ return _99056_<1;}",876);
		funMap.put("with(Math){ return _99057_<1;}",877);
		funMap.put("with(Math){ return _99058_<1;}",878);
		funMap.put("with(Math){ return _99059_<1;}",879);
		funMap.put("with(Math){ return _99060_<1;}",880);
		funMap.put("with(Math){ return _99061_<1;}",881);
		funMap.put("with(Math){ return _96001_/_96002_<0.1;}",882);
		funMap.put("with(Math){ return _99062_>=1;}",883);
		funMap.put("with(Math){ return _99062_>=2;}",884);
		funMap.put("with(Math){ return _99062_>=3;}",885);
		funMap.put("with(Math){ return _99066_>=1;}",886);
		funMap.put("with(Math){ return _99067_>=1;}",887);
		funMap.put("with(Math){ return _99049_>=5;}",888);
		funMap.put("with(Math){ return _99068_>=1;}",889);
		funMap.put("with(Math){ return _99071_>=1;}",890);
		funMap.put("with(Math){ return _99070_==1;}",891);
		funMap.put("with(Math){ return _99072_<1;}",892);
		funMap.put("with(Math){ return _94041_>=1;}",893);
		funMap.put("with(Math){ return _99065_>=3;}",894);
		funMap.put("with(Math){ return _99074_>=1;}",895);
		funMap.put("with(Math){ return _96001_>=1;}",896);
		funMap.put("with(Math){ return _99077_>=1;}",897);
		funMap.put("with(Math){ return _99078_>=1;}",898);
		funMap.put("with(Math){ return _502002_;}",899);
		funMap.put("with(Math){ return _502003_;}",900);
		funMap.put("with(Math){ return !_13_;}",901);
		funMap.put("with(Math){ return _509082_||_509083_;}",902);
		funMap.put("with(Math){ return _504002_;}",903);
		funMap.put("with(Math){ return !_504002_;}",904);
		funMap.put("with(Math){ return !_120_;}",905);
		funMap.put("with(Math){ return _120_;}",906);
		funMap.put("with(Math){ return _500033_;}",907);
		funMap.put("with(Math){ return _506003_;}",908);
		funMap.put("with(Math){ return !_506003_;}",909);
		funMap.put("with(Math){ return _501901_;}",910);
		funMap.put("with(Math){ return _502003_||_506002_;}",911);
		funMap.put("with(Math){ return _505005_||_504011_;}",912);
		funMap.put("with(Math){ return !_501010_&&!_13_;}",913);
		funMap.put("with(Math){ return !_501004_;}",914);
		funMap.put("with(Math){ return _509082_||_509083_||_506201_;}",915);
		funMap.put("with(Math){ return _506002_;}",916);
		funMap.put("with(Math){ return _501402_;}",917);
		funMap.put("with(Math){ return !_13_&&!_501008_;}",918);
		funMap.put("with(Math){ return _110_||_120_||_13_;}",919);
		funMap.put("with(Math){ return _506306_;}",920);
		funMap.put("with(Math){ return _503002_;}",921);
		funMap.put("with(Math){ return _504003_;}",922);
		funMap.put("with(Math){ return !_506109_;}",923);
		funMap.put("with(Math){ return _13_;}",924);
		funMap.put("with(Math){ return _504013_;}",925);
		funMap.put("with(Math){ return !_501010_;}",926);
		funMap.put("with(Math){ return _506109_;}",927);
		funMap.put("with(Math){ return !_506101_;}",928);
		funMap.put("with(Math){ return !_510139_;}",929);
		funMap.put("with(Math){ return !_506306_;}",930);
		funMap.put("with(Math){ return !_506201_;}",931);
		funMap.put("with(Math){ return _501010_;}",932);
		funMap.put("with(Math){ return _501004_;}",933);
		funMap.put("with(Math){ return _509082_||_509083_||_506201_||_509068_||_509031_;}",934);
		funMap.put("with(Math){ return !_502002_;}",935);
		funMap.put("with(Math){ return _110_||_120_;}",936);
		funMap.put("with(Math){ return _509201_;}",937);
		funMap.put("with(Math){ return !_508236_;}",938);
		funMap.put("with(Math){ return !_508237_;}",939);
		funMap.put("with(Math){ return !_509951_;}",940);
		funMap.put("with(Math){ return !_503001_;}",941);
		funMap.put("with(Math){ return !_501402_;}",942);
		funMap.put("with(Math){ return !_508002_;}",943);
		funMap.put("with(Math){ return !_508006_;}",944);
		funMap.put("with(Math){ return _509081_;}",945);
		funMap.put("with(Math){ return _503001_;}",946);
		funMap.put("with(Math){ return !_508014_;}",947);
		funMap.put("with(Math){ return !_508008_;}",948);
		funMap.put("with(Math){ return 1*TeamNum+3;}",949);
		funMap.put("with(Math){ return TeamLv;}",950);
		funMap.put("with(Math){ return 1*TeamNum+5;}",951);
		funMap.put("with(Math){ return 0*TeamNum+4;}",952);
		funMap.put("with(Math){ return 1*TeamNum+4;}",953);
		funMap.put("with(Math){ return 1*TeamNum;}",954);
		funMap.put("with(Math){ return 0*TeamNum+6+2*random();}",955);
		funMap.put("with(Math){ return 0*TeamNum+8+2*random();}",956);
		funMap.put("with(Math){ return 0*TeamNum+2;}",957);
	}
	public static Object JsFunbyID(IJavaScriptEngine engine, Fighter opf, Fighter aimf, int id)
	{
		switch(id)
		{
			case 0:  { return -(Math.max(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue(),opf.getEffectRole().getAttrById(130)*0.1)+(opf.getBuffAgent().existBuff(509300)?(Math.min(Math.max(aimf.getEffectRole().getAttrById(140)-aimf.getEffectRole().getAttrById(130),((((boolean)engine.get("pve")))?(2*engine.getDouble("gradea").intValue()):(10))),4*engine.getDouble("gradea").intValue())):(0)));}
			case 1:  { return -(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 2:  { return engine.getDouble("quality").intValue()*60+2000;}
			case 3:  { return engine.getDouble("quality").intValue()*0.6+10;}
			case 4:  { return engine.getDouble("quality").intValue()*32+1000;}
			case 5:  { return engine.getDouble("quality").intValue();}
			case 6:  { return engine.getDouble("quality").intValue()*0.4+10;}
			case 7:  { return 400*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 8:  { return (engine.getDouble("quality").intValue()*12+150)*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 9:  { return (engine.getDouble("quality").intValue()*5+50)*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 10:  { return engine.getDouble("quality").intValue()*3*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 11:  { return (engine.getDouble("quality").intValue()*5+100)*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 12:  { return 100*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 13:  { return -engine.getDouble("quality").intValue()*3;}
			case 14:  { return ((boolean)engine.get("pve"));}
			case 15:  { return 200*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 16:  { return 150*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 17:  { return 300*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 18:  { return 250*(opf.getBuffAgent().existBuff(508042)?(1.2):(1));}
			case 19:  { return engine.getDouble("quality").intValue()*12+150;}
			case 20:  { return engine.getDouble("quality").intValue()*5+50;}
			case 21:  { return engine.getDouble("skilllevel").intValue()*10;}
			case 22:  { return 2.5*engine.getDouble("skilllevel").intValue();}
			case 23:  { return 2*engine.getDouble("skilllevel").intValue();}
			case 24:  { return 10+1.2*engine.getDouble("skilllevel").intValue();}
			case 25:  { return -(opf.getEffectRole().getAttrById(130)*1.05-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 26:  { return -(opf.getEffectRole().getAttrById(130)*0.9-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 27:  { return -(opf.getEffectRole().getAttrById(130)*0.75-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 28:  { return engine.getDouble("skilllevel").intValue()>=70;}
			case 29:  { return -(opf.getEffectRole().getAttrById(130)*0.65-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 30:  { return (opf.getEffectRole().getAttrById(80)/opf.getEffectRole().getAttrById(60))>=0.5;}
			case 31:  { return -(opf.getEffectRole().getAttrById(130)*1.15-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 32:  { return -(opf.getEffectRole().getAttrById(130)*1.25-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 33:  { return -(opf.getEffectRole().getAttrById(130)*0.55-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 34:  { return Math.min(-2.4*engine.getDouble("gradea").intValue()+1.2*engine.getDouble("skilllevel").intValue(),0);}
			case 35:  { return -Math.min((Math.random()*(0.13-0.07)+0.07)*opf.getEffectRole().getAttrById(60),opf.getEffectRole().getAttrById(80)-1);}
			case 36:  { return 0.15*aimf.getEffectRole().getAttrById(60);}
			case 37:  { return 1*engine.getDouble("skilllevel").intValue();}
			case 38:  { return -(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue())*(0.45+0.05*engine.getDouble("skilllevel").intValue());}
			case 39:  { return (opf.getEffectRole().getAttrById(80)/opf.getEffectRole().getAttrById(60))<=0.8;}
			case 40:  { return (opf.getEffectRole().getAttrById(80)/opf.getEffectRole().getAttrById(60))<=0.6;}
			case 41:  { return (opf.getEffectRole().getAttrById(80)/opf.getEffectRole().getAttrById(60))<=0.4;}
			case 42:  { return (opf.getEffectRole().getAttrById(80)/opf.getEffectRole().getAttrById(60))<=0.2;}
			case 43:  { return -(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue())*(0.25+0.05*engine.getDouble("skilllevel").intValue());}
			case 44:  { return 0.5*engine.getDouble("skilllevel").intValue();}
			case 45:  { return 10*engine.getDouble("skilllevel").intValue();}
			case 46:  { return -(opf.getEffectRole().getAttrById(130)*1.45-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 47:  { return -(opf.getEffectRole().getAttrById(130)*0.85-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 48:  { return 9*engine.getDouble("skilllevel").intValue();}
			case 49:  { return 3*engine.getDouble("skilllevel").intValue();}
			case 50:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*(0.5+0.05*(4-engine.getDouble("preaimcount").intValue()));}
			case 51:  { return ((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))*0.5;}
			case 52:  { return -(opf.getEffectRole().getAttrById(150)*1.2-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*(0.5+0.05*(4-engine.getDouble("preaimcount").intValue()));}
			case 53:  { return ((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))+0.05;}
			case 54:  { return -1.4*engine.getDouble("skilllevel").intValue();}
			case 55:  { return Math.min(-1*engine.getDouble("gradea").intValue()+0.5*engine.getDouble("skilllevel").intValue(),0);}
			case 56:  { return ((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)));}
			case 57:  { return -2*engine.getDouble("skilllevel").intValue();}
			case 58:  { return (((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16)*(0.3+0.05*engine.getDouble("skilllevel").intValue())*0.5;}
			case 59:  { return (((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16)*(0.3+0.05*engine.getDouble("skilllevel").intValue())*0.5/(1-(((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16)*(0.3+0.05*engine.getDouble("skilllevel").intValue())*0.5);}
			case 60:  { return -(opf.getEffectRole().getAttrById(130)*1.1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 61:  { return -(opf.getEffectRole().getAttrById(130)*1.1-aimf.getEffectRole().getAttrById(140)*0.9+1*engine.getDouble("skilllevel").intValue());}
			case 62:  { return engine.getDouble("gradea").intValue()*2;}
			case 63:  { return opf.getFighterBean().getInitattrs().get(1010)<2;}
			case 64:  { return opf.getFighterBean().getInitattrs().get(1010)>=2;}
			case 65:  { return -(opf.getEffectRole().getAttrById(130)*0.95-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 66:  { return -(opf.getEffectRole().getAttrById(130)*0.45-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 67:  { return 16*engine.getDouble("skilllevel").intValue();}
			case 68:  { return -(opf.getEffectRole().getAttrById(150)*1.1-aimf.getEffectRole().getAttrById(160)+1*engine.getDouble("skilllevel").intValue());}
			case 69:  { return -(opf.getEffectRole().getAttrById(130)*1.1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(170)-aimf.getEffectRole().getAttrById(170))*0.5);}
			case 70:  { return -Math.min(0.1*aimf.getEffectRole().getAttrById(80),10*engine.getDouble("skilllevel").intValue())-3*engine.getDouble("skilllevel").intValue();}
			case 71:  { return ((opf.getEffectRole().getAttrById(170)*0.5+engine.getDouble("skilllevel").intValue()*1.4)+Math.abs(engine.getDouble("maindamage").intValue())*0.1)*(1+opf.getEffectRole().getAttrById(790))*(1+opf.getEffectRole().getAttrById(990)/1000);}
			case 72:  { return engine.getDouble("maindamage").intValue();}
			case 73:  { return ((opf.getEffectRole().getAttrById(170)*0.2+engine.getDouble("skilllevel").intValue()*1.2)+Math.abs(engine.getDouble("maindamage").intValue())*0.08)*(1+opf.getEffectRole().getAttrById(790))*(1+opf.getEffectRole().getAttrById(990)/1000);}
			case 74:  { return -(opf.getEffectRole().getAttrById(130)*1.05-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(170)-aimf.getEffectRole().getAttrById(170))*0.5);}
			case 75:  { return -(opf.getEffectRole().getAttrById(130)*1.15-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(170)-aimf.getEffectRole().getAttrById(170))*0.5);}
			case 76:  { return -0.1-(0.1+0.05*engine.getDouble("skilllevel").intValue())*(1-aimf.getEffectRole().getAttrById(100)/aimf.getEffectRole().getAttrById(90));}
			case 77:  { return 10+2.4*engine.getDouble("skilllevel").intValue();}
			case 78:  { return -(opf.getEffectRole().getAttrById(150)*2.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.5;}
			case 79:  { return Math.abs(engine.getDouble("maindamage").intValue())*0.35;}
			case 80:  { return Math.abs(engine.getDouble("maindamage").intValue())*1;}
			case 81:  { return -opf.getEffectRole().getAttrById(150)*0.2;}
			case 82:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue())*0.5*(1.2+(0.6+0.2*engine.getDouble("skilllevel").intValue())*(1-aimf.getEffectRole().getAttrById(100)/aimf.getEffectRole().getAttrById(90)));}
			case 83:  { return 10+2*engine.getDouble("skilllevel").intValue();}
			case 84:  { return -(opf.getEffectRole().getAttrById(150)*1.3-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*(0.5+0.05*(4-engine.getDouble("preaimcount").intValue()));}
			case 85:  { return opf.getEffectRole().getAttrById(170)+3*engine.getDouble("skilllevel").intValue();}
			case 86:  { return (opf.getEffectRole().getAttrById(170)+3*engine.getDouble("skilllevel").intValue())*0.4;}
			case 87:  { return 1.4*engine.getDouble("skilllevel").intValue();}
			case 88:  { return opf.getEffectRole().getAttrById(170)+3*engine.getDouble("skilllevel").intValue()*2;}
			case 89:  { return 0.15+0.1*engine.getDouble("skilllevel").intValue();}
			case 90:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*(0.5+0.05*(3-engine.getDouble("preaimcount").intValue()))*(opf.getBuffAgent().existBuff(506109)?((Math.random()*(1.20-1.1))+1.1):((Math.random()*(1.20-0.9))+0.9));}
			case 91:  { return -(opf.getEffectRole().getAttrById(150)*2.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.5*(opf.getBuffAgent().existBuff(506109)?((Math.random()*(1.20-1.1))+1.1):((Math.random()*(1.20-0.9))+0.9));}
			case 92:  { return -(opf.getEffectRole().getAttrById(150)*1-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.5;}
			case 93:  { return -(opf.getEffectRole().getAttrById(150)*2.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.5*(opf.getBuffAgent().existBuff(506109)?((Math.random()*(1.20-1.1))+1.1):((Math.random()*(1.20-0.9))+0.9))*(1+(0.4+0.1*engine.getDouble("skilllevel").intValue())*(1-opf.getEffectRole().getAttrById(80)/opf.getEffectRole().getAttrById(60)));}
			case 94:  { return 20*engine.getDouble("skilllevel").intValue();}
			case 95:  { return 2.1*engine.getDouble("skilllevel").intValue();}
			case 96:  { return opf.getEffectRole().getAttrById(170)+1.2*engine.getDouble("skilllevel").intValue();}
			case 97:  { return (opf.getEffectRole().getAttrById(170)+1.2*engine.getDouble("skilllevel").intValue())*0.4;}
			case 98:  { return opf.getFighterBean().getInitattrs().get(1010)>=3;}
			case 99:  { return opf.getFighterBean().getInitattrs().get(1010)>=4;}
			case 100:  { return opf.getFighterBean().getInitattrs().get(1010)>=5;}
			case 101:  { return 2*engine.getDouble("skilllevel").intValue()+50;}
			case 102:  { return randint(1,2);}
			case 103:  { return 0.7*aimf.getEffectRole().getAttrById(60);}
			case 104:  { return -(opf.getEffectRole().getAttrById(200)*0.1+7*engine.getDouble("skilllevel").intValue())*1.1;}
			case 105:  { return -(opf.getEffectRole().getAttrById(200)*0.1+10*engine.getDouble("skilllevel").intValue())*1.1;}
			case 106:  { return ((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16;}
			case 107:  { return 10+1.3*engine.getDouble("skilllevel").intValue();}
			case 108:  { return 4.5*engine.getDouble("skilllevel").intValue();}
			case 109:  { return -(opf.getEffectRole().getAttrById(150)*2.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue())*1.1;}
			case 110:  { return engine.getDouble("skilllevel").intValue()>=60;}
			case 111:  { return -(opf.getEffectRole().getAttrById(150)*3.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*1.1;}
			case 112:  { return -(opf.getEffectRole().getAttrById(150)*3.0-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue())*1.1;}
			case 113:  { return engine.getDouble("skilllevel").intValue()>=90;}
			case 114:  { return 10+1.4*engine.getDouble("skilllevel").intValue();}
			case 115:  { return -(opf.getEffectRole().getAttrById(130)*0.4+opf.getEffectRole().getAttrById(140)*0.5-aimf.getEffectRole().getAttrById(140)+2*engine.getDouble("gradea").intValue());}
			case 116:  { return -0.05+0.1*engine.getDouble("skilllevel").intValue();}
			case 117:  { return (opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.38*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)*(0.3+0.05*engine.getDouble("skilllevel").intValue())):(0.6*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)*(0.3+0.05*engine.getDouble("skilllevel").intValue()));}
			case 118:  { return -(opf.getEffectRole().getAttrById(130)*0.7-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 119:  { return -(opf.getEffectRole().getAttrById(150)*0.9-aimf.getEffectRole().getAttrById(160)+3*engine.getDouble("skilllevel").intValue());}
			case 120:  { return engine.getDouble("skilllevel").intValue()>=50;}
			case 121:  { return -(opf.getEffectRole().getAttrById(130)*0.5+opf.getEffectRole().getAttrById(140)*0.6-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 122:  { return -(opf.getEffectRole().getAttrById(150)*1-aimf.getEffectRole().getAttrById(160)+3*engine.getDouble("skilllevel").intValue());}
			case 123:  { return aimf.getEffectRole().getAttrById(60)*1;}
			case 124:  { return engine.getDouble("skilllevel").intValue()*1;}
			case 125:  { return engine.getDouble("skilllevel").intValue()*50;}
			case 126:  { return engine.getDouble("skilllevel").intValue()*8;}
			case 127:  { return -(opf.getEffectRole().getAttrById(150)*1.1-aimf.getEffectRole().getAttrById(160)+3*engine.getDouble("skilllevel").intValue());}
			case 128:  { return -opf.getEffectRole().getAttrById(80)*1;}
			case 129:  { return -aimf.getEffectRole().getAttrById(80)*0.05;}
			case 130:  { return -aimf.getEffectRole().getAttrById(80)*0.1;}
			case 131:  { return -aimf.getEffectRole().getAttrById(80)*0.2;}
			case 132:  { return -aimf.getEffectRole().getAttrById(80)*0.5;}
			case 133:  { return 3+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1);}
			case 134:  { return -aimf.getEffectRole().getAttrById(80)*0.7;}
			case 135:  { return -aimf.getEffectRole().getAttrById(60)*2.5;}
			case 136:  { return opf.getEffectRole().getAttrById(60)*1;}
			case 137:  { return aimf.getEffectRole().getAttrById(60);}
			case 138:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*(0.5+0.05*(3-engine.getDouble("preaimcount").intValue()));}
			case 139:  { return -aimf.getEffectRole().getAttrById(60)*0.5;}
			case 140:  { return aimf.getEffectRole().getAttrById(60)*0.5;}
			case 141:  { return ((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))*0.4;}
			case 142:  { return ((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))*0.3;}
			case 143:  { return 4+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1)+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/90),1);}
			case 144:  { return -(opf.getEffectRole().getAttrById(130)*1.05-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 145:  { return -opf.getEffectRole().getAttrById(80)*0.8;}
			case 146:  { return -aimf.getEffectRole().getAttrById(80)*0.8;}
			case 147:  { return -opf.getEffectRole().getAttrById(100)*0.8;}
			case 148:  { return -aimf.getEffectRole().getAttrById(60)*0.1;}
			case 149:  { return -aimf.getEffectRole().getAttrById(60)*0.2;}
			case 150:  { return -aimf.getEffectRole().getAttrById(60)*0.3;}
			case 151:  { return -aimf.getEffectRole().getAttrById(60)*0.4;}
			case 152:  { return -aimf.getEffectRole().getAttrById(60)*0.6;}
			case 153:  { return -aimf.getEffectRole().getAttrById(60)*0.7;}
			case 154:  { return -(opf.getEffectRole().getAttrById(130)*10-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue()+Math.max((opf.getEffectRole().getAttrById(130)-aimf.getEffectRole().getAttrById(130))*0.05,0));}
			case 155:  { return 0.6+0.002*(engine.getDouble("skilllevel").intValue()-aimf.getEffectRole().getLevel())+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820));}
			case 156:  { return 2+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1);}
			case 157:  { return -(opf.getEffectRole().getAttrById(130)*1.40-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue())*2.5;}
			case 158:  { return -(opf.getEffectRole().getAttrById(130)*1.45-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue())*2.5;}
			case 159:  { return -(opf.getEffectRole().getAttrById(130)*1.50-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue())*2.5;}
			case 160:  { return -(opf.getEffectRole().getAttrById(130)*1.55-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue())*2.5;}
			case 161:  { return -(opf.getEffectRole().getAttrById(130)*1.60-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue())*2.5;}
			case 162:  { return -(opf.getEffectRole().getAttrById(130)*1.10-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue())*2.5;}
			case 163:  { return -opf.getEffectRole().getAttrById(150)*2;}
			case 164:  { return -opf.getEffectRole().getAttrById(150)*3;}
			case 165:  { return -opf.getEffectRole().getAttrById(150)*2.2;}
			case 166:  { return -opf.getEffectRole().getAttrById(150)*1.6;}
			case 167:  { return engine.getDouble("gradea").intValue()*0.8;}
			case 168:  { return engine.getDouble("gradea").intValue()*0.4;}
			case 169:  { return engine.getDouble("gradea").intValue()*0.9;}
			case 170:  { return engine.getDouble("gradea").intValue()*20;}
			case 171:  { return engine.getDouble("gradea").intValue()*1.6;}
			case 172:  { return 3*engine.getDouble("gradea").intValue();}
			case 173:  { return -(opf.getEffectRole().getAttrById(150)*2.2-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue())*0.5;}
			case 174:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue())*(0.5+0.05*(2-engine.getDouble("preaimcount").intValue()));}
			case 175:  { return engine.getDouble("gradea").intValue()>=60;}
			case 176:  { return -(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+3*engine.getDouble("gradea").intValue());}
			case 177:  { return -(opf.getEffectRole().getAttrById(130)*0.75-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 178:  { return -(opf.getEffectRole().getAttrById(130)*0.45-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 179:  { return engine.getDouble("maindamage").intValue()*0.33*((Math.random()*(1.05-0.95))+0.95);}
			case 180:  { return -(opf.getEffectRole().getAttrById(130)*1.25-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue()+Math.max((opf.getEffectRole().getAttrById(130)-aimf.getEffectRole().getAttrById(130))*0.25,0));}
			case 181:  { return -(opf.getEffectRole().getAttrById(130)*2-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 182:  { return opf.getEffectRole().getAttrById(130)*1.25-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue();}
			case 183:  { return ((Math.random()*(3-2))+2);}
			case 184:  { return ((Math.random()*(5-3))+3);}
			case 185:  { return engine.getDouble("maindamage").intValue()*0.2*((Math.random()*(1.05-0.95))+0.95);}
			case 186:  { return -engine.getDouble("maindamage").intValue();}
			case 187:  { return -(opf.getEffectRole().getAttrById(150)*0.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue())*(0.5+0.05*(2-engine.getDouble("preaimcount").intValue()));}
			case 188:  { return -(opf.getEffectRole().getAttrById(150)*0.8-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue())*(0.5+0.05*(2-engine.getDouble("preaimcount").intValue()));}
			case 189:  { return -(opf.getEffectRole().getAttrById(130)*0.55-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 190:  { return Math.abs(engine.getDouble("maindamage").intValue())*0.20;}
			case 191:  { return -(opf.getEffectRole().getAttrById(150)*3.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.5;}
			case 192:  { return -(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+7*engine.getDouble("gradea").intValue());}
			case 193:  { return -(opf.getEffectRole().getAttrById(150)*3.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.3;}
			case 194:  { return engine.getDouble("gradea").intValue()*0.16;}
			case 195:  { return engine.getDouble("gradea").intValue()*0.1;}
			case 196:  { return engine.getDouble("gradea").intValue()*0.2;}
			case 197:  { return engine.getDouble("gradea").intValue()*0.125;}
			case 198:  { return engine.getDouble("gradea").intValue()*0.24;}
			case 199:  { return engine.getDouble("gradea").intValue()*0.15;}
			case 200:  { return engine.getDouble("gradea").intValue()*0.28;}
			case 201:  { return engine.getDouble("gradea").intValue()*0.175;}
			case 202:  { return engine.getDouble("gradea").intValue()*0.32;}
			case 203:  { return engine.getDouble("gradea").intValue()*0.7;}
			case 204:  { return engine.getDouble("gradea").intValue()*0.87;}
			case 205:  { return engine.getDouble("gradea").intValue()*1.05;}
			case 206:  { return engine.getDouble("gradea").intValue()*1.22;}
			case 207:  { return engine.getDouble("gradea").intValue()*1.4;}
			case 208:  { return engine.getDouble("gradea").intValue()*0.0007;}
			case 209:  { return engine.getDouble("gradea").intValue()*0.000875;}
			case 210:  { return engine.getDouble("gradea").intValue()*0.00105;}
			case 211:  { return engine.getDouble("gradea").intValue()*0.001225;}
			case 212:  { return engine.getDouble("gradea").intValue()*0.0014;}
			case 213:  { return engine.getDouble("gradea").intValue()*0.08;}
			case 214:  { return engine.getDouble("gradea").intValue()*1;}
			case 215:  { return engine.getDouble("gradea").intValue()*0.12;}
			case 216:  { return engine.getDouble("gradea").intValue()*1.2;}
			case 217:  { return engine.getDouble("gradea").intValue()*0.14;}
			case 218:  { return engine.getDouble("gradea").intValue()*0.189;}
			case 219:  { return engine.getDouble("gradea").intValue()*0.2362;}
			case 220:  { return engine.getDouble("gradea").intValue()*0.2835;}
			case 221:  { return engine.getDouble("gradea").intValue()*0.3375;}
			case 222:  { return engine.getDouble("gradea").intValue()*0.378;}
			case 223:  { return engine.getDouble("gradea").intValue()*0.875;}
			case 224:  { return engine.getDouble("gradea").intValue()*1.225;}
			case 225:  { return engine.getDouble("gradea").intValue()*0.05;}
			case 226:  { return engine.getDouble("gradea").intValue()*0.5;}
			case 227:  { return engine.getDouble("gradea").intValue()*0.0625;}
			case 228:  { return engine.getDouble("gradea").intValue()*0.625;}
			case 229:  { return engine.getDouble("gradea").intValue()*0.075;}
			case 230:  { return engine.getDouble("gradea").intValue()*0.75;}
			case 231:  { return engine.getDouble("gradea").intValue()*0.0875;}
			case 232:  { return engine.getDouble("gradea").intValue()*0.65;}
			case 233:  { return engine.getDouble("gradea").intValue()*0.85;}
			case 234:  { return engine.getDouble("gradea").intValue()*0.3;}
			case 235:  { return engine.getDouble("gradea").intValue()*0.375;}
			case 236:  { return engine.getDouble("gradea").intValue()*0.45;}
			case 237:  { return engine.getDouble("gradea").intValue()*0.525;}
			case 238:  { return engine.getDouble("gradea").intValue()*0.6;}
			case 239:  { return engine.getDouble("gradea").intValue()*3;}
			case 240:  { return engine.getDouble("gradea").intValue()*3.25;}
			case 241:  { return engine.getDouble("gradea").intValue()*3.5;}
			case 242:  { return engine.getDouble("gradea").intValue()*3.75;}
			case 243:  { return engine.getDouble("gradea").intValue()*4;}
			case 244:  { return -engine.getDouble("gradea").intValue()*3;}
			case 245:  { return -(opf.getEffectRole().getAttrById(130)*1.2-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 246:  { return -(opf.getEffectRole().getAttrById(130)*1.6-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 247:  { return engine.getDouble("maindamage").intValue()*((Math.random()*(1.05-0.95))+0.95);}
			case 248:  { return -Math.max(opf.getEffectRole().getAttrById(80)-opf.getEffectRole().getAttrById(60)*0.1,0);}
			case 249:  { return 0.05*aimf.getEffectRole().getAttrById(60);}
			case 250:  { return 0.3*aimf.getEffectRole().getAttrById(60);}
			case 251:  { return 0.35*aimf.getEffectRole().getAttrById(60);}
			case 252:  { return aimf.getEffectRole().getAttrById(60)*0.03+200;}
			case 253:  { return aimf.getEffectRole().getAttrById(60)*0.06+400;}
			case 254:  { return aimf.getEffectRole().getAttrById(60)*0.09+600;}
			case 255:  { return aimf.getEffectRole().getAttrById(90)*0.1+150;}
			case 256:  { return aimf.getEffectRole().getAttrById(90)*0.15+250;}
			case 257:  { return Math.min(aimf.getEffectRole().getAttrById(60)*0.25,aimf.getEffectRole().getLevel()*18);}
			case 258:  { return Math.min(aimf.getEffectRole().getAttrById(60)*0.50,aimf.getEffectRole().getLevel()*30);}
			case 259:  { return -opf.getEffectRole().getAttrById(100);}
			case 260:  { return Math.min(aimf.getEffectRole().getAttrById(60)*0.25,aimf.getEffectRole().getLevel()*12);}
			case 261:  { return Math.min(aimf.getEffectRole().getAttrById(60)*0.15,aimf.getEffectRole().getLevel()*12);}
			case 262:  { return -(opf.getEffectRole().getAttrById(130)*0.65-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 263:  { return -(opf.getEffectRole().getAttrById(130)*0.8-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 264:  { return -(opf.getEffectRole().getAttrById(130)*0.5-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 265:  { return engine.getDouble("gradea").intValue()*1.5;}
			case 266:  { return 10+1.2*engine.getDouble("gradea").intValue();}
			case 267:  { return 0.08*aimf.getEffectRole().getAttrById(60);}
			case 268:  { return -(opf.getEffectRole().getAttrById(130)*1.6-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 269:  { return -(opf.getEffectRole().getAttrById(130)*1.05-Math.min(aimf.getEffectRole().getAttrById(140),aimf.getEffectRole().getAttrById(160))+1*engine.getDouble("skilllevel").intValue());}
			case 270:  { return -(opf.getEffectRole().getAttrById(130)*1.15-Math.min(aimf.getEffectRole().getAttrById(140),aimf.getEffectRole().getAttrById(160))+1*engine.getDouble("skilllevel").intValue());}
			case 271:  { return -(opf.getEffectRole().getAttrById(130)*1.25-Math.min(aimf.getEffectRole().getAttrById(140),aimf.getEffectRole().getAttrById(160))+1*engine.getDouble("skilllevel").intValue());}
			case 272:  { return -(opf.getEffectRole().getAttrById(130)*1.6-Math.min(aimf.getEffectRole().getAttrById(140),aimf.getEffectRole().getAttrById(160))+1*engine.getDouble("skilllevel").intValue());}
			case 273:  { return -aimf.getEffectRole().getAttrById(60)*0.15;}
			case 274:  { return -(opf.getEffectRole().getAttrById(130)*1.1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(200)-aimf.getEffectRole().getAttrById(200))*0.5);}
			case 275:  { return -(opf.getEffectRole().getAttrById(130)*1.2-aimf.getEffectRole().getAttrById(140)*0.9+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(200)-aimf.getEffectRole().getAttrById(200))*0.5);}
			case 276:  { return -(opf.getEffectRole().getAttrById(130)*1.05-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(200)-aimf.getEffectRole().getAttrById(200))*0.5);}
			case 277:  { return -(opf.getEffectRole().getAttrById(130)*0.95-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(200)-aimf.getEffectRole().getAttrById(200))*0.5);}
			case 278:  { return -(opf.getEffectRole().getAttrById(130)*0.85-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(200)-aimf.getEffectRole().getAttrById(200))*0.5);}
			case 279:  { return -(opf.getEffectRole().getAttrById(130)*0.75-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue()+Math.max(0,opf.getEffectRole().getAttrById(200)-aimf.getEffectRole().getAttrById(200))*0.5);}
			case 280:  { return opf.getEffectRole().getAttrById(200);}
			case 281:  { return -(opf.getEffectRole().getAttrById(130)*1.3-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 282:  { return 5*engine.getDouble("skilllevel").intValue();}
			case 283:  { return 0.8*engine.getDouble("skilllevel").intValue();}
			case 284:  { return 0.7*engine.getDouble("skilllevel").intValue();}
			case 285:  { return 1.2*engine.getDouble("skilllevel").intValue();}
			case 286:  { return -Math.min(0.2*aimf.getEffectRole().getAttrById(80),10*engine.getDouble("skilllevel").intValue())-3*engine.getDouble("skilllevel").intValue();}
			case 287:  { return ((opf.getEffectRole().getAttrById(170)*0.7+engine.getDouble("skilllevel").intValue()*1.4)+Math.abs(engine.getDouble("maindamage").intValue())*0.1)*(1+opf.getEffectRole().getAttrById(790))*(1+opf.getEffectRole().getAttrById(990)/1000);}
			case 288:  { return 0.1*aimf.getEffectRole().getAttrById(60);}
			case 289:  { return opf.getEffectRole().getAttrById(170)+3.5*engine.getDouble("skilllevel").intValue();}
			case 290:  { return 0.6*engine.getDouble("skilllevel").intValue();}
			case 291:  { return opf.getEffectRole().getAttrById(170)+4*engine.getDouble("skilllevel").intValue();}
			case 292:  { return opf.getEffectRole().getAttrById(170)+1*engine.getDouble("skilllevel").intValue();}
			case 293:  { return 6*engine.getDouble("skilllevel").intValue();}
			case 294:  { return Math.round((Math.pow(1.02,engine.getDouble("skilllevel").intValue())-1)*1000);}
			case 295:  { return Math.round((1-Math.pow(0.98,engine.getDouble("skilllevel").intValue()))*1000);}
			case 296:  { return -8*engine.getDouble("skilllevel").intValue();}
			case 297:  { return ((opf.getEffectRole().getAttrById(170)+3*engine.getDouble("skilllevel").intValue())*0.5+Math.abs(engine.getDouble("maindamage").intValue())*0.5)*(1+opf.getEffectRole().getAttrById(790))*(1+opf.getEffectRole().getAttrById(990)/1000);}
			case 298:  { return 14*engine.getDouble("skilllevel").intValue();}
			case 299:  { return -(opf.getEffectRole().getAttrById(130)*1.1-aimf.getEffectRole().getAttrById(140)*0.9+2*engine.getDouble("skilllevel").intValue());}
			case 300:  { return -aimf.getEffectRole().getAttrById(80);}
			case 301:  { return engine.getDouble("skilllevel").intValue()>=2;}
			case 302:  { return engine.getDouble("skilllevel").intValue()>=3;}
			case 303:  { return engine.getDouble("skilllevel").intValue()>=4;}
			case 304:  { return engine.getDouble("survivala").intValue()<engine.getDouble("survivalb").intValue();}
			case 305:  { return 3+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1)+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/90),1);}
			case 306:  { return 3+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1)+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/90),2);}
			case 307:  { return 3+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1)+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/90),3);}
			case 308:  { return 3+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1)+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/90),4);}
			case 309:  { return 3+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1)+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/90),5);}
			case 310:  { return 3+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/60),1)+Math.min(Math.floor(engine.getDouble("skilllevel").intValue()/90),6);}
			case 311:  { return -(opf.getEffectRole().getAttrById(130)*1.1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 312:  { return -(opf.getEffectRole().getAttrById(130)*2.5-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue());}
			case 313:  { return opf.getEffectRole().getAttrById(130)*2-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue();}
			case 314:  { return -(2*opf.getEffectRole().getAttrById(150)+engine.getDouble("bodong80").intValue()-200);}
			case 315:  { return opf.getEffectRole().getAttrById(60)*0.12;}
			case 316:  { return (opf.getEffectRole().getAttrById(60)*0.2)*0.4;}
			case 317:  { return -opf.getEffectRole().getAttrById(150)*1.2;}
			case 318:  { return opf.getEffectRole().getAttrById(60)*0.22;}
			case 319:  { return -(opf.getEffectRole().getAttrById(130)*2-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("skilllevel").intValue());}
			case 320:  { return -opf.getEffectRole().getAttrById(130);}
			case 321:  { return -opf.getEffectRole().getAttrById(150)*1.7;}
			case 322:  { return -opf.getEffectRole().getAttrById(150)*10;}
			case 323:  { return opf.getEffectRole().getAttrById(150)*10;}
			case 324:  { return opf.getEffectRole().getAttrById(170)+engine.getDouble("skilllevel").intValue()*10;}
			case 325:  { return opf.getEffectRole().getAttrById(170)*2+engine.getDouble("skilllevel").intValue()*10;}
			case 326:  { return engine.getDouble("cons").intValue()>=600;}
			case 327:  { return -(engine.getDouble("maxhp").intValue()*0.1+2*engine.getDouble("gradea").intValue());}
			case 328:  { return engine.getDouble("cons").intValue()>=300;}
			case 329:  { return (engine.getDouble("cons").intValue()*2+3*engine.getDouble("gradea").intValue());}
			case 330:  { return (engine.getDouble("cons").intValue()*5+10*engine.getDouble("gradea").intValue());}
			case 331:  { return (engine.getDouble("agi").intValue()*0.5+3*engine.getDouble("gradea").intValue());}
			case 332:  { return engine.getDouble("agi").intValue()>=600;}
			case 333:  { return -(opf.getEffectRole().getAttrById(150)*2.2-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue()+Math.max((opf.getEffectRole().getAttrById(150)-aimf.getEffectRole().getAttrById(150))*0.3,0));}
			case 334:  { return Math.abs(engine.getDouble("maindamage").intValue()*0.2);}
			case 335:  { return -opf.getEffectRole().getAttrById(200)*0.5;}
			case 336:  { return -opf.getEffectRole().getAttrById(150)*0.1;}
			case 337:  { return -opf.getEffectRole().getAttrById(200)*2;}
			case 338:  { return engine.getDouble("gradea").intValue()*1.3;}
			case 339:  { return aimf.getEffectRole().getAttrById(130)*0.1;}
			case 340:  { return -(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue())*0.5;}
			case 341:  { return -(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue())*0.9;}
			case 342:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+1.5*engine.getDouble("gradea").intValue())*1.3;}
			case 343:  { return -(opf.getEffectRole().getAttrById(130)*1-aimf.getEffectRole().getAttrById(140)+1*engine.getDouble("gradea").intValue())*0.8;}
			case 344:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+1.5*engine.getDouble("gradea").intValue())*1.2;}
			case 345:  { return -opf.getEffectRole().getAttrById(150)*0.7;}
			case 346:  { return -Math.min(0.1*aimf.getEffectRole().getAttrById(80),20*engine.getDouble("skilllevel").intValue());}
			case 347:  { return -Math.min(0.05*aimf.getEffectRole().getAttrById(100),10*engine.getDouble("skilllevel").intValue());}
			case 348:  { return -(opf.getEffectRole().getAttrById(150)*2-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.5;}
			case 349:  { return Math.abs(engine.getDouble("maindamage").intValue()*0.5);}
			case 350:  { return -0.7*engine.getDouble("skilllevel").intValue();}
			case 351:  { return -1*engine.getDouble("skilllevel").intValue();}
			case 352:  { return (((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16)*0.6;}
			case 353:  { return (((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16)*0.5;}
			case 354:  { return (((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16)*0.4;}
			case 355:  { return (((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16)*0.3;}
			case 356:  { return (((opf.getEffectRole().getAttrById(180)>=aimf.getEffectRole().getAttrById(190))?(0.98-0.32*Math.pow(0.95,(opf.getEffectRole().getAttrById(180)/10-aimf.getEffectRole().getAttrById(190)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)):(0.66*Math.pow(0.9,(aimf.getEffectRole().getAttrById(190)/10-opf.getEffectRole().getAttrById(180)/10))+(opf.getEffectRole().getAttrById(810)-aimf.getEffectRole().getAttrById(820))+(opf.getEffectRole().getAttrById(2130)/1000-aimf.getEffectRole().getAttrById(2140)/1000)))-0.16)*0.2;}
			case 357:  { return Math.abs(engine.getDouble("maindamage").intValue())*0.30;}
			case 358:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.25;}
			case 359:  { return -(opf.getEffectRole().getAttrById(150)*1.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("skilllevel").intValue())*0.1;}
			case 360:  { return opf.getEffectRole().getAttrById(150)*0.1;}
			case 361:  { return engine.getDouble("gradea").intValue()*1.1;}
			case 362:  { return engine.getDouble("gradea").intValue()*2.3;}
			case 363:  { return -(opf.getEffectRole().getAttrById(150)*2.5-aimf.getEffectRole().getAttrById(160)+2*engine.getDouble("gradea").intValue())*0.5;}
			case 364:  { return opf.getFighterBean().getInitattrs().get(1010)>=1;}
			case 365:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*160;}
			case 366:  { return (1000*engine.getDouble("RoleLv").intValue()*0.377*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 367:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*120;}
			case 368:  { return (1000*engine.getDouble("RoleLv").intValue()*0.5)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 369:  { return (1000*engine.getDouble("MonsterLv").intValue()*0.019*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 370:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*150;}
			case 371:  { return (1000*engine.getDouble("RoleLv").intValue()*0.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 372:  { return (1000*engine.getDouble("RoleLv").intValue()*0.1*(0.78+0.04*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 373:  { return (1000*engine.getDouble("RoleLv").intValue()*0.232*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 374:  { return (1000*engine.getDouble("RoleLv").intValue()*0.2)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 375:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*100;}
			case 376:  { return 100*1;}
			case 377:  { return (1000*engine.getDouble("RoleLv").intValue()*0.377*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1))*0.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 378:  { return (1+14*engine.getDouble("IsDbPoint").intValue()+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdMoney").intValue()*1.5/74*(14*0.09+1))*(Math.random()*(1.2-0.8)+0.8);}
			case 379:  { return (1000*Math.min(Math.max(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenLv").intValue()),engine.getDouble("FuBenLv").intValue()+9)*0.2*(0.7+0.1*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 380:  { return (1000*engine.getDouble("RoleLv").intValue()*0.232*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1))*0.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 381:  { return (1000*engine.getDouble("RoleLv").intValue()*0.232*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 382:  { return (1000*engine.getDouble("RoleLv").intValue()*0.3)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 383:  { return (1000*engine.getDouble("RoleLv").intValue()*0.215*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1))*0.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 384:  { return (1000*Math.min(Math.max(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenLv").intValue()),engine.getDouble("FuBenLv").intValue()+9)*0.1*(0.7+0.1*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 385:  { return (1000*engine.getDouble("RoleLv").intValue()*0.377*3)*(Math.random()*(1.02-0.98)+0.98);}
			case 386:  { return 3000+5000*Math.random();}
			case 387:  { return (1000*engine.getDouble("RoleLv").intValue()*0.215*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 388:  { return (1000*engine.getDouble("TeamLv").intValue()*0.075*(1-engine.getDouble("IsDbPoint").intValue())+1000*engine.getDouble("TeamLv").intValue()*0.12*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 389:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*140;}
			case 390:  { return (1000*engine.getDouble("MonsterLv").intValue()*0.1)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 391:  { return (1000*engine.getDouble("RoleLv").intValue()*0.4)*(Math.random()*(1.02-0.98)+0.98);}
			case 392:  { return (1000*engine.getDouble("TeamLv").intValue()*0.038*(0.78+0.04*engine.getDouble("Ring").intValue())*(1-engine.getDouble("IsDbPoint").intValue())+1000*engine.getDouble("TeamLv").intValue()*0.098*(0.78+0.04*engine.getDouble("Ring").intValue())*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 393:  { return 500*engine.getDouble("RoleLv").intValue();}
			case 394:  { return 1000*engine.getDouble("RoleLv").intValue()*0.194*(0.85+0.03*((engine.getDouble("Time").intValue()-1)%9+1))*(0.9+0.1*(Math.floor((engine.getDouble("Time").intValue()-1)/9)+1))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 395:  { return (1000*engine.getDouble("RoleLv").intValue()*0.4)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 396:  { return 200*engine.getDouble("RoleLv").intValue();}
			case 397:  { return engine.getDouble("RoleLv").intValue()*10;}
			case 398:  { return (1000*engine.getDouble("RoleLv").intValue()*0.1)*(Math.random()*(1.02-0.98)+0.98)*0.5;}
			case 399:  { return (engine.getDouble("StdMoney").intValue()*3.15/8*((engine.getDouble("Ring").intValue()-1)*0.3+1))*(Math.random()*(1.05-0.95)+0.95);}
			case 400:  { return (engine.getDouble("StdMoney").intValue()*4.2/8*((engine.getDouble("Ring").intValue()-1)*0.3+1))*(Math.random()*(1.05-0.95)+0.95);}
			case 401:  { return (1000*engine.getDouble("RoleLv").intValue()*0.194*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 402:  { return (1000*engine.getDouble("RoleLv").intValue()*0.1*(0.79+0.02*engine.getDouble("AnswerCnt").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 403:  { return engine.getDouble("StdMoney").intValue()*0.4*((engine.getDouble("Ring").intValue()-1)*0.09+1);}
			case 404:  { return (engine.getDouble("StdMoney").intValue()*2/15)*(Math.random()*(1.05-0.95)+0.95);}
			case 405:  { return (engine.getDouble("StdMoney").intValue()*2/10)*(Math.random()*(1.05-0.95)+0.95);}
			case 406:  { return (1000*engine.getDouble("RoleLv").intValue()*0.05*(0.79+0.02*engine.getDouble("AnswerCnt").intValue()))*0.5*(Math.random()*(1.02-0.98)+0.98);}
			case 407:  { return 1000*Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)*0.35*(0.75+0.05*engine.getDouble("Saveid").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 408:  { return (1000*engine.getDouble("RoleLv").intValue()*0.1)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 409:  { return (1000*engine.getDouble("RoleLv").intValue()*0.2*(0.78+0.04*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 410:  { return (engine.getDouble("StdMoney").intValue()*2/5)*(Math.random()*(1.05-0.95)+0.95);}
			case 411:  { return (engine.getDouble("StdMoney").intValue()*6/10)*(Math.random()*(1.05-0.95)+0.95);}
			case 412:  { return 1000*engine.getDouble("RoleLv").intValue()*0.067*(0.74+0.02*engine.getDouble("Time").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 413:  { return (15+Math.random()*5)*engine.getDouble("RoleLv").intValue();}
			case 414:  { return 100*engine.getDouble("RoleLv").intValue();}
			case 415:  { return 9.5*engine.getDouble("RoleLv").intValue();}
			case 416:  { return (1000*engine.getDouble("RoleLv").intValue()*0.194*1.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 417:  { return (1000*engine.getDouble("RoleLv").intValue()*0.1*(0.89+0.02*engine.getDouble("AnswerCnt").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 418:  { return 1000*Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)*0.35*(0.5+0.1*engine.getDouble("Saveid").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 419:  { return (1000*engine.getDouble("RoleLv").intValue()*0.215*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 420:  { return 1600*engine.getDouble("RoleLv").intValue()*0.067*(0.74+0.02*engine.getDouble("Time").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 421:  { return (1000*engine.getDouble("RoleLv").intValue()*0.194*1)*(Math.random()*(1.02-0.98)+0.98);}
			case 422:  { return engine.getDouble("RoleLv").intValue()*50;}
			case 423:  { return (1000*engine.getDouble("RoleLv").intValue()*0.1*(0.89+0.02*engine.getDouble("AnswerCnt").intValue()))*0.5*(Math.random()*(1.02-0.98)+0.98);}
			case 424:  { return 5000*engine.getDouble("RoleLv").intValue();}
			case 425:  { return (1000*engine.getDouble("RoleLv").intValue()*0.1*(0.79+0.02*engine.getDouble("AnswerCnt").intValue()))*0.5*(Math.random()*(1.02-0.98)+0.98);}
			case 426:  { return (engine.getDouble("StdMoney").intValue()*2)*(Math.random()*(1.05-0.95)+0.95);}
			case 427:  { return 250*engine.getDouble("RoleLv").intValue()*(Math.random()*(1.02-0.98)+0.98);}
			case 428:  { return (engine.getDouble("StdMoney").intValue()*6/28.1*((engine.getDouble("Ring").intValue()-1)*0.09+1))*(Math.random()*(1.05-0.95)+0.95);}
			case 429:  { return (1+14*engine.getDouble("IsDbPoint").intValue()+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdMoney").intValue()*1.5/74*((engine.getDouble("Ring").intValue()-1)*0.09+1))*(Math.random()*(1.2-0.8)+0.8);}
			case 430:  { return 4000+6000*Math.random();}
			case 431:  { return (1000*engine.getDouble("RoleLv").intValue()*0.05*(0.79+0.02*engine.getDouble("AnswerCnt").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 432:  { return (1*Math.min(Math.max(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenLv").intValue()),engine.getDouble("FuBenLv").intValue()+9)*5)*(Math.random()*(1.02-0.98)+0.98);}
			case 433:  { return (1*engine.getDouble("RoleLv").intValue()*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 434:  { return (1*engine.getDouble("RoleLv").intValue()*1.256*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 435:  { return (1*engine.getDouble("RoleLv").intValue()*0.717*2*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 436:  { return (1*engine.getDouble("RoleLv").intValue()*0.775*2*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 437:  { return (1*engine.getDouble("RoleLv").intValue()*6.66)*(Math.random()*(1.02-0.98)+0.98);}
			case 438:  { return engine.getDouble("RoleLv").intValue()*1.7+20;}
			case 439:  { return (1*Math.min(Math.max(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenLv").intValue()),engine.getDouble("FuBenLv").intValue()+9)*5)*(Math.random()*(2.02-0.98)+0.98);}
			case 440:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*2;}
			case 441:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*5;}
			case 442:  { return engine.getDouble("RoleLv").intValue()*5;}
			case 443:  { return (1*engine.getDouble("RoleLv").intValue()*0.717*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 444:  { return engine.getDouble("MonsterLv").intValue()+20;}
			case 445:  { return (1*engine.getDouble("TeamLv").intValue()*0.196*(0.78+0.04*engine.getDouble("Ring").intValue())*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 446:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*3;}
			case 447:  { return (1*engine.getDouble("RoleLv").intValue()*0.94)*(Math.random()*(1.02-0.98)+0.98);}
			case 448:  { return (1*engine.getDouble("RoleLv").intValue()*0.775*2*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 449:  { return (1*engine.getDouble("RoleLv").intValue()*1.3)*(Math.random()*(1.02-0.98)+0.98);}
			case 450:  { return (1*engine.getDouble("RoleLv").intValue()*1.256*2*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 451:  { return 1*engine.getDouble("RoleLv").intValue()*0.667*2*(3.5+0.5*(Math.floor((engine.getDouble("Time").intValue()-1)/5)+1))*Math.floor(1-(engine.getDouble("Time").intValue()%5)*0.2)*(Math.random()*(1.02-0.98)+0.98);}
			case 452:  { return (engine.getDouble("MonsterLv").intValue()-30)*0.2+4;}
			case 453:  { return (1*engine.getDouble("RoleLv").intValue()*0.775*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 454:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*4;}
			case 455:  { return (1*engine.getDouble("RoleLv").intValue()*11)*(Math.random()*(1.02-0.98)+0.98);}
			case 456:  { return (1*engine.getDouble("RoleLv").intValue()*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 457:  { return (15)+(engine.getDouble("TeamNum").intValue()-1)*15+engine.getDouble("RoleLv").intValue()*1;}
			case 458:  { return (1*engine.getDouble("RoleLv").intValue()*1)*(Math.random()*(1.02-0.98)+0.98);}
			case 459:  { return (1*engine.getDouble("RoleLv").intValue()*1.256*2*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 460:  { return (engine.getDouble("IsDbPoint").intValue()*(engine.getDouble("Ring").intValue()-1)*1+6);}
			case 461:  { return (1*engine.getDouble("RoleLv").intValue()*4)*(Math.random()*(1.02-0.98)+0.98);}
			case 462:  { return (1*engine.getDouble("RoleLv").intValue()*0.717*2*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 463:  { return (1*engine.getDouble("RoleLv").intValue()*5)*(Math.random()*(1.02-0.98)+0.98);}
			case 464:  { return (1*engine.getDouble("RoleLv").intValue()*8)*(Math.random()*(1.02-0.98)+0.98);}
			case 465:  { return (1*engine.getDouble("RoleLv").intValue()*1.333)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 466:  { return 2.5*engine.getDouble("RoleLv").intValue()*(Math.random()*(1.02-0.98)+0.98);}
			case 467:  { return 2.22*engine.getDouble("RoleLv").intValue()*(Math.random()*(1.02-0.98)+0.98);}
			case 468:  { return 3.4*engine.getDouble("RoleLv").intValue()*(Math.random()*(1.02-0.98)+0.98);}
			case 469:  { return 1.38*engine.getDouble("RoleLv").intValue()*(Math.random()*(1.02-0.98)+0.98);}
			case 470:  { return Math.max(Math.floor((engine.getDouble("Ring").intValue()-4)/2),0);}
			case 471:  { return (400*engine.getDouble("RoleLv").intValue()*0.25*(0.89+0.02*engine.getDouble("AnswerCnt").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 472:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+7*engine.getDouble("IsDbPoint").intValue()+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*10/63*((engine.getDouble("Ring").intValue()-1)*0.05+1));}
			case 473:  { return (400*engine.getDouble("RoleLv").intValue()*0.017)*(Math.random()*(1.02-0.98)+0.98);}
			case 474:  { return 2000*engine.getDouble("RoleLv").intValue();}
			case 475:  { return (400*engine.getDouble("RoleLv").intValue()*0.667)*(Math.random()*(1.02-0.98)+0.98)*0.5;}
			case 476:  { return (400*engine.getDouble("RoleLv").intValue()*1.099*3)*(Math.random()*(1.02-0.98)+0.98);}
			case 477:  { return (1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*5);}
			case 478:  { return (1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*13.333/28.867*((engine.getDouble("Ring").intValue()-1)*0.08+1)+engine.getDouble("RoleLv").intValue()*50-1000);}
			case 479:  { return (400*engine.getDouble("RoleLv").intValue()*0.5*(0.79+0.02*engine.getDouble("AnswerCnt").intValue()))*0.5*(Math.random()*(1.02-0.98)+0.98);}
			case 480:  { return (400*engine.getDouble("TeamLv").intValue()*0.3*(1-engine.getDouble("IsDbPoint").intValue())+400*engine.getDouble("TeamLv").intValue()*1.244*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 481:  { return (400*engine.getDouble("RoleLv").intValue()*0.678*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 482:  { return (8000*engine.getDouble("RoleLv").intValue()*1.8)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 483:  { return (engine.getDouble("StdExp").intValue()*13.333/28.867*((engine.getDouble("Ring").intValue()-1)*0.08+1)+engine.getDouble("RoleLv").intValue()*50-1000);}
			case 484:  { return (400*engine.getDouble("RoleLv").intValue()*0.278*(0.78+0.04*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 485:  { return 400*engine.getDouble("RoleLv").intValue()*0.875*(0.91+0.02*((engine.getDouble("Ring").intValue()-1)%8+1))*(0.58+0.04*(Math.floor((engine.getDouble("Ring").intValue()-1)/8)+1));}
			case 486:  { return 4000*engine.getDouble("RoleLv").intValue();}
			case 487:  { return (400*engine.getDouble("MonsterLv").intValue()*0.011*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*(1-engine.getDouble("IsDbPoint").intValue())+400*engine.getDouble("MonsterLv").intValue()*0.13*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 488:  { return (400*engine.getDouble("RoleLv").intValue()*1.099*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1))*0.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 489:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*6.6667/8*((engine.getDouble("Ring").intValue()-1)*0.3+1));}
			case 490:  { return (175+Math.random()*50)*engine.getDouble("RoleLv").intValue();}
			case 491:  { return 400*engine.getDouble("RoleLv").intValue()*1.215*(0.88+0.03);}
			case 492:  { return (400*engine.getDouble("RoleLv").intValue()*0.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 493:  { return 500*engine.getDouble("RoleLv").intValue()*1.215*(0.88+0.03);}
			case 494:  { return (400*engine.getDouble("RoleLv").intValue()*0.628*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 495:  { return engine.getDouble("StdExp").intValue()*0.83/14.5*((engine.getDouble("Ring").intValue()-1)*0.1+1);}
			case 496:  { return engine.getDouble("StdExp").intValue()*7*2.86/168*8;}
			case 497:  { return (400*engine.getDouble("RoleLv").intValue()*1.25)*(Math.random()*(1.02-0.98)+0.98);}
			case 498:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),94)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 499:  { return (400*engine.getDouble("RoleLv").intValue()*0.833)*(Math.random()*(1.02-0.98)+0.98);}
			case 500:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*6.7/5);}
			case 501:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*6.7/10)*((engine.getDouble("TeamNum").intValue()-1)*0.05+1);}
			case 502:  { return 400*engine.getDouble("RoleLv").intValue()*1*(0.74+0.02*engine.getDouble("Time").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 503:  { return (400*engine.getDouble("RoleLv").intValue()*0.678*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 504:  { return (400*engine.getDouble("RoleLv").intValue()*0.628*0.6);}
			case 505:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*2.14*7/8*((engine.getDouble("Ring").intValue()-1)*0.3+1));}
			case 506:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*6.7);}
			case 507:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),74)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 508:  { return (400*engine.getDouble("RoleLv").intValue()*0.678*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1))*0.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 509:  { return (1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*0.83/14.5*((engine.getDouble("Ring").intValue()-1)*0.1+1));}
			case 510:  { return 400*engine.getDouble("RoleLv").intValue()*0.656*(0.82+0.04*((engine.getDouble("Ring").intValue()-1)%8+1))*(0.58+0.04*(Math.floor((engine.getDouble("Ring").intValue()-1)/8)+1));}
			case 511:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*6.7/15);}
			case 512:  { return (1000*engine.getDouble("TeamLv").intValue()*0.15*(0.78+0.04*engine.getDouble("Ring").intValue())*(1-engine.getDouble("IsDbPoint").intValue())+400*engine.getDouble("TeamLv").intValue()*1.02*(0.78+0.04*engine.getDouble("Ring").intValue())*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(2+0.05*engine.getDouble("IsTL").intValue());}
			case 513:  { return (400*engine.getDouble("RoleLv").intValue()*1.099*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 514:  { return (400*engine.getDouble("RoleLv").intValue()*0.628*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1)))*(Math.random()*(1.02-0.98)+0.98);}
			case 515:  { return (400*engine.getDouble("RoleLv").intValue()*0.628*(0.95+0.05*(engine.getDouble("PVPCnt").intValue()+1))*(0.95+0.05*(engine.getDouble("PVPTargetCnt").intValue()+1))*0.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 516:  { return (400*engine.getDouble("TeamLv").intValue()*0.15*(0.78+0.04*engine.getDouble("Ring").intValue())*(1-engine.getDouble("IsDbPoint").intValue())+400*engine.getDouble("TeamLv").intValue()*1.02*(0.78+0.04*engine.getDouble("Ring").intValue())*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 517:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),59)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 518:  { return (400*engine.getDouble("RoleLv").intValue()*0.694*(0.78+0.04*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 519:  { return (400*engine.getDouble("RoleLv").intValue()*1)*(Math.random()*(1.02-0.98)+0.98);}
			case 520:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)*0.35*(0.5+0.1*engine.getDouble("Saveid").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 521:  { return (1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*0.2);}
			case 522:  { return engine.getDouble("RoleLv").intValue()*200;}
			case 523:  { return (400*engine.getDouble("RoleLv").intValue()*0.7)*(Math.random()*(1.02-0.98)+0.98);}
			case 524:  { return (400*engine.getDouble("RoleLv").intValue()*1.215*1)*(Math.random()*(1.02-0.98)+0.98);}
			case 525:  { return engine.getDouble("RoleLv").intValue()*100;}
			case 526:  { return 400*engine.getDouble("RoleLv").intValue()*1.215*(0.85+0.03*((engine.getDouble("Time").intValue()-1)%9+1))*(0.9+0.1*(Math.floor((engine.getDouble("Time").intValue()-1)/9)+1))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 527:  { return (500*engine.getDouble("TeamLv").intValue()*0.15*(0.78+0.04*engine.getDouble("Ring").intValue())*(1-engine.getDouble("IsDbPoint").intValue())+400*engine.getDouble("TeamLv").intValue()*1.02*(0.78+0.04*engine.getDouble("Ring").intValue())*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 528:  { return (400*engine.getDouble("RoleLv").intValue()*1.099*0.6);}
			case 529:  { return (400*engine.getDouble("RoleLv").intValue()*2.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 530:  { return (400*Math.min(Math.max(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenLv").intValue()),engine.getDouble("FuBenLv").intValue()+9)*2*(0.7+0.1*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 531:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)*0.35*(0.75+0.05*engine.getDouble("Saveid").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 532:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),49)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 533:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)*0.35*(0.75+0.05*engine.getDouble("Saveid").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 534:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*6);}
			case 535:  { return (400*engine.getDouble("RoleLv").intValue()*0.25*(0.89+0.02*engine.getDouble("AnswerCnt").intValue()))*0.5*(Math.random()*(1.02-0.98)+0.98);}
			case 536:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),84)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 537:  { return (400*engine.getDouble("RoleLv").intValue()*0.25*(0.79+0.02*engine.getDouble("AnswerCnt").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 538:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),89)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 539:  { return (105+Math.random()*30)*engine.getDouble("RoleLv").intValue();}
			case 540:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),99)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 541:  { return 3000*engine.getDouble("RoleLv").intValue();}
			case 542:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)*0.0392*(0.4+0.1*engine.getDouble("Saveid").intValue());}
			case 543:  { return (400*engine.getDouble("RoleLv").intValue()*1.215*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 544:  { return (400*engine.getDouble("MonsterLv").intValue()*0.017*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*(1-engine.getDouble("IsDbPoint").intValue())+400*engine.getDouble("MonsterLv").intValue()*0.13*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 545:  { return (7000*engine.getDouble("RoleLv").intValue()*1.8)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 546:  { return (400*engine.getDouble("RoleLv").intValue()*1.215*1.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 547:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+7*engine.getDouble("IsDbPoint").intValue()+engine.getDouble("IsSerMul").intValue())*(engine.getDouble("StdExp").intValue()*10/63*(14*0.05+1));}
			case 548:  { return engine.getDouble("StdExp").intValue()*5/10*(Math.random()*(1.2-0.8)+0.8);}
			case 549:  { return (400*Math.min(Math.max(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenLv").intValue()),engine.getDouble("FuBenLv").intValue()+9)*1*(0.7+0.1*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 550:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),79)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 551:  { return (400*engine.getDouble("RoleLv").intValue()*0.5*(0.79+0.02*engine.getDouble("AnswerCnt").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 552:  { return (7500*engine.getDouble("RoleLv").intValue()*1.8)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 553:  { return (400*engine.getDouble("RoleLv").intValue()*0.678*0.6);}
			case 554:  { return (400*engine.getDouble("RoleLv").intValue()*0.25*(0.79+0.02*engine.getDouble("AnswerCnt").intValue()))*0.5*(Math.random()*(1.02-0.98)+0.98);}
			case 555:  { return (1000*engine.getDouble("RoleLv").intValue()*1.8)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 556:  { return (400*engine.getDouble("RoleLv").intValue()*2.222)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 557:  { return 400*Math.min(engine.getDouble("RoleLv").intValue(),69)*0.35*(0.75+0.05*10)*(Math.random()*(1.02-0.98)+0.98);}
			case 558:  { return engine.getDouble("Ring").intValue()+1;}
			case 559:  { return engine.getDouble("Ring").intValue()+5;}
			case 560:  { return 2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)/10)*40*engine.getDouble("Saveid").intValue());}
			case 561:  { return 2200+Math.floor(engine.getDouble("RoleLv").intValue()/10)*440+(200+Math.floor(engine.getDouble("RoleLv").intValue()/10)*40*(engine.getDouble("Ring").intValue()-1));}
			case 562:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),74)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),74)/10)*40*10))*2;}
			case 563:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),84)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),84)/10)*40*10))*2;}
			case 564:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),99)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),99)/10)*40*10))*2;}
			case 565:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)/10)*40*engine.getDouble("Saveid").intValue()))*2;}
			case 566:  { return 105800+Math.floor(engine.getDouble("RoleLv").intValue()/10)*440+(200+Math.floor(engine.getDouble("RoleLv").intValue()/10)*40*(engine.getDouble("Ring").intValue()-1));}
			case 567:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),89)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),89)/10)*40*10))*2;}
			case 568:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),79)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),79)/10)*40*10))*2;}
			case 569:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),69)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),69)/10)*40*10))*2;}
			case 570:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),49)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),49)/10)*40*10))*2;}
			case 571:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),94)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),94)/10)*40*10))*2;}
			case 572:  { return (2200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),59)/10)*440+(200+Math.floor(Math.min(engine.getDouble("RoleLv").intValue(),59)/10)*40*10))*2;}
			case 573:  { return engine.getDouble("SwXs").intValue()*1;}
			case 574:  { return (5000*engine.getDouble("RoleLv").intValue()*0.05)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 575:  { return (5000*Math.min(Math.max(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenLv").intValue()),engine.getDouble("FuBenLv").intValue()+9)*0.2*(0.7+0.1*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 576:  { return (5000*engine.getDouble("MonsterLv").intValue()*0.05)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 577:  { return (5000*engine.getDouble("TeamLv").intValue()*0.05*(1-engine.getDouble("IsDbPoint").intValue())+5000*engine.getDouble("TeamLv").intValue()*0.124*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 578:  { return (5000*engine.getDouble("RoleLv").intValue()*0.049*1.5)*(Math.random()*(1.02-0.98)+0.98);}
			case 579:  { return (5000*engine.getDouble("RoleLv").intValue()*0.1)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 580:  { return (5000*engine.getDouble("RoleLv").intValue()*0.05*(0.78+0.04*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98);}
			case 581:  { return (1+engine.getDouble("IsSerMul").intValue())*(5000*engine.getDouble("RoleLv").intValue()*0.5/20);}
			case 582:  { return (5000*engine.getDouble("RoleLv").intValue()*0.05)*(Math.random()*(1.02-0.98)+0.98)*0.5;}
			case 583:  { return (1+0.05*engine.getDouble("IsTL").intValue())*(1+1.5*engine.getDouble("IsDbPoint").intValue()+engine.getDouble("IsSerMul").intValue())*(5000*engine.getDouble("RoleLv").intValue()*1.25/50);}
			case 584:  { return (5000*Math.min(Math.max(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenLv").intValue()),engine.getDouble("FuBenLv").intValue()+9)*0.1*(0.7+0.1*engine.getDouble("Ring").intValue()))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 585:  { return (5000*engine.getDouble("MonsterLv").intValue()*0.011*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*(1-engine.getDouble("IsDbPoint").intValue())+5000*engine.getDouble("MonsterLv").intValue()*0.02*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 586:  { return 5000*engine.getDouble("RoleLv").intValue()*0.1*(0.74+0.02*engine.getDouble("Time").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 587:  { return 5000*Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)*0.058*(0.5+0.1*engine.getDouble("Saveid").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 588:  { return (5000*engine.getDouble("RoleLv").intValue()*0.111)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 589:  { return (5000*engine.getDouble("TeamLv").intValue()*0.025*(0.78+0.04*engine.getDouble("Ring").intValue())*(1-engine.getDouble("IsDbPoint").intValue())+5000*engine.getDouble("TeamLv").intValue()*0.102*(0.78+0.04*engine.getDouble("Ring").intValue())*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15)*(1+0.05*engine.getDouble("IsTL").intValue());}
			case 590:  { return engine.getDouble("RoleLv").intValue()*100*30/5;}
			case 591:  { return (5000*engine.getDouble("MonsterLv").intValue()*0.017*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*(1-engine.getDouble("IsDbPoint").intValue())+5000*engine.getDouble("MonsterLv").intValue()*0.02*(engine.getDouble("MonsterNum").intValue()*0.083+engine.getDouble("MasterNum").intValue()*0.1245)*Math.min(Math.max(1-0.2*Math.floor(Math.abs(engine.getDouble("MonsterLv").intValue()-engine.getDouble("RoleLv").intValue())/5),0.1),1)*engine.getDouble("IsDbPoint").intValue())*(Math.random()*(1.02-0.98)+0.98);}
			case 592:  { return 5000*Math.min(engine.getDouble("RoleLv").intValue(),engine.getDouble("FuBenId").intValue()*10-1051-Math.floor(engine.getDouble("FuBenId").intValue()/113)*5)*0.058*(0.75+0.05*engine.getDouble("Saveid").intValue())*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 593:  { return (5000*engine.getDouble("RoleLv").intValue()*0.1)*(Math.random()*(1.02-0.98)+0.98);}
			case 594:  { return (5000*engine.getDouble("RoleLv").intValue()*0.15)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 595:  { return (5000*engine.getDouble("RoleLv").intValue()*0.075)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 596:  { return (500*engine.getDouble("RoleLv").intValue()*0.05)*(Math.random()*(1.02-0.98)+0.98)*0.5;}
			case 597:  { return 5000*engine.getDouble("RoleLv").intValue()*0.049*(0.85+0.03*((engine.getDouble("Time").intValue()-1)%9+1))*(0.9+0.1*(Math.floor((engine.getDouble("Time").intValue()-1)/9)+1))*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 598:  { return (5000*engine.getDouble("RoleLv").intValue()*0.049*1)*(Math.random()*(1.02-0.98)+0.98);}
			case 599:  { return (5000*engine.getDouble("RoleLv").intValue()*0.125)*(Math.random()*(1.02-0.98)+0.98)*(1-Math.min(5-engine.getDouble("TeamNum").intValue(),2)*0.15);}
			case 600:  { return (5000*engine.getDouble("RoleLv").intValue()*0.049*2)*(Math.random()*(1.02-0.98)+0.98);}
			case 601:  { return Math.min(Math.max(engine.getDouble("rolenum").intValue()*0.004,8),16);}
			case 602:  { return Math.min(Math.max(engine.getDouble("rolenum").intValue()*0.001,2),4)+(engine.getDouble("ServerLv").intValue()-50)*0.2;}
			case 603:  { return Math.floor((Math.min(Math.max(Math.floor((engine.getDouble("ServerLv").intValue()-40)*0.2),0),4)*3+6)*Math.min(Math.max(engine.getDouble("rolenum").intValue()*0.0005,1),2));}
			case 604:  { return null;}
			case 605:  { return Math.floor((Math.min(Math.max(Math.floor((engine.getDouble("ServerLv").intValue()-50)*0.2),0),3)*2+3)*Math.min(Math.max(engine.getDouble("rolenum").intValue()*0.0005,1),2));}
			case 606:  { return engine.getDouble("_94023_")>=1;}
			case 607:  { return engine.getDouble("_94024_")>=1;}
			case 608:  { return engine.getDouble("_94029_")>=1;}
			case 609:  { return engine.getDouble("_94033_")>=2;}
			case 610:  { return engine.getDouble("_94034_")<1;}
			case 611:  { return engine.getDouble("_94046_")<1&&engine.getDouble("_94045_")>=3;}
			case 612:  { return engine.getDouble("_94031_")>=3;}
			case 613:  { return engine.getDouble("_94035_")>=1;}
			case 614:  { return engine.getDouble("_94027_")>=1&&engine.getDouble("_94053_")<1;}
			case 615:  { return engine.getDouble("_94036_")>=2;}
			case 616:  { return engine.getDouble("_94040_")<1;}
			case 617:  { return engine.getDouble("_94039_")>=1;}
			case 618:  { return engine.getDouble("_94038_")>=2||engine.getDouble("_94028_")>=1;}
			case 619:  { return engine.getDouble("_94056_")>=2;}
			case 620:  { return engine.getDouble("_94054_")>=1;}
			case 621:  { return engine.getDouble("_94026_")>=1;}
			case 622:  { return engine.getDouble("_94001_")>=1;}
			case 623:  { return engine.getDouble("_94002_")>=1;}
			case 624:  { return engine.getDouble("_94003_")>=1;}
			case 625:  { return engine.getDouble("_94004_")>=1;}
			case 626:  { return engine.getDouble("_94005_")>=5;}
			case 627:  { return engine.getDouble("_94005_")>=3;}
			case 628:  { return engine.getDouble("_94005_")>=1;}
			case 629:  { return engine.getDouble("_94006_")<3;}
			case 630:  { return engine.getDouble("_94007_")>=2&&engine.getDouble("_94011_")>=1;}
			case 631:  { return engine.getDouble("_94007_")>=2;}
			case 632:  { return engine.getDouble("_94008_")>=1;}
			case 633:  { return engine.getDouble("_94009_")<1;}
			case 634:  { return engine.getDouble("_94012_")>=2;}
			case 635:  { return engine.getDouble("_94013_")>=1;}
			case 636:  { return engine.getDouble("_94016_")>=1;}
			case 637:  { return engine.getDouble("_94014_")>=1;}
			case 638:  { return engine.getDouble("_94015_")>=1;}
			case 639:  { return engine.getDouble("_94017_")<1;}
			case 640:  { return engine.getDouble("_94006_")<3&&engine.getDouble("_94005_")>=1;}
			case 641:  { return engine.getDouble("_94003_")>=1&&engine.getDouble("_94006_")>=3;}
			case 642:  { return engine.getDouble("_94003_")>=1&&engine.getDouble("_94006_")<3;}
			case 643:  { return engine.getDouble("_94019_")<1;}
			case 644:  { return opf.getFighterBean().getInitattrs().get(1010)>=0;}
			case 645:  { return engine.getDouble("_94020_")>=1;}
			case 646:  { return engine.getDouble("_94021_")>=1;}
			case 647:  { return engine.getDouble("_94022_")>=1;}
			case 648:  { return engine.getDouble("_94025_")>=1&&engine.getDouble("_99075_")>=1;}
			case 649:  { return engine.getDouble("_94026_")>=1&&engine.getDouble("_99075_")>=1;}
			case 650:  { return engine.getDouble("_99076_")>=1&&engine.getDouble("_99075_")>=1;}
			case 651:  { return engine.getDouble("_94025_")>=1&&engine.getDouble("_94030_")>=3;}
			case 652:  { return engine.getDouble("_94025_")>=1&&engine.getDouble("_94030_")==2;}
			case 653:  { return engine.getDouble("_94025_")>=1&&engine.getDouble("_94030_")==1;}
			case 654:  { return engine.getDouble("_99076_")>=1;}
			case 655:  { return engine.getDouble("_94030_")>=3;}
			case 656:  { return engine.getDouble("_94030_")==2&&engine.getDouble("_94029_")>=1;}
			case 657:  { return engine.getDouble("_94030_")==2;}
			case 658:  { return engine.getDouble("_94030_")==1;}
			case 659:  { return engine.getDouble("_94044_")>=1&&engine.getDouble("_94057_")<1;}
			case 660:  { return engine.getDouble("_94044_")>=1&&engine.getDouble("_94057_")>=1;}
			case 661:  { return engine.getDouble("_94037_")>=1;}
			case 662:  { return engine.getDouble("_94038_")>=2;}
			case 663:  { return engine.getDouble("_94028_")>=1;}
			case 664:  { return opf.getFighterBean().getInitattrs().get(1010)<1;}
			case 665:  { return engine.getDouble("_99065_")>=4;}
			case 666:  { return engine.getDouble("_94044_")>=1;}
			case 667:  { return engine.getDouble("_95001_")>=1;}
			case 668:  { return engine.getDouble("_95002_")==1;}
			case 669:  { return engine.getDouble("_95009_")==1;}
			case 670:  { return engine.getDouble("_95013_")==1;}
			case 671:  { return engine.getDouble("_95010_")>=1;}
			case 672:  { return engine.getDouble("_95003_")<=1;}
			case 673:  { return engine.getDouble("_95017_")==1;}
			case 674:  { return engine.getDouble("_95018_")<=1;}
			case 675:  { return engine.getDouble("_95020_")==1;}
			case 676:  { return engine.getDouble("_95021_")==1;}
			case 677:  { return engine.getDouble("_95024_")<=0;}
			case 678:  { return engine.getDouble("_95028_")==1;}
			case 679:  { return engine.getDouble("_95025_")==1;}
			case 680:  { return engine.getDouble("_95030_")>=1;}
			case 681:  { return engine.getDouble("_95035_")>=1;}
			case 682:  { return engine.getDouble("_95036_")>=1;}
			case 683:  { return engine.getDouble("_95039_")<1;}
			case 684:  { return engine.getDouble("_95038_")>=1;}
			case 685:  { return engine.getDouble("_95037_")>=2||engine.getDouble("_95040_")>=1;}
			case 686:  { return engine.getDouble("_95041_")>=2;}
			case 687:  { return engine.getDouble("_95042_")>=1;}
			case 688:  { return engine.getDouble("_95043_")>=3;}
			case 689:  { return engine.getDouble("_95044_")>=1;}
			case 690:  { return engine.getDouble("_95045_")>=1;}
			case 691:  { return engine.getDouble("_95046_")<=2;}
			case 692:  { return engine.getDouble("_95047_")>=2;}
			case 693:  { return engine.getDouble("_95048_")>=1;}
			case 694:  { return engine.getDouble("_95049_")>=2||engine.getDouble("_95054_")>=1;}
			case 695:  { return engine.getDouble("_95050_")>=1;}
			case 696:  { return engine.getDouble("_95051_")>=2;}
			case 697:  { return engine.getDouble("_95052_")>=2;}
			case 698:  { return engine.getDouble("_95053_")==1;}
			case 699:  { return engine.getDouble("_95041_")>=3;}
			case 700:  { return engine.getDouble("_95055_")>=1;}
			case 701:  { return engine.getDouble("_95058_")>=1;}
			case 702:  { return engine.getDouble("_95059_")>=1;}
			case 703:  { return engine.getDouble("_95052_")>=1;}
			case 704:  { return engine.getDouble("_95060_")>=1;}
			case 705:  { return engine.getDouble("_95018_")==1;}
			case 706:  { return engine.getDouble("_95057_")==1;}
			case 707:  { return engine.getDouble("_95062_")==1;}
			case 708:  { return engine.getDouble("_95073_")==1;}
			case 709:  { return engine.getDouble("_95063_")==1;}
			case 710:  { return engine.getDouble("_95057_")<1;}
			case 711:  { return engine.getDouble("_95064_")>=2;}
			case 712:  { return engine.getDouble("_95065_")>=3;}
			case 713:  { return engine.getDouble("_95074_")==1;}
			case 714:  { return engine.getDouble("_95075_")==1;}
			case 715:  { return engine.getDouble("_95076_")==1;}
			case 716:  { return engine.getDouble("_95046_")<=1;}
			case 717:  { return engine.getDouble("_95077_")>=2;}
			case 718:  { return engine.getDouble("_95078_")<1;}
			case 719:  { return engine.getDouble("_95080_")==1;}
			case 720:  { return engine.getDouble("_95079_")<1;}
			case 721:  { return engine.getDouble("_95081_")<1;}
			case 722:  { return engine.getDouble("_95082_")>=2;}
			case 723:  { return engine.getDouble("_95086_")>=1;}
			case 724:  { return engine.getDouble("_95083_")==1;}
			case 725:  { return engine.getDouble("_95084_")<1;}
			case 726:  { return engine.getDouble("_95085_")>=2&&engine.getDouble("_95089_")<1;}
			case 727:  { return engine.getDouble("_95086_")>=1&&engine.getDouble("_95087_")<1;}
			case 728:  { return engine.getDouble("_95082_")>=3;}
			case 729:  { return engine.getDouble("_95057_")>=1;}
			case 730:  { return engine.getDouble("_95088_")<=0;}
			case 731:  { return engine.getDouble("_96001_")/engine.getDouble("_96002_")>=0.2;}
			case 732:  { return engine.getDouble("_96001_")/engine.getDouble("_96002_")<0.2;}
			case 733:  { return engine.getDouble("_96004_")>=4;}
			case 734:  { return engine.getDouble("_96003_")>=1;}
			case 735:  { return engine.getDouble("_96124_")<=0.01;}
			case 736:  { return engine.getDouble("_96015_")==1;}
			case 737:  { return engine.getDouble("_96016_")>=1||engine.getDouble("_96018_")>=1;}
			case 738:  { return engine.getDouble("_96016_")<1&&engine.getDouble("_96018_")<1;}
			case 739:  { return engine.getDouble("_96017_")<1;}
			case 740:  { return engine.getDouble("_96107_")>=1;}
			case 741:  { return engine.getDouble("_96103_")>=1;}
			case 742:  { return engine.getDouble("_96108_")>=1;}
			case 743:  { return engine.getDouble("_96106_")>=1;}
			case 744:  { return engine.getDouble("_96104_")>=1;}
			case 745:  { return engine.getDouble("_96105_")>=1;}
			case 746:  { return engine.getDouble("_96109_")>=1;}
			case 747:  { return engine.getDouble("_96110_")>=1;}
			case 748:  { return engine.getDouble("_96111_")>=1;}
			case 749:  { return engine.getDouble("_96101_")==1;}
			case 750:  { return engine.getDouble("_96102_")>=1;}
			case 751:  { return engine.getDouble("_96113_")<1;}
			case 752:  { return engine.getDouble("_96120_")>=1;}
			case 753:  { return engine.getDouble("_96121_")>=1;}
			case 754:  { return engine.getDouble("_96122_")<1;}
			case 755:  { return engine.getDouble("_96123_")>=1;}
			case 756:  { return engine.getDouble("_99002_")<1;}
			case 757:  { return engine.getDouble("_96301_")>=1;}
			case 758:  { return engine.getDouble("_96302_")>=1;}
			case 759:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96307_")<1;}
			case 760:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96308_")<1;}
			case 761:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96309_")<1;}
			case 762:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96310_")<1;}
			case 763:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96311_")<1;}
			case 764:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96362_")<1;}
			case 765:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96363_")<1;}
			case 766:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96364_")<1;}
			case 767:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96365_")<1;}
			case 768:  { return engine.getDouble("_96301_")>=1&&engine.getDouble("_96366_")<1;}
			case 769:  { return engine.getDouble("_96304_")<1;}
			case 770:  { return engine.getDouble("_96351_")>=1;}
			case 771:  { return engine.getDouble("_96352_")>=1;}
			case 772:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96357_")<1;}
			case 773:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96358_")<1;}
			case 774:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96359_")<1;}
			case 775:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96360_")<1;}
			case 776:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96361_")<1;}
			case 777:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96362_")<1;}
			case 778:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96363_")<1;}
			case 779:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96364_")<1;}
			case 780:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96365_")<1;}
			case 781:  { return engine.getDouble("_96351_")>=1&&engine.getDouble("_96366_")<1;}
			case 782:  { return engine.getDouble("_96354_")<1;}
			case 783:  { return engine.getDouble("_96401_")==1;}
			case 784:  { return engine.getDouble("_96402_")>=1||engine.getDouble("_96403_")>=1;}
			case 785:  { return engine.getDouble("_97001_")/engine.getDouble("_97002_")>=0.2;}
			case 786:  { return engine.getDouble("_97001_")/engine.getDouble("_97002_")<0.2;}
			case 787:  { return engine.getDouble("_97003_")>=1;}
			case 788:  { return engine.getDouble("_97004_")>=4;}
			case 789:  { return engine.getDouble("_97005_")==1;}
			case 790:  { return engine.getDouble("_96200_")>=4;}
			case 791:  { return engine.getDouble("_96201_")>=4;}
			case 792:  { return engine.getDouble("_96202_")>=4;}
			case 793:  { return engine.getDouble("_96203_")>=4;}
			case 794:  { return engine.getDouble("_96204_")>=1;}
			case 795:  { return engine.getDouble("_96205_")>=1;}
			case 796:  { return engine.getDouble("_96206_")>=4;}
			case 797:  { return engine.getDouble("_96207_")>=4;}
			case 798:  { return engine.getDouble("_96208_")<3;}
			case 799:  { return engine.getDouble("_96209_")>=1;}
			case 800:  { return engine.getDouble("_96210_")<3;}
			case 801:  { return engine.getDouble("_96211_")>=1;}
			case 802:  { return engine.getDouble("_96212_")>=1;}
			case 803:  { return engine.getDouble("_96213_")>=3;}
			case 804:  { return engine.getDouble("_96215_")>=4;}
			case 805:  { return engine.getDouble("_96216_")<=3;}
			case 806:  { return engine.getDouble("_96217_")<3;}
			case 807:  { return engine.getDouble("_96218_")>=1;}
			case 808:  { return engine.getDouble("_96125_")>1;}
			case 809:  { return engine.getDouble("_99001_")<1;}
			case 810:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99030_")==1;}
			case 811:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99004_")==1;}
			case 812:  { return engine.getDouble("_99003_")>=1&&engine.getDouble("_96124_")<=0.01;}
			case 813:  { return engine.getDouble("_99031_")>=1;}
			case 814:  { return engine.getDouble("_99032_")>=1;}
			case 815:  { return engine.getDouble("_99033_")>=1;}
			case 816:  { return engine.getDouble("_99034_")>=1;}
			case 817:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99010_")>=1;}
			case 818:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99011_")>=1;}
			case 819:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99012_")>=1;}
			case 820:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99013_")>=1;}
			case 821:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99014_")>=1;}
			case 822:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99015_")>=1;}
			case 823:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99016_")>=1;}
			case 824:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99017_")>=1;}
			case 825:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99018_")>=1;}
			case 826:  { return engine.getDouble("_99001_")<1&&engine.getDouble("_99019_")>=1;}
			case 827:  { return engine.getDouble("_94056_")>=1;}
			case 828:  { return engine.getDouble("_99036_")>=1;}
			case 829:  { return engine.getDouble("_99037_")>=1;}
			case 830:  { return engine.getDouble("_99038_")>=1;}
			case 831:  { return engine.getDouble("_99039_")>=1;}
			case 832:  { return engine.getDouble("_94056_")>=4;}
			case 833:  { return engine.getDouble("_95003_")<=2;}
			case 834:  { return engine.getDouble("_95003_")<=3;}
			case 835:  { return engine.getDouble("_95003_")<=4;}
			case 836:  { return engine.getDouble("_95003_")<=5;}
			case 837:  { return engine.getDouble("_95003_")<=6;}
			case 838:  { return engine.getDouble("_95003_")<=7;}
			case 839:  { return engine.getDouble("_95003_")<=8;}
			case 840:  { return engine.getDouble("_95003_")<=9;}
			case 841:  { return engine.getDouble("_95003_")<=10;}
			case 842:  { return engine.getDouble("_96232_")>=1;}
			case 843:  { return engine.getDouble("_96234_")>=1;}
			case 844:  { return engine.getDouble("_95003_")==3;}
			case 845:  { return engine.getDouble("_97001_")>=4;}
			case 846:  { return engine.getDouble("_99040_")>=2;}
			case 847:  { return engine.getDouble("_95003_")==4;}
			case 848:  { return engine.getDouble("_95003_")==5;}
			case 849:  { return engine.getDouble("_95003_")==6;}
			case 850:  { return engine.getDouble("_95003_")==7;}
			case 851:  { return engine.getDouble("_95003_")==8;}
			case 852:  { return engine.getDouble("_95003_")==9;}
			case 853:  { return engine.getDouble("_99041_")>=3;}
			case 854:  { return engine.getDouble("_99042_")>=3;}
			case 855:  { return engine.getDouble("_99043_")>=1;}
			case 856:  { return engine.getDouble("_99044_")<1;}
			case 857:  { return engine.getDouble("_99045_")<1;}
			case 858:  { return engine.getDouble("_99047_")>=1;}
			case 859:  { return engine.getDouble("_99048_")>=1;}
			case 860:  { return engine.getDouble("_94056_")>=3;}
			case 861:  { return engine.getDouble("_99049_")>=1;}
			case 862:  { return engine.getDouble("_99052_")>=1;}
			case 863:  { return engine.getDouble("_94014_")>=7;}
			case 864:  { return engine.getDouble("_99053_")>=1;}
			case 865:  { return engine.getDouble("_99054_")>=1;}
			case 866:  { return engine.getDouble("_99055_")>=1;}
			case 867:  { return engine.getDouble("_99056_")>=1;}
			case 868:  { return engine.getDouble("_99057_")>=1;}
			case 869:  { return engine.getDouble("_99058_")>=1;}
			case 870:  { return engine.getDouble("_99059_")>=1;}
			case 871:  { return engine.getDouble("_99060_")>=1;}
			case 872:  { return engine.getDouble("_99061_")>=1;}
			case 873:  { return engine.getDouble("_99053_")<1;}
			case 874:  { return engine.getDouble("_99054_")<1;}
			case 875:  { return engine.getDouble("_99055_")<1;}
			case 876:  { return engine.getDouble("_99056_")<1;}
			case 877:  { return engine.getDouble("_99057_")<1;}
			case 878:  { return engine.getDouble("_99058_")<1;}
			case 879:  { return engine.getDouble("_99059_")<1;}
			case 880:  { return engine.getDouble("_99060_")<1;}
			case 881:  { return engine.getDouble("_99061_")<1;}
			case 882:  { return engine.getDouble("_96001_")/engine.getDouble("_96002_")<0.1;}
			case 883:  { return engine.getDouble("_99062_")>=1;}
			case 884:  { return engine.getDouble("_99062_")>=2;}
			case 885:  { return engine.getDouble("_99062_")>=3;}
			case 886:  { return engine.getDouble("_99066_")>=1;}
			case 887:  { return engine.getDouble("_99067_")>=1;}
			case 888:  { return engine.getDouble("_99049_")>=5;}
			case 889:  { return engine.getDouble("_99068_")>=1;}
			case 890:  { return engine.getDouble("_99071_")>=1;}
			case 891:  { return engine.getDouble("_99070_")==1;}
			case 892:  { return engine.getDouble("_99072_")<1;}
			case 893:  { return engine.getDouble("_94041_")>=1;}
			case 894:  { return engine.getDouble("_99065_")>=3;}
			case 895:  { return engine.getDouble("_99074_")>=1;}
			case 896:  { return engine.getDouble("_96001_")>=1;}
			case 897:  { return engine.getDouble("_99077_")>=1;}
			case 898:  { return engine.getDouble("_99078_")>=1;}
			case 899:  { return (Boolean)engine.get("_502002_");}
			case 900:  { return (Boolean)engine.get("_502003_");}
			case 901:  { return !(Boolean)engine.get("_13_");}
			case 902:  { return (Boolean)engine.get("_509082_")||(Boolean)engine.get("_509083_");}
			case 903:  { return (Boolean)engine.get("_504002_");}
			case 904:  { return !(Boolean)engine.get("_504002_");}
			case 905:  { return !(Boolean)engine.get("_120_");}
			case 906:  { return (Boolean)engine.get("_120_");}
			case 907:  { return (Boolean)engine.get("_500033_");}
			case 908:  { return (Boolean)engine.get("_506003_");}
			case 909:  { return !(Boolean)engine.get("_506003_");}
			case 910:  { return (Boolean)engine.get("_501901_");}
			case 911:  { return (Boolean)engine.get("_502003_")||(Boolean)engine.get("_506002_");}
			case 912:  { return (Boolean)engine.get("_505005_")||(Boolean)engine.get("_504011_");}
			case 913:  { return !(Boolean)engine.get("_501010_")&&!(Boolean)engine.get("_13_");}
			case 914:  { return !(Boolean)engine.get("_501004_");}
			case 915:  { return (Boolean)engine.get("_509082_")||(Boolean)engine.get("_509083_")||(Boolean)engine.get("_506201_");}
			case 916:  { return (Boolean)engine.get("_506002_");}
			case 917:  { return (Boolean)engine.get("_501402_");}
			case 918:  { return !(Boolean)engine.get("_13_")&&!(Boolean)engine.get("_501008_");}
			case 919:  { return (Boolean)engine.get("_110_")||(Boolean)engine.get("_120_")||(Boolean)engine.get("_13_");}
			case 920:  { return (Boolean)engine.get("_506306_");}
			case 921:  { return (Boolean)engine.get("_503002_");}
			case 922:  { return (Boolean)engine.get("_504003_");}
			case 923:  { return !(Boolean)engine.get("_506109_");}
			case 924:  { return (Boolean)engine.get("_13_");}
			case 925:  { return (Boolean)engine.get("_504013_");}
			case 926:  { return !(Boolean)engine.get("_501010_");}
			case 927:  { return (Boolean)engine.get("_506109_");}
			case 928:  { return !(Boolean)engine.get("_506101_");}
			case 929:  { return !(Boolean)engine.get("_510139_");}
			case 930:  { return !(Boolean)engine.get("_506306_");}
			case 931:  { return !(Boolean)engine.get("_506201_");}
			case 932:  { return (Boolean)engine.get("_501010_");}
			case 933:  { return (Boolean)engine.get("_501004_");}
			case 934:  { return (Boolean)engine.get("_509082_")||(Boolean)engine.get("_509083_")||(Boolean)engine.get("_506201_")||(Boolean)engine.get("_509068_")||(Boolean)engine.get("_509031_");}
			case 935:  { return !(Boolean)engine.get("_502002_");}
			case 936:  { return (Boolean)engine.get("_110_")||(Boolean)engine.get("_120_");}
			case 937:  { return (Boolean)engine.get("_509201_");}
			case 938:  { return !(Boolean)engine.get("_508236_");}
			case 939:  { return !(Boolean)engine.get("_508237_");}
			case 940:  { return !(Boolean)engine.get("_509951_");}
			case 941:  { return !(Boolean)engine.get("_503001_");}
			case 942:  { return !(Boolean)engine.get("_501402_");}
			case 943:  { return !(Boolean)engine.get("_508002_");}
			case 944:  { return !(Boolean)engine.get("_508006_");}
			case 945:  { return (Boolean)engine.get("_509081_");}
			case 946:  { return (Boolean)engine.get("_503001_");}
			case 947:  { return !(Boolean)engine.get("_508014_");}
			case 948:  { return !(Boolean)engine.get("_508008_");}
			case 949:  { return 1*engine.getDouble("TeamNum").intValue()+3;}
			case 950:  { return engine.getDouble("TeamLv").intValue();}
			case 951:  { return 1*engine.getDouble("TeamNum").intValue()+5;}
			case 952:  { return 0*engine.getDouble("TeamNum").intValue()+4;}
			case 953:  { return 1*engine.getDouble("TeamNum").intValue()+4;}
			case 954:  { return 1*engine.getDouble("TeamNum").intValue();}
			case 955:  { return 0*engine.getDouble("TeamNum").intValue()+6+2*Math.random();}
			case 956:  { return 0*engine.getDouble("TeamNum").intValue()+8+2*Math.random();}
			case 957:  { return 0*engine.getDouble("TeamNum").intValue()+2;}
		}
		return null;
	}
}