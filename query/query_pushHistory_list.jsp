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
<%@ page import="cleanmanager.biz.BizPush" %>
<%@ page import="cleanmanager.biz.BizPush.BizPushRecord" %>

<%@ include file="./include_session_query.jsp" %> 

<%

//-----------------------------	
// Push message 전송 목록을 검색하는  쿼리호출이다.
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
	
	BizPush bizP = new BizPush();
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

	String strQuery = "";
	Date dateST = null;
	Date dateEnd = null;
	String strSearchValue = "";
	String strWhereDate = "";
	String strWhereVal = "";
	
	String strWhere = "";		
	
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
		strWhereDate = " ( OCCUR_DATE >= " + EtcUtils.getSqlDate(dateST,bizP.m_strDBType) + " and OCCUR_DATE < " + EtcUtils.getSqlDate(dateEnd,bizP.m_strDBType) + ")";
	}


	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	if(!strSearchValue.isEmpty())
	{
		
		if(strSearchType.equals("id"))
		{
			strWhereVal = "a.USER_ID like  '%" + strSearchValue + "%'";
		}
	}
	
	strWhere = " a.USER_ID = b.USER_ID";
	if(!strWhereVal.isEmpty())
	{
		strWhere +=  " and " + strWhereVal;
		if(!strWhereDate.isEmpty())
		{
			strWhere += " and " + strWhereDate;
		}
	}
	else
	{
		if(!strWhereDate.isEmpty())
		{
			strWhere += " and " + strWhereDate;
		}
		else
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","parameter is empty");
			out.println(joReturn.toString());
			return ;
		}
	}


	try
	{
		if(!bizP.connection())
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","database connection fail");
			out.println(joReturn.toString());
			return ;	
		}

		int nDispPage = 0;
		int nPageLinkPerDoc = 10;
		int nListPerPage = 10;
		int nTotalRecordCnt = 0;
		int nFirstRecordNo = 0;
		
		nDispPage = EtcUtils.parserInt(request.getParameter("pg"),1);
		nListPerPage = EtcUtils.parserInt(request.getParameter("lpp"),10);
	

		nTotalRecordCnt = (int)bizP.getQueryCount(strWhere, false);
		ListPagingUtil listPager = new ListPagingUtil("Pager",nPageLinkPerDoc,nListPerPage,nDispPage,nTotalRecordCnt,false);
	
		nFirstRecordNo = listPager.getPageFirstRecordNo();
		
		ArrayList<BizPushRecord> aryBP = bizP.selectPushForList(strWhere, nFirstRecordNo , (nFirstRecordNo+nListPerPage-1),false);
		
		JSONObject joP = null;
		JSONArray jaP = new JSONArray();

		for(BizPushRecord rP : aryBP)
		{
			joP = new JSONObject();
			joP.put("no",nFirstRecordNo++);
			joP.put("name",rP.m_strName);
			joP.put("id",rP.m_strID);
			joP.put("date",EtcUtils.getStrDate(rP.m_dateOccur,"yyyy-MM-dd HH:mm"));
			joP.put("msg",rP.m_strPushMsg);
			
			jaP.put(joP);
		}
		
		joReturn.put("result","OK");
		joReturn.put("msg","success");
		joReturn.put("tot_count",Integer.toString(nTotalRecordCnt));
		joReturn.put("members",jaP);
		//-----------------------------------------------------------------------------
		// 페이지 navigation html 만들어서 JSON 개체에 추가함
		joReturn.put("PageNavi",listPager.getPagingStyle04());
		
		System.out.println(joReturn.toString());
		
		out.println(joReturn.toString());
		return ;
	}
	finally
	{
		if(bizP.isConnected())
			bizP.disConnection();
	}
%>