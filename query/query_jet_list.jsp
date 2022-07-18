<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoJetState"%>
<%@ page import="wguard.dao.DaoJetState.DaoJetStateRecord"%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	

	JSONObject joReturn = new JSONObject();

	String strSTID = EtcUtils.NullS(request.getParameter("stid"));

	if(strSTID.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter not found");
		out.println(joReturn.toString());
		return ;
	}
	
	DaoJetState daoJetState = new DaoJetState();

	ArrayList<DaoJetStateRecord> aryJetState =  daoJetState.selectJetState(strSTID,true);

	JSONObject joJ = null;
	JSONArray jaJ = new JSONArray();
	for(DaoJetStateRecord rJS : aryJetState)
	{
		String strMonth = Integer.toString(rJS.m_nMonth);
		
		joJ = new JSONObject();
		joJ.put("stid",rJS.m_strSTID);
		joJ.put("month",strMonth);
		joJ.put("state",rJS.m_strJetState);
		jaJ.put(joJ);
	}

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	joReturn.put("jetstate",jaJ);
	
	out.println(joReturn.toString());
%>

