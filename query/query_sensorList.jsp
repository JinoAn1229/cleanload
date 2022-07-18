<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoSite"%>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord"%>
<%@ page import="wguard.dao.DaoSensor"%>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord"%>
<%@ page import="wguard.dao.DaoSensorSt" %>    
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %> 

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// 사이트에 속한 모든 센서를 로딩한다.
	String strSTID = EtcUtils.NullS(request.getParameter("stid"));
	JSONObject joReturn = new JSONObject();
	
	DaoSensor daoSensor = new DaoSensor();
	ArrayList<DaoSensorRecord> arySensor =  daoSensor.selectSensor(strSTID,true);
	ArrayList<String> arySIDs =  new ArrayList<String>();
	HashMap<String, JSONObject> mapSensor = new HashMap<String, JSONObject>();
	joReturn.put("result","OK");
	joReturn.put("msg","success");
	
	JSONObject joS = null;
	JSONArray jaS = new JSONArray();
	for(DaoSensorRecord rSR : arySensor)
	{
		joS = new JSONObject();
		joS.put("sid",rSR.m_strSID);
		joS.put("sname",rSR.m_strSName);
		joS.put("usegoal",160); // '162(A2)' 보안센서, '163(A3)' 동작센서
		jaS.put(joS);

		//센서 최종 상태를 조회 하기위해 SID모음
		arySIDs.add(rSR.m_strSID);
		mapSensor.put(rSR.m_strSID,joS);
	}
	
	DaoSensorSt daoSSt = new DaoSensorSt();	
	ArrayList<DaoSensorStRecord> arySStR =  daoSSt.selectLastSensorSt(arySIDs);
	for(DaoSensorStRecord rSSt :  arySStR)
	{
		joS = mapSensor.get(rSSt.m_strSensorID);
		if(joS != null)
		{
			joS.put("usegoal",rSSt.m_nUseGoal); // '162(A2)' 보안센서, '163(A3)' 동작센서
			joS.put("date",EtcUtils.getStrDate(rSSt.m_dateReg,"yyyy-MM-dd HH:mm:ss.SSS"));
			joS.put("action",rSSt.m_strSensorAction);
		}
	}
	joReturn.put("sensor",jaS);
	
	out.println(joReturn.toString());
%>

