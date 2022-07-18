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
// ���� ���� ����� ��ȸ�ϴ� ����ȣ���̴�.
// �Ķ���� sid �� �ԷµǸ� SENSOR ������ ��ȸ�Ѵ�.
//          sid �� �Էµ��� ������ SITE ������ ��ȸ�Ѵ�.
// �Ķ���� stid �� �ԷµǸ� GMT ������ ���� �ð��� �����Ѵ�.
// �Ķ���� date�� �ԷµǸ�, �ð� ���� �ռ� �ڷḦ ��ȸ�Ѵ�. ( ���� ��� ����ð� ����)
// �Ķ���� rows�� �ԷµǸ� ��ȸ�ϴ� ���ڵ���� �����Ѵ�. ( ���� ��� �⺻�� 50 ����)
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








