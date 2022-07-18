<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="common.util.ListPagingUtil" %>
<%@ page import="wguard.dao.DaoSensorSt" %>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>

<%@ include file="./include_session_query.jsp" %> 

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
	
	int i;
	
	
	String strSearchType = EtcUtils.NullS(request.getParameter("stype"));
	if(strSearchType.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( stype)");
		out.println(joReturn.toString());
		return ;
	}
	
	DaoSensorSt daoS = new DaoSensorSt();    
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

	String strQuery = "";
	Date dateST = null;
	Date dateEnd = null;
	String strSearchValue = "";
	String strWhereDate = "";
	String strWhereVal = "";
	
	String strWhere = "";	
	
	String strOrderBy = "REG_DATE desc";
	String strTempSensor = "";
	
	
	if(strDateAnd.equals("true"))
	{  // 기간  and 조건 추가
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

		strWhereDate = " REG_DATE >= DATE(" + EtcUtils.getSqlDate(dateST,daoS.m_strDBType) + ") and REG_DATE < DATE(" + EtcUtils.getSqlDate(dateEnd,daoS.m_strDBType) + ")";    //바꿀부분  
	}


	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	
	
	if(!strSearchType.isEmpty())
	{
		strWhere =  "SENSOR_ID  like  '%" + strSearchType + "%'";
	}
	
	
	
	if(!strWhereDate.isEmpty())
	{
		strWhere += " and "+ strWhereDate;
	}
	else if(strWhere.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter is empty");
		out.println(joReturn.toString());
		return ;
	}
	

	try
	{
		if(!daoS.connection())
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","database connection fail");
			out.println(joReturn.toString());
			return ;	
		}
		


		int nDispPage = 0;
		int nPageLinkPerDoc = 10;
		int nListPerUage = 10;
		int nTotalRecordCnt = 0;
		int nFirstRecordNo = 0;
		
		nDispPage = EtcUtils.parserInt(request.getParameter("pg"),1);
		nListPerUage = EtcUtils.parserInt(request.getParameter("lpp"),10);
	

		nTotalRecordCnt = (int)daoS.getQueryCount(daoS.getTableName(),strWhere, false);    //바꿀부분
		ListPagingUtil listPager = new ListPagingUtil("Pager",nPageLinkPerDoc,nListPerUage,nDispPage,nTotalRecordCnt,false);

		nFirstRecordNo = listPager.getPageFirstRecordNo();
	
		
		ArrayList<DaoSensorStRecord> arySensonSts = daoS.selectUserForList(strWhere,strOrderBy,nFirstRecordNo,nFirstRecordNo+nListPerUage-1,false);
		
		JSONObject joS = null;
		JSONArray jaS = new JSONArray();
		
		JSONObject   joExp = null;

		for(DaoSensorStRecord rU : arySensonSts)
		{
			
			joExp = new JSONObject();
			String[] astrExp= EtcUtils.splitString(rU.m_strExpansion,"=\\",true,false);
			for(int nIndex=0; nIndex<astrExp.length; nIndex+=2 )
			{
				if(astrExp.length > nIndex+1)
					joExp.put(astrExp[nIndex],astrExp[nIndex+1]);
			}
			
			joS = new JSONObject();
			joS.put("no",nFirstRecordNo++);
			joS.put("use",String.format("%02X", rU.m_nUseGoal));
			joS.put("sdate",EtcUtils.getStrDate(rU.m_dateReg,"yyyy-MM-dd HH:mm:ss.SSS"));
			joS.put("gid",rU.m_strGWID);
			joS.put("sid",rU.m_strSensorID);
			joS.put("state",rU.m_strSensorState);
			joS.put("battery",rU.m_nBatteryLevel);
			joS.put("action",rU.m_strSensorAction);
			joS.put("exp",joExp);
			

			
			jaS.put(joS);
		}
		
		joReturn.put("result","OK");
		joReturn.put("msg","success");
		joReturn.put("tot_count",Integer.toString(nTotalRecordCnt));
		joReturn.put("members",jaS);
		//-----------------------------------------------------------------------------
		// 페이지 navigation html 만들어서 JSON 개체에 추가함
		joReturn.put("PageNavi",listPager.getPagingStyle04());
		
		System.out.println(joReturn.toString());
		
		out.println(joReturn.toString());
		
		return ;
	}
	finally
	{
		if(daoS.isConnected())
			daoS.disConnection();
	}
%>