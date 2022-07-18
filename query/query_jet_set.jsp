<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="common.util.EtcUtils" %>   
<%@ page import="wguard.dao.DaoJetState"%>
<%@ page import="wguard.dao.DaoJetState.DaoJetStateRecord"%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	

JSONObject joReturn = new JSONObject();



boolean bSendOK = false;


 
String strSTID = EtcUtils.NullS(request.getParameter("stid"));
String strMonth = EtcUtils.NullS(request.getParameter("month"));
String strState = EtcUtils.NullS(request.getParameter("state"));

if(strSTID.isEmpty() || strMonth.isEmpty() || strState.isEmpty())
{
	joReturn.put("result","FAIL");
	joReturn.put("msg","Parameter not found");
	out.println(joReturn.toString());
	return ;
}
int nMonth = Integer.parseInt(strMonth);

DaoJetState daoJetState = new DaoJetState();
DaoJetState.DaoJetStateRecord rJS = daoJetState.new DaoJetStateRecord();

if(daoJetState.updateState(strSTID, nMonth, strState))
{
	bSendOK = true;
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