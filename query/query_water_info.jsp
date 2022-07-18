<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="wguard.dao.DaoSensor" %>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord" %>
<%@ page import="wguard.dao.DaoSensorSt" %>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>
<%@ page import="wguard.dao.DaoLinkSensor"%>
<%@ page import="wguard.dao.DaoLinkSensor.DaoLinkSensorRecord"%>
<%@ page import="wguard.dao.DaoCleanloadInfo"%>
<%@ page import="wguard.dao.DaoCleanloadInfo.DaoCleanloadInfoRecord"%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// 센서 상태 기록을 조회하는 쿼리호출이다.
// 파라메터 sid 가 입력되면 SENSOR 단위로 조회한다.
//          sid 가 입력되지 않으면 SITE 단위로 조회한다.
// 파라메터 stid 가 입력되면 GMT 설정에 따라 시간을 수정한다.
// 파라메터 date가 입력되면, 시간 보다 앞선 자료를 조회한다. ( 없을 경우 현재시간 적용)
// 파라메터 rows가 입력되면 조회하는 레코드수을 제한한다. ( 없을 경우 기본값 50 적용)
String strSID =  EtcUtils.NullS(request.getParameter("sensor"));
String strEnclosureID = "";
String strAlarmVal = "";


JSONObject joReturn = new JSONObject();
JSONObject joAuto = null;
	
joAuto = new JSONObject();

DaoLinkSensor daoLs = new DaoLinkSensor(); 
DaoLinkSensorRecord rLSR = daoLs.getEnclosure(strSID,true);
if(rLSR != null)
{
	strEnclosureID = rLSR.m_strLinkSID;
}	


DaoCleanloadInfo daoCleanloadInfo = new DaoCleanloadInfo();	
DaoCleanloadInfoRecord rCt = daoCleanloadInfo.getCleanloadInfo(strSID,true);
if(rCt != null)
{
	joAuto.put("wtime",Integer.toString(rCt.m_nWatertime));
}	


DaoSensor daoSensor = new DaoSensor();
DaoSensorRecord rSR = daoSensor.getSensor(strEnclosureID,true);
if(rSR != null)
{
	strAlarmVal = rSR.m_strAlarmVal;
	String[] astrExp= EtcUtils.splitString(strAlarmVal,"=\\",true,false);
		for(int i=0; i<astrExp.length; i+=2 )
		{
			if(astrExp.length > i+1)
			{
				if(astrExp[i].equals("t"))
				{
					joAuto.put("temp",astrExp[i+1]);
				}
				else if(astrExp[i].equals("h"))
				{
					joAuto.put("hum",astrExp[i+1]);			
				}
				else if(astrExp[i].equals("p"))
				{
					joAuto.put("dust",astrExp[i+1]);
				}
			}
		}
}



	
joReturn.put("result","OK");
joReturn.put("msg","success");
joReturn.put("auto",joAuto);
out.println(joReturn.toString());


%>








