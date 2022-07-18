<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.io.DataOutputStream"%>
<%@ page import="java.io.InputStreamReader"%>
<%@ page import="java.net.HttpURLConnection"%>
<%@ page import="javax.net.ssl.HttpsURLConnection"%>
<%@ page import="java.net.URL"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="wguard.dao.DaoSensor" %>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord" %>
<%@ page import="wguard.dao.DaoSensorSt" %>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>
<%@ page import="wguard.dao.DaoApiAirkorea"%>
<%@ page import="wguard.dao.DaoApiAirkorea.DaoApiAirkoreaRecord"%>
<%@ page import="wguard.dao.DaoApiKma" %>    
<%@ page import="wguard.dao.DaoApiKma.DaoApiKmaRecord" %>
<%@ page import="wguard.dao.DaoCleanloadInfo"%>
<%@ page import="wguard.dao.DaoCleanloadInfo.DaoCleanloadInfoRecord"%>

<%!
  class SensorExpData {
	public int m_nCount = 0;
	public Float m_fValue = 0.0F;

	public SensorExpData() {
		this.m_nCount = 0;
		this.m_fValue = 0.0F;
    }
  }
%>
<%!
  class SensorExp {
	public HashMap<String,SensorExpData> m_mapExp = new HashMap<String,SensorExpData>();
	
    public SensorExp() {
      this.m_mapExp.clear();
    }
  }
%>
<%!
	public boolean isNumeric(String s)
	{
		try {
			Double.parseDouble(s);
			return true;
		} catch(NumberFormatException e) {
			return false;
	}
}
%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// 센서 상태 기록을 조회하는 쿼리호출이다.
// 파라메터 sid 가 입력되면 SENSOR 단위로 조회한다.
// 파라메터 date가 입력되면, 시간 보다 앞선 자료를 조회한다. ( 없을 경우 현재시간 적용)
// 파라메터 rows가 입력되면 조회하는 레코드수을 제한한다. ( 없을 경우 기본값 50 적용)
	JSONObject joReturn = new JSONObject();
	int i = 0;
	int nIndex = 0;
	Date dateST = null;
	Date dateEnd = null;
	String strWhereDate = "";
	String strWhereStationID = "";
	String strWhereStationName = "";
	String strWhere = "";
	
	String strSID = EtcUtils.NullS(request.getParameter("sid"));	  
	String strDateS = EtcUtils.NullS(request.getParameter("dates"));
	String strDateE = EtcUtils.NullS(request.getParameter("datee"));
	if(strDateS.isEmpty() || strDateE.isEmpty() || strSID.isEmpty() )
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch");
		out.println(joReturn.toString());
		return ;
	}
	
	DaoCleanloadInfo daoCleanloadInfo = new DaoCleanloadInfo();
	DaoCleanloadInfoRecord rCR = daoCleanloadInfo.getCleanloadInfo(strSID, true);

	DaoSensorSt daoSSt = new DaoSensorSt();
	DaoApiAirkorea daoAir = new DaoApiAirkorea();
	DaoApiKma DaoApiKma = new DaoApiKma();

	dateST = EtcUtils.getJavaDate(strDateS);
	dateEnd = EtcUtils.getJavaDate(strDateE);
	dateEnd = EtcUtils.addDateDay(dateEnd,1,true);

	strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoSSt.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoSSt.m_strDBType) + ") ORDER BY reg_date";

	strWhereStationID = "STATION_ID = '"+ rCR.m_strStationID + "' and" + strWhereDate;
	strWhereStationName = "STATION_NAME = '"+ rCR.m_strStationName + "' and" + strWhereDate;
	strWhere =  "SENSOR_ID ='" + strSID + "'  and " + strWhereDate;

	ArrayList<DaoSensorStRecord> arySStR = daoSSt.selectSensorManagerList(strWhere,true);
	ArrayList<DaoApiAirkoreaRecord> aryAirR = daoAir.selectAirkoreaList(strWhereStationName,true);
	ArrayList<DaoApiKmaRecord> aryKmaR = DaoApiKma.selectKmaList(strWhereStationID,true);

	HashMap<String,SensorExp> mapSensor = new HashMap<String,SensorExp>();
	ArrayList<String> aryKeyTime = new ArrayList<String>();

	SensorExp cSensorExp = null;
	SensorExpData cSensorData = null;
	
	String strKey = "";
	//DB테이터를 맵에 넣는다
	for(DaoSensorStRecord rSStR : arySStR)
	{		
		if(rSStR.m_nUseGoal != 168) continue;
	
		strKey = EtcUtils.getStrDate(rSStR.m_dateReg,"yyyy-MM-dd HH");
		strKey += ":00";
		cSensorExp = mapSensor.get(strKey);
		if(cSensorExp == null)
		{
			cSensorExp = new SensorExp();
			aryKeyTime.add(strKey);
		}

		String[] astrExp= EtcUtils.splitString(rSStR.m_strExpansion,"=\\",true,false);
		for(i=0; i<astrExp.length; i+=2 )
		{
			if(astrExp.length > i+1)
			{
				cSensorData = cSensorExp.m_mapExp.get(astrExp[i]);
				if(cSensorData == null) cSensorData = new SensorExpData();
				cSensorData.m_nCount++;
				cSensorData.m_fValue += Float.parseFloat(astrExp[i+1]);
				cSensorExp.m_mapExp.put(astrExp[i], cSensorData);
			}
		}
		
		mapSensor.put(strKey, cSensorExp);
	}

	//에어코리아 부분
	for(DaoApiAirkoreaRecord rAirR : aryAirR)  
	{
		SimpleDateFormat transFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String dateReg = transFormat.format(rAirR.m_dateReg);
		strKey = dateReg;
		SimpleDateFormat formatter=new SimpleDateFormat("yyyy-MM-dd HH:mm");
		Date date=formatter.parse(strKey);
		strKey = formatter.format(date);
		
		cSensorExp = mapSensor.get(strKey);
		if(cSensorExp == null) continue;
		
		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		cSensorData.m_fValue = rAirR.m_fPm10;
		cSensorExp.m_mapExp.put("ap", cSensorData);
		
		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		cSensorData.m_fValue = rAirR.m_fPm25;
		cSensorExp.m_mapExp.put("au", cSensorData);
		
		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		cSensorData.m_fValue = rAirR.m_fNo2;
		cSensorExp.m_mapExp.put("an", cSensorData);
		
		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		cSensorData.m_fValue = rAirR.m_fS02;
		cSensorExp.m_mapExp.put("as", cSensorData);
		
	}
	
	//kma부분
	for(DaoApiKmaRecord rKmaR : aryKmaR)  
	{
		SimpleDateFormat transFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String dateReg = transFormat.format(rKmaR.m_dateReg);
		strKey = dateReg;
		SimpleDateFormat formatter=new SimpleDateFormat("yyyy-MM-dd HH:mm");
		Date date=formatter.parse(strKey);
		strKey = formatter.format(date);
		
		cSensorExp = mapSensor.get(strKey);
		if(cSensorExp == null) continue;
		
		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		cSensorData.m_fValue = rKmaR.m_fTS;
		cSensorExp.m_mapExp.put("ad", cSensorData);		
	}
	
	
	
	

	JSONObject joSSt = null;
	JSONArray jaSSt = new JSONArray();

	for(nIndex = aryKeyTime.size() -1 ; nIndex >= 0  ; nIndex-- )
	{
		cSensorExp = mapSensor.get(aryKeyTime.get(nIndex));
		if(cSensorExp == null) continue;

		joSSt = new JSONObject();
		joSSt.put("sdate",aryKeyTime.get(nIndex)+":00");

		for(String strExpKey : cSensorExp.m_mapExp.keySet())
		{
			cSensorData = cSensorExp.m_mapExp.get(strExpKey);
			if(cSensorData == null) continue;
			joSSt.put(strExpKey, cSensorData.m_fValue / cSensorData.m_nCount);
		}
		jaSSt.put(joSSt);
	}
	
	


	joReturn.put("result","OK");
	joReturn.put("msg","success");
	joReturn.put("sensor",jaSSt);
	out.println(joReturn.toString());
	//return ;
%>








