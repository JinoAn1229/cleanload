<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="cleanmanager.biz.BizPush" %>
<%@ page import="cleanmanager.biz.BizPush.BizPushRecord" %>

<%@ include file="./include_session_proc.jsp" %> 

<%

//-----------------------------	
// Push message 전송 목록을 검색하는  쿼리호출이다.
// stype : 검색조건 형식, 
//     name  :   sval 파라메터로 회원 이름 이 전달된다.
//     id       :   sval 파라메터로 회원 ID가 전달된다.
//     addr   :   sval 파라메터로 주소가 전달된다.
// dtend : true 경우 
//             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
//             dates >=  회원등록일  <= datee 조건으로 이용됨

    response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition","attachment;filename=pushHistory.xls");
    
	if(!bSessionOK)
	{
		out.println("FAIL\tsession not found");
		return ;
	}
	
	int i;
	
	
	String strSearchType = EtcUtils.NullS(request.getParameter("stype"));
	if(strSearchType.isEmpty())
	{
		out.println("FAIL\tparameter mismatch ( stype)");
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
			out.println("FAIL\tparameter mismatch ( date)");
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
		else if(strSearchType.equals("name"))
		{
			strWhereVal = "a.USER_NAME  like  '%" + strSearchValue + "%'";
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
			out.println("FAIL\tparameter mismatch");
			return ;
		}
	}


	try
	{
		if(!bizP.connection())
		{
			out.println("FAIL\tdatabase connection fail");
			return ;	
		}

		int nRecordCnt = 1;
		ArrayList<BizPushRecord> aryBP = bizP.selectPush(strWhere,false);
		
		StringBuffer strbList = new StringBuffer();
		StringBuffer strbLine = new StringBuffer();

		strbLine.append("no\t");
		strbLine.append("name\t");
		strbLine.append("id\t");
		strbLine.append("date\t");
		strbLine.append("msg\r\n");
		
		//out.write(strbLine.toString());
		strbList.append(strbLine.toString());
		
		for(BizPushRecord rP : aryBP)
		{
			strbLine.setLength(0);
			strbLine.append("" + nRecordCnt++ + "\t");
			strbLine.append(rP.m_strName + "\t");
			strbLine.append(rP.m_strID + "\t");
			strbLine.append(EtcUtils.getStrDate(rP.m_dateOccur,"yyyy-MM-dd") + "\t");
			strbLine.append(rP.m_strPushMsg + "\r\n");
			
			//out.write(strbLine.toString());
			strbList.append(strbLine.toString());
		}
		out.clear(); 
		EtcUtils.sendResponseData(response , strbList.toString().getBytes("euc-kr")); 
		out.flush();
	}
	finally
	{
		if(bizP.isConnected())
			bizP.disConnection();
	}
%>