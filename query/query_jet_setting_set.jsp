<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>   
<%@ page import="wguard.dao.DaoJetSettingTime"%>
<%@ page import="wguard.dao.DaoJetSettingTime.DaoJetSettingTimeRecord"%>
<%@ page import="wguard.dao.DaoJetSettingNomal"%>
<%@ page import="wguard.dao.DaoJetSettingNomal.DaoJetSettingNomalRecord"%>
<%@ page import="wguard.dao.DaoJetSettingFinedust"%>
<%@ page import="wguard.dao.DaoJetSettingFinedust.DaoJetSettingFinedustRecord"%>
<%@ page import="wguard.dao.DaoJetSettingHeatwave"%>
<%@ page import="wguard.dao.DaoJetSettingHeatwave.DaoJetSettingHeatwaveRecord"%>
<%
JSONObject joReturn = new JSONObject();


byte[] bytRequest = EtcUtils.readFile(request.getInputStream());
String strRequest = new String(bytRequest,"utf-8");
//JSONObject joReq = new JSONObject(strRequest);
JSONArray jaReq = new JSONArray(strRequest);



JSONObject joReq = null;

String strSTID =  "";
String strMonth = "";
String strSHour = "";
String strEHour = "";
String strNomalCount = "";
String strNomalInterval = "";
String strDustCount = "";
String strDustInterval = "";
String strHeatCount = "";
String strHeatInterval = "";

int nMonth = 0;
int nSHour = 0;
int nEHour = 0;
int nNomalCount = 0;
int nNomalInterval = 0;
int nDustCount = 0;
int nDustInterval = 0;
int nHeatCount = 0;
int nHeatInterval = 0;

DaoJetSettingTime daoJetSettingTime = new DaoJetSettingTime();
DaoJetSettingNomal daoJetSettingNomal = new DaoJetSettingNomal();
DaoJetSettingFinedust daoJetSettingFinedust = new DaoJetSettingFinedust();
DaoJetSettingHeatwave daoJetSettingHeatwave = new DaoJetSettingHeatwave();

for(int i=0; i < jaReq.length(); i++)
{
	joReq = (JSONObject)jaReq.get(i);

	strSTID =  joReq.optString("Stid","");
	strMonth = joReq.optString("Month","");
	strSHour = joReq.optString("Shour","");
	strEHour = joReq.optString("Ehour","");
	strNomalCount = joReq.optString("Ncount","");
	strNomalInterval = joReq.optString("Ninterval","");
	strDustCount = joReq.optString("Dcount","");
	strDustInterval = joReq.optString("Dinterval","");
	strHeatCount = joReq.optString("Hcount","");
	strHeatInterval = joReq.optString("Hinterval","");

	nMonth = Integer.parseInt(strMonth);
	nSHour = Integer.parseInt(strSHour);
	nEHour = Integer.parseInt(strEHour);
	nNomalCount = Integer.parseInt(strNomalCount);
	nNomalInterval = Integer.parseInt(strNomalInterval);
	nDustCount = Integer.parseInt(strDustCount);
	nDustInterval = Integer.parseInt(strDustInterval);
	nHeatCount = Integer.parseInt(strHeatCount);
	nHeatInterval = Integer.parseInt(strHeatInterval);


	daoJetSettingTime.updateTime(strSTID, nMonth, nSHour, nEHour);

	daoJetSettingNomal.updateNomal(strSTID, nMonth, nNomalCount, nNomalInterval);

	daoJetSettingFinedust.updateFinedust(strSTID, nMonth, nDustCount, nDustInterval);

	daoJetSettingHeatwave.updateHeatwave(strSTID, nMonth, nHeatCount, nHeatInterval);

}



joReturn.put("result","OK");
joReturn.put("msg","success");
	
out.println(joReturn.toString());
return ;
%>