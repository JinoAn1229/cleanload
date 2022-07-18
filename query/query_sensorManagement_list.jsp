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
<%@ page import="wguard.dao.DaoSensor" %>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord" %>

 

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

	
	
	String strUID = EtcUtils.NullS(request.getParameter("uid"));
	
	
	DaoSensor daoS = new DaoSensor();    
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
		if(strDateS.isEmpty() || strDateE.isEmpty())
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","parameter mismatch ( date )");
			out.println(joReturn.toString());
			return ;
		}
		dateST = EtcUtils.getJavaDate(strDateS);
		dateEnd = EtcUtils.getJavaDate(strDateE);
		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);
		strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoS.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoS.m_strDBType) + ")";    //바꿀부분  
	}
	
	
	if(!strUID.isEmpty())
	{
		strWhere =  "USER_ID  like  '%" + strUID + "%'";
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
	
		
		ArrayList<DaoSensorRecord> arySensonSts = daoS.selectUserForList(strWhere,strOrderBy,nFirstRecordNo,nFirstRecordNo+nListPerUage-1,false);
		
		JSONObject joD = null;
		JSONArray jaD = new JSONArray();

		for(DaoSensorRecord rU : arySensonSts)
		{		
			joD = new JSONObject();
			joD.put("no",nFirstRecordNo++);
			joD.put("name",rU.m_strSName);
			joD.put("id",rU.m_strUID);
			joD.put("sdate",EtcUtils.getStrDate(rU.m_dateReg,"yyyy-MM-dd HH:mm:ss.SSS"));
			joD.put("sid",rU.m_strSID);
			joD.put("gid",rU.m_strGID);
			joD.put("alarm",rU.m_strAlarmState);
			
			jaD.put(joD);
		}
		
		
		
		joReturn.put("result","OK");
		joReturn.put("msg","success");
		joReturn.put("tot_count",Integer.toString(nTotalRecordCnt));
		joReturn.put("members",jaD);
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