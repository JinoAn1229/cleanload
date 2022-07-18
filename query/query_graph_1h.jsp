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

	DaoSensorSt daoSSt = new DaoSensorSt();

	dateST = EtcUtils.getJavaDate(strDateS);
	dateEnd = EtcUtils.getJavaDate(strDateE);
	dateEnd = EtcUtils.addDateDay(dateEnd,1,true);

	strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoSSt.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoSSt.m_strDBType) + ") ORDER BY reg_date";

	strWhere =  "SENSOR_ID ='" + strSID + "'  and " + strWhereDate;

	ArrayList<DaoSensorStRecord> arySStR = daoSSt.selectSensorManagerList(strWhere,true);

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

	//airkorea 테이터를 받는다
	String url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty";
	url += "?serviceKey=ztAwASBpMilBA4z9Z0Cx9HE9yTBFcpPxQmjPxEWsKlHbB%2Bm9XVIqNK9CqiDPfD2wyvBzMhak5ZC4L7MZNGgbwA%3D%3D";
	url += "&numOfRows=900&pageNo=2&stationName=%EA%B2%80%EB%8B%A8&dataTerm=3MONTH&ver=1.3&_returnType=json";

	URL obj = new URL(url);
	HttpURLConnection con = (HttpURLConnection) obj.openConnection();

	con.setRequestMethod("GET");

	BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));

	String strInputLine;
	StringBuffer sbResponse = new StringBuffer();

	while ((strInputLine = in.readLine()) != null)
	{
		sbResponse.append(strInputLine);
	}
	
	in.close();

	JSONObject joAir = new JSONObject(sbResponse.toString());
	JSONArray jaAirList = (JSONArray)joAir.get("list");
	JSONObject joAirTemp = null;
	String strTemp;

	SimpleDateFormat formatter=new SimpleDateFormat("yyyy-MM-dd HH:mm"); 
	for( i=0 ; i < jaAirList.length() ; i++)
	{
		joAirTemp = jaAirList.getJSONObject(i);
		strKey = joAirTemp.getString("dataTime");
		Date date=formatter.parse(strKey);
		strKey = formatter.format(date); 

		cSensorExp = mapSensor.get(strKey);
		if(cSensorExp == null) continue;

		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		strTemp = joAirTemp.getString("no2Value");
		if(isNumeric(strTemp)) cSensorData.m_fValue = Float.parseFloat(strTemp);
		cSensorExp.m_mapExp.put("an", cSensorData);

		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		strTemp = joAirTemp.getString("so2Value");
		if(isNumeric(strTemp)) cSensorData.m_fValue = Float.parseFloat(strTemp);
		cSensorExp.m_mapExp.put("as", cSensorData);

		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		strTemp = joAirTemp.getString("pm10Value");
		if(isNumeric(strTemp)) cSensorData.m_fValue = Float.parseFloat(strTemp);
		cSensorExp.m_mapExp.put("ap", cSensorData);

		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		strTemp = joAirTemp.getString("pm25Value");
		if(isNumeric(strTemp)) cSensorData.m_fValue = Float.parseFloat(strTemp);
		cSensorExp.m_mapExp.put("au", cSensorData);
	}

	//기상청 데이터를 받는다
	//전전날 자료까지만 가능하다

	Date dateKmaMax = new Date();
	dateKmaMax = EtcUtils.addDateDay(dateKmaMax,-2,true);
	if(dateEnd.getTime() > dateKmaMax.getTime()) dateEnd = dateKmaMax;


	String strKmaUrl = "http://apis.data.go.kr/1360000/AsosHourlyInfoService/getWthrDataList?dataType=json&dataCd=ASOS&dateCd=HR";
	strKmaUrl += "&startDt=" + EtcUtils.getStrDate(dateST,"yyyyMMdd") + "&startHh=00";
	strKmaUrl += "&endDt=" + EtcUtils.getStrDate(dateEnd,"yyyyMMdd") + "&endHh=23";
	strKmaUrl += "&stnIds=112&numOfRows=900&pageIndex=1&schListCnt=100";
	strKmaUrl += "&serviceKey=ztAwASBpMilBA4z9Z0Cx9HE9yTBFcpPxQmjPxEWsKlHbB%2Bm9XVIqNK9CqiDPfD2wyvBzMhak5ZC4L7MZNGgbwA%3D%3D";

//	String certificatesTrustStorePath = "C:\\Program Files\\Java\\jre1.8.0_191\\lib\\security\\jssecacerts";
//	System.setProperty("javax.net.ssl.trustStore", certificatesTrustStorePath);
//	out.println(strKmaUrl);
	URL urlKma = new URL(strKmaUrl);
	HttpURLConnection conKma = (HttpURLConnection) urlKma.openConnection();


	BufferedReader inKma = new BufferedReader(new InputStreamReader(conKma.getInputStream(), "UTF-8"));


	sbResponse.delete(0, sbResponse.length());

	while ((strInputLine = inKma.readLine()) != null)
	{
		sbResponse.append(strInputLine);
	}

	inKma.close();
/*
	nIndex = 0;
	while(nIndex >= 0)
	{
		nIndex = sbResponse.indexOf("[");
		if(nIndex < 0) break;
		sbResponse.setCharAt(nIndex, '{');
	}

	nIndex = 0;
	while(nIndex >= 0)
	{
		nIndex = sbResponse.indexOf("]");
		if(nIndex < 0) break;
		sbResponse.setCharAt(nIndex, '}');
	}
	*/


	//nIndex = sbResponse.indexOf("{\"info\":");
	//String strKmaTemp = sbResponse.substring(nIndex, sbResponse.length()-1);

//	out.println(sbResponse.toString());


//	out.println("<br>");
//	out.println("<br>");

	JSONObject joKma = new JSONObject(sbResponse.toString());
	JSONArray jaKmaList = (JSONArray)joKma.getJSONObject("response").getJSONObject("body").getJSONObject("items").get("item");

//	JSONArray jaKmaList = joKma.get("response");
	JSONObject joKmaTemp = null;

	for( i=0 ; i < jaKmaList.length() ; i++)
	{
		joKmaTemp = jaKmaList.getJSONObject(i);
		strKey = joKmaTemp.getString("tm");

		cSensorExp = mapSensor.get(strKey);
		if(cSensorExp == null) continue;

		cSensorData = new SensorExpData();
		cSensorData.m_nCount++;
		strTemp = joKmaTemp.getString("ts");
		if(isNumeric(strTemp)) cSensorData.m_fValue = Float.parseFloat(strTemp);
		cSensorExp.m_mapExp.put("at", cSensorData);
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








