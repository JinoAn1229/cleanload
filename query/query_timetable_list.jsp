<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoTimeTable"%>
<%@ page import="wguard.dao.DaoTimeTable.DaoTimeTableRecord"%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	

	JSONObject joReturn = new JSONObject();

	String strSID = EtcUtils.NullS(request.getParameter("sid"));

	if(strSID.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter not found");
		out.println(joReturn.toString());
		return ;
	}
	
	DaoTimeTable daoTimeTable = new DaoTimeTable();

	ArrayList<DaoTimeTableRecord> aryTimeTable =  daoTimeTable.selectTimeTable(strSID,true);

	JSONObject joT = null;
	JSONArray jaT = new JSONArray();
	for(DaoTimeTableRecord rTT : aryTimeTable)
	{
		joT = new JSONObject();
		joT.put("seq",rTT.m_strSeqID);
		joT.put("sid",rTT.m_strSID);
		joT.put("mouth",rTT.m_nMonth);
		joT.put("hour",rTT.m_nHour);
		jaT.put(joT);
	}

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	joReturn.put("timetable",jaT);
	
	out.println(joReturn.toString());
%>

