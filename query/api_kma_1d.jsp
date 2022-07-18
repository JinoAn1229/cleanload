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
	Date dateST = null;
	Date dateEnd = null;
	String strWhereDate = "";
	String strWhere = "";
	
	String strDateS = EtcUtils.NullS(request.getParameter("dates"));
	String strDateE = EtcUtils.NullS(request.getParameter("datee"));
	String strStation = EtcUtils.NullS(request.getParameter("kmsst"));

	SimpleDateFormat formatter=new SimpleDateFormat("yyyy-MM-dd HH"); 

	if(strDateS.isEmpty())
	{
		dateST = new Date();
		dateST = EtcUtils.addDateDay(dateST,-7,true);
	}
	else
	{
		dateST = EtcUtils.getJavaDate(strDateS);
		dateST = EtcUtils.addDateDay(dateST,0,true);
	}

	if(strDateE.isEmpty())
	{
		dateEnd = new Date();
		dateEnd = EtcUtils.addDateDay(dateEnd,-2,true);
	}
	else
	{
		dateEnd = EtcUtils.getJavaDate(strDateE);
		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);
	}

	if(strStation.isEmpty()) strStation = "108";

	//기상청 데이터를 받는다
	//전전날 자료까지만 가능하다

	Date dateKmaMax = new Date();
	dateKmaMax = EtcUtils.addDateDay(dateKmaMax,-2,true);
	if(dateEnd.getTime() > dateKmaMax.getTime()) dateEnd = dateKmaMax;


	String strKmaUrl = "http://apis.data.go.kr/1360000/AsosHourlyInfoService/getWthrDataList?dataType=json&dataCd=ASOS&dateCd=HR";
	strKmaUrl += "&startDt=" + EtcUtils.getStrDate(dateST,"yyyyMMdd") + "&startHh=00";
	strKmaUrl += "&endDt=" + EtcUtils.getStrDate(dateEnd,"yyyyMMdd") + "&endHh=23";
	strKmaUrl += "&stnIds=" + strStation + "&numOfRows=200&pageIndex=1&schListCnt=200";
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

	for( i=0 ; i < jaKmaList.length() ; i++)
	{
		joKmaTemp = jaKmaList.getJSONObject(i);
		String strTime = joKmaTemp.getString("tm");
		Date date=formatter.parse(strTime);

		if((date.getTime() < dateST.getTime()) || (date.getTime() >= dateEnd.getTime()))  continue;

		DaoApiKma.DaoApiKmaRecord rK = DaoApiKma.new DaoApiKmaRecord();

		rK.m_dateReg = date;
		rK.m_strStaion = strStation;

		strTemp = joKmaTemp.getString("ts");
		if(isNumeric(strTemp)) rK.m_fTS = Float.parseFloat(strTemp);

		strTemp = joKmaTemp.getString("hm");
		if(isNumeric(strTemp)) rK.m_fHM = Float.parseFloat(strTemp);

		strTemp = joKmaTemp.getString("ta");
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








