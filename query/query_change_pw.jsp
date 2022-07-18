<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="wguard.dao.DaoUser" %>  
<%@ page import="common.util.EtcUtils" %>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
	String strID = EtcUtils.NullS(request.getParameter("id"));
	String strPW = EtcUtils.NullS(request.getParameter("pw"));

	boolean bFindID = false;
	JSONObject joReturn = new JSONObject();

	if(strID.isEmpty() || strPW.isEmpty())
	{
		joReturn.put("result","FAIL");
		out.println(joReturn.toString());
		return;
	}

	DaoUser daoUser = new DaoUser();
	DaoUser.DaoUserRecord rUser = null;
	try
	{
		rUser = daoUser.getUser(strID);
		if (rUser != null )
		{			
			bFindID = true;
			rUser.m_strPW = strPW;
			daoUser.updateUser(rUser);
			joReturn.put("result","OK");		
		}

	}
	catch(Exception e)
	{
	}
	if(!bFindID)
	{
		joReturn.put("result","FAIL");
	}
	out.println(joReturn.toString());
	return;
%>