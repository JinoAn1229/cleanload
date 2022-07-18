<%@ page language="java" contentType="text/html; charset=utf-8"    pageEncoding="utf-8"%>
<%@ page import="wguard.web.ProjectConst" %> 
<%@ page import="java.util.Locale"%>
<%@ page import="common.util.UTF8ResourceBundle"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoDisplay" %> 
<%@ page import="wguard.dao.DaoDisplay.DaoDisplayRecord" %> 
<%@ page import="wguard.dao.DaoSite" %> 
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord" %>
<%@ page import="wguard.dao.DaoSensorSt" %>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%> 
<%@ page import="java.util.ArrayList" %>
<%@ page import="wguard.biz.SendGateMessage"%>
<%

boolean bError = false;

HttpSession p_Session = request.getSession(false);
if(p_Session == null)
{
	bError = true;
}
String strID = EtcUtils.NullS(request.getParameter("id"));
if(strID == null)
{
	bError = true;
}

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// 사이트의 정보를 수정한다.
// 이름, List순서,보안모드
	JSONObject joReturn = new JSONObject();
	
	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}
	
	String strSTID = EtcUtils.NullS(request.getParameter("stid"));
	if(strSTID.isEmpty())
	{
		bError = true;
	}

	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter stid is not found.");
		out.println(joReturn.toString());
		return ;
	}
	
	DaoSite daoSite = new DaoSite();
	DaoSiteRecord  rSTR = daoSite.getSite(strSTID);
	
	String strSid = EtcUtils.NullS(request.getParameter("sid"));
	if(strSid.isEmpty())
	{
		bError = true;
	}

	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter stid is not found.");
		out.println(joReturn.toString());
		return ;
	}
		
	
	String strMsg = EtcUtils.NullS(request.getParameter("message"));
	if(strMsg.isEmpty())
	{
		bError = true;
	}

	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter stid is not found.");
		out.println(joReturn.toString());
		return ;
	}
	
	boolean bSendOK = false;
	
	joReturn.put("result","OK");
	joReturn.put("msg","success");

	String[] astrSid= EtcUtils.splitString(strSid,"_",true,false);
	
	
	
	
	
	for(int i=0; i<astrSid.length; i++)
	{
		DaoSensorSt daoSensorSt = new DaoSensorSt();
		DaoSensorStRecord rSSR = daoSensorSt.getLastSensorSt(astrSid[i], true);
	
		bSendOK = SendGateMessage.SendDisplayMsg(rSSR.m_strGWID, astrSid[i], strMsg);
	}
	
	out.println(joReturn.toString());
%>








