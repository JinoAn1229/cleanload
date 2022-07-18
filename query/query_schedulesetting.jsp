<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoSite"%>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord"%>
<%@ page import="wguard.dao.DaoSensor"%>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord"%>
<%@ page import="wguard.dao.DaoCleanloadInfo"%>
<%@ page import="wguard.dao.DaoCleanloadInfo.DaoCleanloadInfoRecord"%>
<%

HttpSession p_Session = request.getSession(false);
if(p_Session == null)
{
	out.println("FAIL");
	return;
}
String strID = (String)p_Session.getAttribute("ID");
if(strID == null)
{
	out.println("FAIL");
	return;
}

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// SENSOR ALARM 상태정보, 센서이름 등을 설정한다.
	String strSTID = EtcUtils.NullS(request.getParameter("stid"));
	String strAuto = EtcUtils.NullS(request.getParameter("auto"));
	String strWaterTime = EtcUtils.NullS(request.getParameter("time"));		
	if(strSTID.isEmpty())
	{
		out.println("FAIL");
		return;
	}

	if(strAuto.isEmpty())
	{ 
		out.println("FAIL");
		return;
	}
	if(strWaterTime.isEmpty())
	{ 
		out.println("FAIL");
		return;
	}
	int nWaterTime = Integer.parseInt(strWaterTime);
	
	DaoSensor daoSensor = new DaoSensor();	
	ArrayList<DaoSensorRecord> arySensor =  daoSensor.selectUser(strID, true);
	for(DaoSensorRecord rS :  arySensor)
	{
		DaoCleanloadInfo daoCleanloadInfo = new DaoCleanloadInfo();
		DaoCleanloadInfoRecord  rCR = daoCleanloadInfo.getCleanloadInfo(rS.m_strSID,true);
		
		if(rCR.m_nWatertime != nWaterTime)
		{
			daoCleanloadInfo.updateWaterTime(rS.m_strSID,nWaterTime);
		}
	}
	
	
	DaoSite daoSite = new DaoSite();
	daoSite.updateScheduleSetting(strSTID,strAuto);
	
	out.println("OK");
	return;
%>