<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>   
<%@ page import="wguard.biz.SendGateMessage"%>
<%@ page import="wguard.dao.DaoSensorSt"%>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord"%>
<%@ page import="wguard.dao.DaoCleanloadInfo"%>
<%@ page import="wguard.dao.DaoCleanloadInfo.DaoCleanloadInfoRecord"%>
<%@ page import="wguard.dao.DaoValves"%>
<%@ page import="wguard.dao.DaoValves.DaoValvesRecord"%>
<%@ page import="wguard.dao.DaoPolesSt"%>
<%@ page import="wguard.dao.DaoPolesSt.DaoPolesStRecord"%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	

JSONObject joReturn = new JSONObject();

String strCMD = EtcUtils.NullS(request.getParameter("cmd"));
if(strCMD.isEmpty())
{
	joReturn.put("result","FAIL");
	joReturn.put("msg","CMD not found");
	out.println(joReturn.toString());
	return ;
}	

boolean bSendOK = false;
int nIndex = 0;

if(strCMD.equals("stop_send"))
{  // 센서 상태 알림
	String strGID = EtcUtils.NullS(request.getParameter("gid"));
	String strSID = EtcUtils.NullS(request.getParameter("sid"));
	String strOPEN = EtcUtils.NullS(request.getParameter("open"));

	boolean bOpen = false;
	if(strOPEN.equals("true")) bOpen = true;

	bSendOK = SendGateMessage.SendSensorOpenMsg(strGID, strSID, bOpen);
}
else if(strCMD.equals("valves_open"))
{  // 센서 상태 알림
	String strSID = EtcUtils.NullS(request.getParameter("sid"));
	String strOPEN = EtcUtils.NullS(request.getParameter("open"));
	String strWaterTime = EtcUtils.NullS(request.getParameter("time"));

	DaoSensorSt daoSensorSt = new DaoSensorSt();
	DaoSensorStRecord rSSR = daoSensorSt.getLastSensorSt(strSID, true);
	
	String strGID = rSSR.m_strGWID;
	String strExp = rSSR.m_strExpansion;

	String[] astrExp= EtcUtils.splitString(strExp,"=\\",true,false);
	String strVavlesOpen = "0000";

	for(nIndex=0; nIndex<astrExp.length; nIndex+=2 )
	{
		if(astrExp.length > nIndex+1)
		{
			if(astrExp[nIndex].equals("w"))
			{
				strVavlesOpen = astrExp[nIndex+1];
				break;
			}
		}
	}
    
	int nVavlesOpen = Integer.parseInt(strVavlesOpen);
	boolean bSend = false;

	if(strOPEN.equals("true"))
	{
		if(nVavlesOpen == 0) bSend = true;
	}
	else if(strOPEN.equals("false"))
	{
		if(nVavlesOpen == 1) bSend = true;
	}

	if(!bSend)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Vavles Error");
		out.println(joReturn.toString());
		return ;
	}

	int nWaterTime = Integer.parseInt(strWaterTime);

	DaoValves daoValves = new DaoValves();
	ArrayList<DaoValvesRecord> aryVR =  daoValves.selectCheakValves(strSID, true);   

	int nValvesCode = 0;
	for(DaoValvesRecord rSSt :  aryVR)   
	{
		nValvesCode += 1<<rSSt.m_nVID-1;
	}
	
	String strValvesCode = Integer.toHexString(nValvesCode);
	
	int nCodeSize = strValvesCode.length();
	if(nCodeSize < 4)
	{
		for(nIndex = 0 ; nIndex < 4-nCodeSize ; nIndex++)
		{
			strValvesCode = "0" + strValvesCode;
		}
	}
	
	boolean bOpen = false;
	if(strOPEN.equals("true")) bOpen = true;
		
	bSendOK = SendGateMessage.SendOpenValveMsg(strGID, strSID, strValvesCode, nWaterTime, bOpen);
	
	
}
else if(strCMD.equals("send_msg"))
{
	String strSID = EtcUtils.NullS(request.getParameter("sid"));
	String strMsg = EtcUtils.NullS(request.getParameter("message"));

	String[] arySID= EtcUtils.splitString(strSID,"_",true,false);

	int nErrorCount = 0;

	for(int i=0; i<arySID.length; i++)
	{
		DaoSensorSt daoSensorSt = new DaoSensorSt();
		DaoSensorStRecord rSSR = daoSensorSt.getLastSensorSt(arySID[i], true);
	
		if(!SendGateMessage.SendDisplayMsg(rSSR.m_strGWID, arySID[i], strMsg)) nErrorCount++;
	}

	if(nErrorCount > 0) bSendOK = false;
	else  bSendOK = true;
}
else if(strCMD.equals("check_msg"))
{
	String strSID = EtcUtils.NullS(request.getParameter("sid"));

	String[] arySID= EtcUtils.splitString(strSID,"_",true,false);

	int nErrorCount = 0;
	for(int i=0; i<arySID.length; i++)
	{
		DaoSensorSt daoSensorSt = new DaoSensorSt();
		DaoSensorStRecord rSSR = daoSensorSt.getLastSensorSt(arySID[i], true);
	
		if(!SendGateMessage.SendSensorReSendMsg(rSSR.m_strGWID, arySID[i])) nErrorCount++;
	}

	if(nErrorCount > 0) bSendOK = false;
	else  bSendOK = true;
}

if(bSendOK)
{
	joReturn.put("result","OK");
	joReturn.put("msg","success");
}
else
{
	joReturn.put("result","FAIL");
	joReturn.put("msg","Send False");
}

out.println(joReturn.toString());

return ;

%>