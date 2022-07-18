<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="wguard.dao.DaoSensorSt" %>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>
<%@ page import="wguard.dao.DaoLinkSensor" %>
<%@ page import="wguard.dao.DaoLinkSensor.DaoLinkSensorRecord" %>

<%@ include file="./include_session_query.jsp" %> 

<%!

ArrayList<String> getSensorData(String strPolesID, Date dStart, Date dEnd)
{
	ArrayList<String> aryReg = new ArrayList<String>();
	
	//폴대에 연동된 센서 녹록을 구한다
	DaoLinkSensor daoLink = new DaoLinkSensor();
	ArrayList<DaoLinkSensorRecord> arySensorList = daoLink.selectSensor(strPolesID, true);
	if(arySensorList.size() == 0) return aryReg;
	
	DaoSensorSt daoS = new DaoSensorSt();
	
	float fHighD = -9999.0f;
	float fLowD = 9999.0f;
	float fHighU = -9999.0f;
	float fLowU = 9999.0f;
	float fHighP = -9999.0f;
	float fLowP = 9999.0f;
	
	try
	{
		if(!daoS.connection()) return aryReg;
		
		Date dateST = EtcUtils.addDateMin(dStart, -30);
		Date dateEnd = EtcUtils.addDateMin(dEnd, 60);
		
		String strWhereStartDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoS.m_strDBType) + " and REG_DATE <= " + EtcUtils.getSqlDate(dStart,daoS.m_strDBType) + ")";
		String strWhereEndDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dEnd,daoS.m_strDBType) + " and REG_DATE <= " + EtcUtils.getSqlDate(dateEnd,daoS.m_strDBType) + ")";

		String strWhere = "";
		
		int nIndex = 0;
		int nSStIndex = 0;
		float fTemp = 0.0f;
		
		for(nIndex = 0 ; nIndex < arySensorList.size() ; nIndex++)
		{
			String strWhereID = "SENSOR_ID ='" + arySensorList.get(nIndex).m_strLinkSID + "'" ; 
			strWhere = strWhereID + " and " + strWhereStartDate;
			ArrayList<DaoSensorStRecord> arySSt = daoS.selectSensorManagerList(strWhere,false);
			String[] astrExp;

			for(nSStIndex = 0 ; nSStIndex < arySSt.size() ; nSStIndex++)
			{
				astrExp = EtcUtils.splitString(arySSt.get(nSStIndex).m_strExpansion,"=\\",true,false);
				for(int i=0; i<astrExp.length; i+=2 )
				{
					if(astrExp.length > i+1)
					{
						if(astrExp[i].equals("d"))
						{
							fTemp = Float.parseFloat(astrExp[i+1]);
							if(fHighD < fTemp) fHighD = fTemp;  
						}
						if(astrExp[i].equals("u"))
						{
							fTemp = Float.parseFloat(astrExp[i+1]);
							if(fHighU < fTemp) fHighU = fTemp;  
						}
						if(astrExp[i].equals("p"))
						{
							fTemp = Float.parseFloat(astrExp[i+1]);
							if(fHighP < fTemp) fHighP = fTemp;  
						}

					}
				}

			}
			
			strWhere = strWhereID + " and " + strWhereEndDate;
			arySSt = daoS.selectSensorManagerList(strWhere,false);
			for(nSStIndex = 0 ; nSStIndex < arySSt.size() ; nSStIndex++)
			{
				astrExp = EtcUtils.splitString(arySSt.get(nSStIndex).m_strExpansion,"=\\",true,false);
				for(int i=0; i<astrExp.length; i+=2 )
				{
					if(astrExp.length > i+1)
					{
						if(astrExp[i].equals("d"))
						{
							fTemp = Float.parseFloat(astrExp[i+1]);
							if(fLowD > fTemp) fLowD = fTemp;  
						}
						if(astrExp[i].equals("u"))
						{
							fTemp = Float.parseFloat(astrExp[i+1]);
							if(fLowU > fTemp) fLowU = fTemp;  
						}
						if(astrExp[i].equals("p"))
						{
							fTemp = Float.parseFloat(astrExp[i+1]);
							if(fLowP > fTemp) fLowP = fTemp;  
						}

					}
				}

			}
			
		}

		aryReg.add(Float.toString(fHighD));
		aryReg.add(Float.toString(fLowD));
		aryReg.add(Float.toString(fHighU));
		aryReg.add(Float.toString(fLowU));
		aryReg.add(Float.toString(fHighP));
		aryReg.add(Float.toString(fLowP));
	}
	finally
	{
		if(daoS.isConnected())
			daoS.disConnection();
	}
	return aryReg;
}

%>


<%

//-----------------------------	
// 회원 리스트를 검색하는  쿼리호출이다.
// pg : 리스트를 보여풀 페이지 번호
// lpp: 한페이지에 보여줄 리스트 갯수
// stype : 검색조건 형식, 
//     name  :   sval 파라메터로 회원 이름 이 전달된다.
//     id       :   sval 파라메터로 회원 ID가 전달된다.
//     addr   :   sval 파라메터로 주소가 전달된다.
// dtend : true 경우 
//             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
//             dates >=  회원등록일  <= datee 조건으로 이용됨
	JSONObject joReturn = new JSONObject();
	if(!bSessionOK)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}
	
	String strSID = EtcUtils.NullS(request.getParameter("sid"));
	String strDateS = EtcUtils.NullS(request.getParameter("dates"));
	String strDateE = EtcUtils.NullS(request.getParameter("datee"));
	String strTimeSet = EtcUtils.NullS(request.getParameter("time"));

	if( strSID.isEmpty() )
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter mismatch");
		out.println(joReturn.toString());
		return ;
	}

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

	Date dateST = null;
	Date dateEnd = null;
	String strWhereDate = "";

	DaoSensorSt daoSSt = new DaoSensorSt();

	dateST = EtcUtils.getJavaDate(strDateS);
	dateEnd = EtcUtils.getJavaDate(strDateE);

	if(strTimeSet.indexOf("hours") >= 0)
		dateEnd = EtcUtils.addDateHour(dateEnd,1);
	else
		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);

	strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoSSt.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoSSt.m_strDBType) + ") ORDER BY reg_date DESC";    //바꿀부분  

	String strWhere = "";
	strWhere =  "SENSOR_ID ='" + strSID + "'" ;
	if(!strWhereDate.isEmpty())	strWhere += " and " + strWhereDate;
	
	ArrayList<DaoSensorStRecord> arySSt = daoSSt.selectSensorManagerList(strWhere,true);

	JSONObject joPS = null;
	JSONArray jaPS = new JSONArray();
	
	String[] astrExp;

	String strStartWater = "";
	String strEndWater = "";
	String strStartElec = "";
	String strEndElec = "";

	Date dStartTime = null;
	Date dEndTime = null;

	//지금 값
	int nWater = 0;
	//하나 전 값
	int nTempWater1 = 0;
	//두개 전 값
	int nTempWater2 = 0;

	int nTempIndex = 0;

	int nFirstRecordNo = 0;

	int i=0;
	for(int nIndex = 0 ; nIndex < arySSt.size() ; nIndex++)
	{		
		astrExp = EtcUtils.splitString(arySSt.get(nIndex).m_strExpansion,"=\\",true,false);
		for(i=0; i<astrExp.length; i+=2 )
		{
			if(astrExp.length > i+1)
			{
				if(astrExp[i].equals("w")) nWater = Integer.parseInt(astrExp[i+1]);
				break;
			}
		}

		if(nTempWater1 == 0 && nWater == 1)
		{
			//w값이 0에서 1로 변경됨 하나 전 0이었던 시점 값을 가져온다
			//00111100 일경우 첫번째 값 (현 위치 = 3번째임)
			//두번째 값의 경우 최종 변화량이 집계되지 않는 경우가 발생 할 수 있다
			nTempIndex = nIndex - 2;
			//단 10111100 일경우 두번째 값을 가져온다
			if(nTempWater2 != 0) nTempIndex = nIndex - 1;
			if(nTempIndex < 0) nTempIndex = 0;
			
			astrExp = EtcUtils.splitString(arySSt.get(nTempIndex).m_strExpansion,"=\\",true,false);
			
			for(i=0; i<astrExp.length; i+=2 )
			{
				if(astrExp.length > i+1)
				{
					if(astrExp[i].equals("f")) strEndWater = astrExp[i+1];
					if(astrExp[i].equals("e")) strEndElec = astrExp[i+1];
				}
			}
			
			//시간의 경우 00111100에서 두번째 값을 가져온다
			nTempIndex = nIndex - 1;
			if(nTempIndex < 0) nTempIndex = 0;
			
			dEndTime = arySSt.get(nTempIndex).m_dateReg;
		}

		if(nTempWater1 == 1 && nWater == 0)
		{
			//w값이 1에서 0으로 변경됨 0이었던 시점 값을 가져온다
			//00111100 일경우 일곱번째 값
			astrExp = EtcUtils.splitString(arySSt.get(nIndex).m_strExpansion,"=\\",true,false);
			
			for(i=0; i<astrExp.length; i+=2 )
			{
				if(astrExp.length > i+1)
				{
					if(astrExp[i].equals("f")) strStartWater = astrExp[i+1];
					if(astrExp[i].equals("e")) strStartElec = astrExp[i+1];
				}
			}
			dStartTime = arySSt.get(nIndex).m_dateReg;
			
			ArrayList<String> arySensorData =  getSensorData(strSID, dStartTime, dEndTime);

			joPS = new JSONObject();
			joPS.put("no",nFirstRecordNo++);	
			joPS.put("stime",EtcUtils.getStrDate(dStartTime,"yyyy-MM-dd HH:mm:ss"));  
			joPS.put("etime",EtcUtils.getStrDate(dEndTime,"yyyy-MM-dd HH:mm:ss"));
			joPS.put("swater",strStartWater);  
			joPS.put("ewater",strEndWater);
			joPS.put("selec",strStartElec);  
			joPS.put("eelec",strEndElec);
			if(arySensorData.size() == 6)
			{
				joPS.put("highd",arySensorData.get(0));
				joPS.put("lowd",arySensorData.get(1));
				joPS.put("highu",arySensorData.get(2));
				joPS.put("lowu",arySensorData.get(3));
				joPS.put("highp",arySensorData.get(4));
				joPS.put("lowp",arySensorData.get(5));
			}
		
			jaPS.put(joPS);
		}
		
		nTempWater2 = nTempWater1;
		nTempWater1 = nWater;
	}
	

	joReturn.put("result","OK");
	joReturn.put("msg","success");
	joReturn.put("members",jaPS);
	out.println(joReturn.toString());
%>