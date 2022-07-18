<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.io.DataOutputStream"%>
<%@ page import="java.io.InputStreamReader"%>
<%@ page import="java.net.HttpURLConnection"%>
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

String strStation = EtcUtils.NullS(request.getParameter("kmsst"));
String strStationX = EtcUtils.NullS(request.getParameter("kmsstX"));
String strStationY = EtcUtils.NullS(request.getParameter("kmsstY"));

Date dateKma = new Date();
//기상청을 40분 이후부터 데이터 수집이 가능하다
//그러므로 안전하게 한시간 전 데이터를 가져온다
dateKma = EtcUtils.addDateHour(dateKma,-1, true);

//장소는 스테이션 아이디에 따라 변경되어야 한다
//기상청 API 문서 참조
//지상 종관 ASOS 시간자료 서비스를 기준으로 저장하므로 이 문서의 장소 아이디에
//맞는 XY값을 동네예보 조회 서비스에서 확인해야 한다
if(strStation.isEmpty()) strStation = "108";
if(strStationX.isEmpty()) strStationX = "60";
if(strStationY.isEmpty()) strStationY = "127";

String url = "http://apis.data.go.kr/1360000/VilageFcstInfoService/getUltraSrtNcst";
url += "?serviceKey=ztAwASBpMilBA4z9Z0Cx9HE9yTBFcpPxQmjPxEWsKlHbB%2Bm9XVIqNK9CqiDPfD2wyvBzMhak5ZC4L7MZNGgbwA%3D%3D";
url += "&base_date=" + EtcUtils.getStrDate(dateKma,"yyyyMMdd") + "&base_time=" + EtcUtils.getStrDate(dateKma,"HH") + "00";
url += "&nx=" + strStationX + "&ny="+strStationY+"&numOfRows=10&pageNo=1&dataType=json";

StringBuffer sbResponse = new StringBuffer();

try
{
	URL obj = new URL(url);
	HttpURLConnection con = (HttpURLConnection) obj.openConnection();

	con.setRequestMethod("GET");

	BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));

	String strInputLine;

	while ((strInputLine = in.readLine()) != null)
	{
		sbResponse.append(strInputLine);
	}
		
	in.close();
}
catch(Exception e)
{
	joReturn.put("result","FAIL");
	joReturn.put("msg","api open error");
	out.println(joReturn.toString());
	return ;
}

JSONObject joKma = null;
JSONObject joResponse = null;
JSONObject joBody = null;
JSONObject joItems = null;
JSONArray jaItem = null;

try
{
	joKma = new JSONObject(sbResponse.toString());
	joResponse = (JSONObject)joKma.get("response");
	joBody = (JSONObject)joResponse.get("body");
	joItems = (JSONObject)joBody.get("items");
	jaItem = (JSONArray)joItems.get("item");
}
catch(Exception e)
{
	joReturn.put("result","FAIL");
	joReturn.put("msg","api json error");
	out.println(joReturn.toString());
	return ;
}

JSONObject joTemp = null;
String strKey;
String strValue;

JSONObject joSSt = null;
JSONArray jaSSt = new JSONArray();

DaoApiKma DaoApiKma = new DaoApiKma();
DaoApiKma.DaoApiKmaRecord rK = DaoApiKma.new DaoApiKmaRecord();

rK.m_dateReg = dateKma;
rK.m_strStaion = strStation;

for( int i = 0 ; i < jaItem.length() ; i++)
{
	joTemp = jaItem.getJSONObject(i);
	if(joTemp == null) continue;

	strKey = joTemp.getString("category");
	strValue = joTemp.getString("obsrValue");	

	if(strKey.equals("T1H"))
	{
		if(isNumeric(strValue))
		{
			rK.m_fTS = Float.parseFloat(strValue);
			rK.m_fTA = rK.m_fTS;
		}
	}
	else if(strKey.equals("REH"))
	{
		if(isNumeric(strValue)) rK.m_fHM = Float.parseFloat(strValue);
	}
}

if(DaoApiKma.getKma(dateKma, strStation, true) == null)
{
	DaoApiKma.insertKma(rK, true);
}
else
{
	DaoApiKma.updateKma(rK, true);
}


joReturn.put("result","OK");
joReturn.put("msg","success");
out.println(joReturn.toString());
%>
