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
<%@ page import="wguard.dao.DaoApiKma"%>
<%@ page import="wguard.dao.DaoApiKma.DaoApiKmaRecord"%>

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
	
	JSONObject joReturn = new JSONObject();
	int i = 0;
	int nIndex = 0;
	String strWhereDate = "";
	String strWhere = "";
	
	String strStation = EtcUtils.NullS(request.getParameter("kmsst"));

	if(strStation.isEmpty()) strStation = "112";


	String strKmaUrl = "http://apis.data.go.kr/1360000/SfcInfoService/getStnbyRtmObs?dataType=JSON";
	strKmaUrl += "&stnId=" + strStation + "&numOfRows=10&pageNo=1";
	strKmaUrl += "&serviceKey=ztAwASBpMilBA4z9Z0Cx9HE9yTBFcpPxQmjPxEWsKlHbB%2Bm9XVIqNK9CqiDPfD2wyvBzMhak5ZC4L7MZNGgbwA%3D%3D";

	URL urlKma = new URL(strKmaUrl);
	HttpURLConnection conKma = (HttpURLConnection) urlKma.openConnection();

	BufferedReader inKma = new BufferedReader(new InputStreamReader(conKma.getInputStream(), "UTF-8"));

	String strInputLine;
	StringBuffer sbResponse = new StringBuffer();

	while ((strInputLine = inKma.readLine()) != null)
	{
		sbResponse.append(strInputLine);
	}

	inKma.close();

	JSONObject joKma = new JSONObject(sbResponse.toString());
	JSONArray jaKmaList = (JSONArray)joKma.getJSONObject("response").getJSONObject("body").getJSONObject("items").get("item");

	JSONObject joKmaTemp = null;
	
	String strTemp;

	DaoApiKma DaoApiKma = new DaoApiKma();

	if(!DaoApiKma.connection())
	{
		joReturn.put("result","ERROR");
		joReturn.put("msg","DB ERROR");
		out.println(joReturn.toString());
		return ;
	}
	
	SimpleDateFormat formatter=new SimpleDateFormat("yyyyMMddHH"); 

	for( i=0 ; i < jaKmaList.length() ; i++)
	{
		joKmaTemp = jaKmaList.getJSONObject(i);
		String strTime = joKmaTemp.getString("time");
		Date date=formatter.parse(strTime);

		DaoApiKma.DaoApiKmaRecord rK = DaoApiKma.new DaoApiKmaRecord();

		rK.m_dateReg = date;
		rK.m_strStaion = strStation;

		strTemp = joKmaTemp.getString("groundTemperature");
		if(isNumeric(strTemp)) rK.m_fTS = Float.parseFloat(strTemp);

		strTemp = joKmaTemp.getString("humidity");
		if(isNumeric(strTemp)) rK.m_fHM = Float.parseFloat(strTemp);

		strTemp = joKmaTemp.getString("temperature");
		if(isNumeric(strTemp)) rK.m_fTA = Float.parseFloat(strTemp);

		if(DaoApiKma.getKma(date, strStation, false) == null)
		{
			DaoApiKma.insertKma(rK, false);
		}
		else
		{
			DaoApiKma.updateKma(rK, false);
		}
	}

	DaoApiKma.disConnection();

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	out.println(joReturn.toString());
%>








