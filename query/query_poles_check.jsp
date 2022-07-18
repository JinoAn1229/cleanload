<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.web.WGuardUtil"%>
<%@ page import="wguard.dao.DaoSite"%>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord"%>
<%@ page import="wguard.dao.DaoSensor"%>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord"%>
<%@ page import="wguard.dao.DaoSensorSt"%>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord"%>



<%
boolean bError = false;

HttpSession p_Session = request.getSession(false);
if(p_Session == null)
{
	//bError = true;
}
String strID = (String)p_Session.getAttribute("ID");
if(strID == null)
{
	//bError = true;
}

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// 사이트에 속한 모든 센서를 로딩한다.
	JSONObject joReturn = new JSONObject();
	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}
	
	
	String strSID = EtcUtils.NullS(request.getParameter("sid"));
	if(strSID.isEmpty()) bError = true;

	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter sid is not found.");
		out.println(joReturn.toString());
		return ;
	}
	
	joReturn.put("result","OK");
	joReturn.put("msg","success");
	
	
	DaoSensorSt daoSensorSt = new DaoSensorSt();
	DaoSensorStRecord rSSR = daoSensorSt.getLastSensorSt(strSID, true);

	
	String strExp = rSSR.m_strExpansion;

	String[] astrExp= EtcUtils.splitString(strExp,"=\\",true,false);
	String strWaterFlowSt = "0";
	int nVavlesOpen = 0;
	for(int nIndex=0; nIndex<astrExp.length; nIndex+=2 )
	{
		if(astrExp.length > nIndex+1)
		{
			if(astrExp[nIndex].equals("w"))
			{
				strWaterFlowSt = astrExp[nIndex+1];
				nVavlesOpen = Integer.parseInt(strWaterFlowSt);
				break;
			}
		}
	}
	
	joReturn.put("water",nVavlesOpen);
	out.println(joReturn.toString());
%>


