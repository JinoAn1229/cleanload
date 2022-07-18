<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoJetSettingTime"%>
<%@ page import="wguard.dao.DaoJetSettingTime.DaoJetSettingTimeRecord"%>
<%@ page import="wguard.dao.DaoJetSettingNomal"%>
<%@ page import="wguard.dao.DaoJetSettingNomal.DaoJetSettingNomalRecord"%>
<%@ page import="wguard.dao.DaoJetSettingFinedust"%>
<%@ page import="wguard.dao.DaoJetSettingFinedust.DaoJetSettingFinedustRecord"%>
<%@ page import="wguard.dao.DaoJetSettingHeatwave"%>
<%@ page import="wguard.dao.DaoJetSettingHeatwave.DaoJetSettingHeatwaveRecord"%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	

	JSONObject joReturn = new JSONObject();

	String strSTID = EtcUtils.NullS(request.getParameter("stid"));
	HashMap<String, JSONObject> mapSensor = new HashMap<String, JSONObject>();
	
	if(strSTID.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter not found");
		out.println(joReturn.toString());
		return ;
	}
	
	DaoJetSettingTime daoJetSettingTime = new DaoJetSettingTime();
	DaoJetSettingNomal daoJetSettingNomal = new DaoJetSettingNomal();
	DaoJetSettingFinedust daoJetSettingFinedust = new DaoJetSettingFinedust();
	DaoJetSettingHeatwave daoJetSettingHeatwave = new DaoJetSettingHeatwave();

	ArrayList<DaoJetSettingTimeRecord> aryTimeJetSetting =  daoJetSettingTime.selectJetSettingTime(strSTID,true);
	ArrayList<DaoJetSettingNomalRecord> aryNomalJetSetting =  daoJetSettingNomal.selectJetSettingNomal(strSTID,true);
	ArrayList<DaoJetSettingFinedustRecord> aryFinedustJetSetting =  daoJetSettingFinedust.selectJetSettingFinedust(strSTID,true);
	ArrayList<DaoJetSettingHeatwaveRecord> aryHeatwaveJetSetting =  daoJetSettingHeatwave.selectJetSettingHeatwave(strSTID,true);

	String strMonth = "";
	String strSHour = "";
	String strEHour = "";
	String strCount = "";
	String strBreakInterval = "";

	JSONObject joJ = null;
	JSONArray jaJ = new JSONArray();

	for(DaoJetSettingTimeRecord rTJS : aryTimeJetSetting)
	{
		strMonth = Integer.toString(rTJS.m_nMonth);
		strSHour = Integer.toString(rTJS.m_nSHour);
		strEHour = Integer.toString(rTJS.m_nEHour);
		
		joJ = new JSONObject();
		joJ.put("stid",rTJS.m_strSTID);
		joJ.put("month",strMonth);
		joJ.put("shour",strSHour);
		joJ.put("ehour",strEHour);
		jaJ.put(joJ);
		
		mapSensor.put(strMonth,joJ);
	}
	
	for(DaoJetSettingNomalRecord rNJS :  aryNomalJetSetting)
	{
		
		strMonth = Integer.toString(rNJS.m_nMonth);
		strCount = Integer.toString(rNJS.m_nCount);
		strBreakInterval = Integer.toString(rNJS.m_nBreakInterval);
		
		joJ = mapSensor.get(strMonth);
		if(joJ != null)
		{
			joJ.put("nomalcount",strCount); 
			joJ.put("nomalinterval",strBreakInterval);
		}
	}
	
	for(DaoJetSettingFinedustRecord rFJS :  aryFinedustJetSetting)
	{
		
		strMonth = Integer.toString(rFJS.m_nMonth);
		strCount = Integer.toString(rFJS.m_nCount);
		strBreakInterval = Integer.toString(rFJS.m_nBreakInterval);
		
		joJ = mapSensor.get(strMonth);
		if(joJ != null)
		{
			joJ.put("dustcount",strCount); 
			joJ.put("dustinterval",strBreakInterval);
		}
	}
	
	for(DaoJetSettingHeatwaveRecord rHJS :  aryHeatwaveJetSetting)
	{
		
		strMonth = Integer.toString(rHJS.m_nMonth);
		strCount = Integer.toString(rHJS.m_nCount);
		strBreakInterval = Integer.toString(rHJS.m_nBreakInterval);
		
		joJ = mapSensor.get(strMonth);
		if(joJ != null)
		{
			joJ.put("heatcount",strCount); 
			joJ.put("heatinterval",strBreakInterval);
		}
	}

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	joReturn.put("jetsetting",jaJ);
	
	out.println(joReturn.toString());
%>

