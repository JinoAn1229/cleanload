<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="common.util.EtcUtils" %>   
<%@ page import="wguard.dao.DaoTimeTable"%>
<%@ page import="wguard.dao.DaoTimeTable.DaoTimeTableRecord"%>
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

if(strCMD.equals("add"))
{  
	String strSID = EtcUtils.NullS(request.getParameter("sid"));
	String strMouth = EtcUtils.NullS(request.getParameter("mouth"));
	String strHour = EtcUtils.NullS(request.getParameter("hour"));

	if(strSID.isEmpty() || strMouth.isEmpty() || strHour.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter not found");
		out.println(joReturn.toString());
		return ;
	}

	DaoTimeTable daoTimeTable = new DaoTimeTable();
	DaoTimeTable.DaoTimeTableRecord rT = daoTimeTable.new DaoTimeTableRecord();

	rT.m_strSID = strSID;
	rT.m_nMonth = Integer.parseInt(strMouth);
	rT.m_nHour = Integer.parseInt(strHour);

	String strSEQ = daoTimeTable.insertTimeTable(rT);
	if(!strSEQ.isEmpty()) bSendOK = true;
}
else if(strCMD.equals("del"))
{  // 센서 상태 알림
	String strSEQ = EtcUtils.NullS(request.getParameter("seq"));
	
	if(strSEQ.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter not found");
		out.println(joReturn.toString());
		return ;
	}


	DaoTimeTable daoTimeTable = new DaoTimeTable();
	bSendOK = daoTimeTable.deleteTimeTable(strSEQ);
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