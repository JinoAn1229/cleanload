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
<%@ page import="java.net.URLEncoder"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="wguard.dao.DaoApiAirkorea"%>
<%@ page import="wguard.dao.DaoApiAirkorea.DaoApiAirkoreaRecord"%>

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
	JSONObject joReturn = new JSONObject();
	int i = 0;
	int nIndex = 0;
	Date dateST = null;
	Date dateEnd = null;
	
	String strDateS = EtcUtils.NullS(request.getParameter("dates"));
	String strDateE = EtcUtils.NullS(request.getParameter("datee"));
	String strAirStation = EtcUtils.NullS(request.getParameter("airst"));

	SimpleDateFormat formatter=new SimpleDateFormat("yyyy-MM-dd HH:mm"); 

	if(strDateS.isEmpty())
	{
		dateST = new Date();
		dateST = EtcUtils.addDateDay(dateST,-1,true);
	}
	else
	{
		dateST = EtcUtils.getJavaDate(strDateS);
//		dateST = EtcUtils.addDateDay(dateST,0,true);
	}

	if(strDateE.isEmpty())
	{
		dateEnd = new Date();
//		dateEnd = EtcUtils.addDateDay(dateEnd,0,true);
	}
	else
	{
		dateEnd = EtcUtils.getJavaDate(strDateE);
//		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);
	}
	

	if(strAirStation.isEmpty()) strAirStation = "종로";

	String strAirStationCode =  URLEncoder.encode(strAirStation, "UTF-8");

	//airkorea 테이터를 받는다
	//구버전 환경공단 api가 변경됬음
	//String url = "http://openapi.airkorea.or.kr/openapi/services/rest/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty";
	//url += "?serviceKey=ztAwASBpMilBA4z9Z0Cx9HE9yTBFcpPxQmjPxEWsKlHbB%2Bm9XVIqNK9CqiDPfD2wyvBzMhak5ZC4L7MZNGgbwA%3D%3D";
	//url += "&numOfRows=100&pageNo=1&stationName="+strAirStationCode+"&dataTerm=MONTH&ver=1.3&_returnType=json";

	String url = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty";
	url += "?serviceKey=ztAwASBpMilBA4z9Z0Cx9HE9yTBFcpPxQmjPxEWsKlHbB%2Bm9XVIqNK9CqiDPfD2wyvBzMhak5ZC4L7MZNGgbwA%3D%3D";
	url += "&numOfRows=100&pageNo=1&stationName="+strAirStationCode+"&dataTerm=MONTH&ver=1.3&returnType=json";
	
	//out.println(url);
	
	
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
	
	//구버전 환경공단 api가 변경됬음
	//JSONArray jaAirList = (JSONArray)joAir.get("list");
	
	JSONArray jaAirList = (JSONArray)joAir.getJSONObject("response").getJSONObject("body").get("items");
	
	JSONObject joAirTemp = null;
	String strTemp;


	DaoApiAirkorea daoAir = new DaoApiAirkorea();

	if(!daoAir.connection())
	{
		joReturn.put("result","ERROR");
		joReturn.put("msg","DB ERROR");
		out.println(joReturn.toString());
		return ;
	}

	for( i=0 ; i < jaAirList.length() ; i++)
	{
		joAirTemp = jaAirList.getJSONObject(i);
		String strTime = joAirTemp.getString("dataTime");
		Date date=formatter.parse(strTime);
		

		if((date.getTime() < dateST.getTime()) || (date.getTime() >= dateEnd.getTime()))  continue;

		DaoApiAirkorea.DaoApiAirkoreaRecord rA = daoAir.new DaoApiAirkoreaRecord();

		rA.m_dateReg = date;
		rA.m_strStaion = strAirStation;

		strTemp = joAirTemp.getString("no2Value");
		if(isNumeric(strTemp)) rA.m_fNo2 = Float.parseFloat(strTemp);

		strTemp = joAirTemp.getString("so2Value");
		if(isNumeric(strTemp)) rA.m_fS02 = Float.parseFloat(strTemp);

		strTemp = joAirTemp.getString("pm10Value");
		if(isNumeric(strTemp)) rA.m_fPm10 = Float.parseFloat(strTemp);

		strTemp = joAirTemp.getString("pm25Value");
		if(isNumeric(strTemp)) rA.m_fPm25 = Float.parseFloat(strTemp);

		strTemp = joAirTemp.getString("o3Value");
		if(isNumeric(strTemp)) rA.m_fO3 = Float.parseFloat(strTemp);

		strTemp = joAirTemp.getString("coValue");
		if(isNumeric(strTemp)) rA.m_fCo = Float.parseFloat(strTemp);

		if(daoAir.getAirkorea(date, strAirStation, false) == null)
		{
			//out.println("i = " + rA.m_dateReg + rA.m_strStaion + "<br>");
			daoAir.insertAirkorea(rA, false);
		}
		else
		{
			//out.println("u = " + rA.m_dateReg + rA.m_strStaion + "<br>");
			daoAir.updateAirkorea(rA, false);
		}
	}

	daoAir.disConnection();

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	out.println(joReturn.toString());
	
	//return ;
%>








