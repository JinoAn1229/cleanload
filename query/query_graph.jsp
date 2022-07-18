<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="wguard.dao.DaoSensor" %>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord" %>
<%@ page import="wguard.dao.DaoSensorSt" %>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>


<%
/*boolean bError = false;
HttpSession p_Session = request.getSession(false);
if(p_Session == null)
{
	bError = true;
}
String strID = (String)p_Session.getAttribute("ID");
if(strID == null)
{
	bError = true;
}*/

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// 센서 상태 기록을 조회하는 쿼리호출이다.
// 파라메터 sid 가 입력되면 SENSOR 단위로 조회한다.
//          sid 가 입력되지 않으면 SITE 단위로 조회한다.
// 파라메터 stid 가 입력되면 GMT 설정에 따라 시간을 수정한다.
// 파라메터 date가 입력되면, 시간 보다 앞선 자료를 조회한다. ( 없을 경우 현재시간 적용)
// 파라메터 rows가 입력되면 조회하는 레코드수을 제한한다. ( 없을 경우 기본값 50 적용)
	JSONObject joReturn = new JSONObject();
	/*
	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}*/
	Date dateST = null;
	Date dateEnd = null;
	String strWhereDate = "";
	
	
	String strSID = EtcUtils.NullS(request.getParameter("sid"));
	
	String strWhere = "";
	
	DaoSensorSt daoSSt = new DaoSensorSt();
	
	  
	String strDateS = EtcUtils.NullS(request.getParameter("dates"));
	String strDateE = EtcUtils.NullS(request.getParameter("datee"));
	String strTimeSet = EtcUtils.NullS(request.getParameter("time"));

	if(strDateS.isEmpty() || strDateE.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( date )");
		out.println(joReturn.toString());
		return ;
	}

	if(strTimeSet.indexOf("hours") >= 0)
	{
		strDateS += ":00:00";
		strDateE += ":00:00";
	}

	dateST = EtcUtils.getJavaDate(strDateS);
	dateEnd = EtcUtils.getJavaDate(strDateE);

	if(strTimeSet.indexOf("hours") >= 0)
		dateEnd = EtcUtils.addDateHour(dateEnd,1);
	else
		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);

	strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoSSt.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoSSt.m_strDBType) + ") ORDER BY reg_date DESC";    //바꿀부분  
	

	if( strSID.isEmpty() )
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter mismatch");
		out.println(joReturn.toString());
		return ;
	}

	if(!strSID.isEmpty())
	{
		strWhere =  "SENSOR_ID ='" + strSID + "'" ;
		if(!strWhereDate.isEmpty())
		{
			strWhere += " and " + strWhereDate;
		}
	}
	
	DaoSensor daoS = new DaoSensor();
	DaoSensorRecord  rST = daoS.getSensor(strSID,true);
	
	JSONObject   joAlarm = null;
	joAlarm = new JSONObject();
	String[] astrAlarm= EtcUtils.splitString(rST.m_strAlarmVal,"=\\",true,false);
	for(int i=0; i<astrAlarm.length; i+=2 )
	{
		if(astrAlarm.length > i+1)
			joAlarm.put(astrAlarm[i],astrAlarm[i+1]);
	}
	
	ArrayList<DaoSensorStRecord> arySStR = daoSSt.selectSensorManagerList(strWhere,true);

	JSONObject joSSt = null;
	JSONArray jaSSt = new JSONArray();
	
	
	JSONObject   joExp = null;
	
	for(DaoSensorStRecord rSStR : arySStR)
	{		

		joExp = new JSONObject();
		String[] astrExp= EtcUtils.splitString(rSStR.m_strExpansion,"=\\",true,false);
		for(int i=0; i<astrExp.length; i+=2 )
		{
			if(astrExp.length > i+1)
				joExp.put(astrExp[i],astrExp[i+1]);
		}
			
		
		joSSt = new JSONObject();

		
		joSSt.put("st",rSStR.m_strSensorState);
		joSSt.put("su",rSStR.m_nUseGoal);
		joSSt.put("gid",rSStR.m_strGWID);
		joSSt.put("sid",rSStR.m_strSensorID);
		joSSt.put("bl",rSStR.m_nBatteryLevel);
		joSSt.put("sa",rSStR.m_strSensorAction);
		joSSt.put("exp",joExp);	
		joSSt.put("alarm",joAlarm);	
		
		
		joSSt.put("sdate",EtcUtils.getStrDate(rSStR.m_dateReg,"yyyy-MM-dd HH:mm:ss.SSS"));
		
		jaSSt.put(joSSt);
	}
	

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	joReturn.put("sensor",jaSSt);
	out.println(joReturn.toString());
	//return ;
%>








