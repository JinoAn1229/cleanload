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


JSONObject joReturn = new JSONObject();
	
if(strSID == "")
{
	joReturn.put("result","OK");
	joReturn.put("msg","Web Server Ok");
	out.println(joReturn.toString());
	return ;	
}
else
{
	DaoSensorSt daoS = new DaoSensorSt();
	DaoSensorStRecord rSR = daoS.getLastSensorSt(strSID, true);
	if(rSR == null)
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","The sensor not found.");
			out.println(joReturn.toString());
			return ;	
		}

	JSONObject joSSt = null;
	
	joSSt = new JSONObject();

	joSSt.put("date",EtcUtils.getStrDate(rSR.m_dateReg,"yyyy-MM-dd HH:mm:ss"));
	
	joReturn.put("result","OK");
	joReturn.put("msg","success");
	joReturn.put("sensor",joSSt);
	out.println(joReturn.toString());
		
}		
	

%>








