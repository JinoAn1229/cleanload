<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoSensor"%>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord"%>
<%@ page import="wguard.biz.SendGateMessage"%>
<%

JSONObject joReturn = new JSONObject();

HttpSession p_Session = request.getSession(false);
if(p_Session == null)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return;
	}
	
String strID = (String)p_Session.getAttribute("ID");
if(strID == null)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","ID not found");
		out.println(joReturn.toString());
		return;
	}

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// SENSOR ALARM 상태정보, 센서이름 등을 설정한다.
	boolean bSendOK = false;
	
	String strSID = EtcUtils.NullS(request.getParameter("sid"));
	String strAlarm = EtcUtils.NullS(request.getParameter("salarm"));
		
	if(strSID.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Sensor ID not found");
		out.println(joReturn.toString());
		return;
	}

	if(strAlarm.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Value not found");
		out.println(joReturn.toString());
		return;
	}
	
DaoSensor daoSensor = new DaoSensor();
	if(daoSensor.insertAlramVal(strSID,strAlarm))
	{
		bSendOK = SendGateMessage.SendSensorAlramValSet(strSID);
		
		joReturn.put("result","OK");
		joReturn.put("msg","success");	
	}
	else
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","insert fail");
	}
		
	out.println(joReturn.toString());	
%>