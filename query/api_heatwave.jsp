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
<%@ page import="wguard.dao.DaoApiNews"%>
<%@ page import="wguard.dao.DaoApiNews.DaoApiNewsRecord"%>
<%!
	public boolean isNumeric(String s)
	{
		try {
			Integer.parseInt(s);
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
	
	String strAreaCode = EtcUtils.NullS(request.getParameter("areacode"));
	
	if(strAreaCode.isEmpty())
	{
		out.println("FAIL");
		return ; 
	}
	
	//String strAreaCode = "L1020510"; //테스트 속초
	
	String url = "http://apis.data.go.kr/1360000/WthrWrnInfoService/getPwnCd";
	url += "?serviceKey=ztAwASBpMilBA4z9Z0Cx9HE9yTBFcpPxQmjPxEWsKlHbB%2Bm9XVIqNK9CqiDPfD2wyvBzMhak5ZC4L7MZNGgbwA%3D%3D";
	url += "&numOfRows=10&pageNo=1&warningType=12&areaCode="+strAreaCode+"&dataType=json";

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

	JSONObject joHeat = new JSONObject(sbResponse.toString());

	JSONObject joResult =  joHeat.getJSONObject("response").getJSONObject("header");
	String strResult = joResult.get("resultCode").toString();
	
	if(strResult.equals("00"))
	{
		DaoApiNews daoApiNews = new DaoApiNews();
		
		if(!daoApiNews.connection())
		{
			joReturn.put("result","ERROR");
			joReturn.put("msg","DB ERROR");
			out.println(joReturn.toString());
			return ;
		}
			
		JSONArray jaHeatList = (JSONArray)joHeat.getJSONObject("response").getJSONObject("body").getJSONObject("items").get("item");
		JSONObject joHeatTemp = null;
		String strTemp;
		
		String strFcTime ="";
		String strStartTime ="";
		String strEndTime ="";
	
		Date dateFc = new Date();
		Date dateStart = new Date();
		Date dateEnd = new Date();

		
		for(int i=0 ; i < jaHeatList.length() ; i++)
		{
			DaoApiNews.DaoApiNewsRecord rAR = daoApiNews.new DaoApiNewsRecord();

			joHeatTemp = jaHeatList.getJSONObject(i);
			
			strFcTime = joHeatTemp.getString("tmFc");
			strStartTime = joHeatTemp.getString("startTime");
			strEndTime = joHeatTemp.getString("endTime");
			
			SimpleDateFormat SimpleDate = new SimpleDateFormat ("yyyy.MM.dd");	
			DateFormat sdFormat = new SimpleDateFormat("yyyyMMddhhmm");
			
			dateFc = sdFormat.parse(strFcTime);
			rAR.m_dateFc = dateFc;
			
			if(strStartTime.equals("0"))
			{						
				strStartTime = SimpleDate.format(dateStart);
				dateStart = SimpleDate.parse(strStartTime);
				rAR.m_dateStart = null;
			}
			else
			{
				dateStart = sdFormat.parse(strStartTime);
				rAR.m_dateStart = dateStart;
			}
			
			if(strEndTime.equals("0"))
			{
				strEndTime = SimpleDate.format(dateEnd);
				dateEnd = SimpleDate.parse(strEndTime);
				rAR.m_dateEnd = null;
			}
			else
			{
				dateEnd = sdFormat.parse(strEndTime);
				rAR.m_dateEnd = dateEnd;
			}
			
			rAR.m_strAreaCode = strAreaCode;
			
			strTemp = joHeatTemp.getString("warnVar");
			if(isNumeric(strTemp)) rAR.m_nWarnVal = Integer.parseInt(strTemp);
			
			strTemp = joHeatTemp.getString("warnStress");
			if(isNumeric(strTemp)) rAR.m_nWarnStress = Integer.parseInt(strTemp);
			
			strTemp = joHeatTemp.getString("command");
			if(isNumeric(strTemp)) rAR.m_nCommand = Integer.parseInt(strTemp);
			
			if(daoApiNews.getApiNews(dateFc, strAreaCode, rAR.m_nWarnVal, false) == null)
			{
				daoApiNews.insertApiNews(rAR, false);
			}
			else
			{
				daoApiNews.updateApiNews(rAR, false);
			}
		}

		daoApiNews.disConnection();	
	}
	
	
	joReturn.put("value",strResult);
	joReturn.put("result","OK");
	joReturn.put("msg","success");
	out.println(joReturn.toString());
	
%>








