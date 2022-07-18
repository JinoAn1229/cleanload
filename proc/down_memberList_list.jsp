<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.io.*"%>
<%@ page import="common.util.EtcUtils" %>

<%@ page import="wguard.dao.DaoUser" %>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord" %>
<%@ page import="wguard.biz.UserExpireCheck" %>

<%@ include file="./include_session_proc.jsp" %> 

<%

//-----------------------------	
// 회원 리스트를 검색하는  쿼리호출이다.
// [memberList.jsp , AS.jsp 2곳에서 같이 이용한다. down_AS_list.jsp를 따로 만들어야 하지만 통일한 기능을 하기 때문에 같이 사용함 ]
// stype : 검색조건 형식, 
//     name  :   sval 파라메터로 회원 이름 이 전달된다.
//     id       :   sval 파라메터로 회원 ID가 전달된다.
//     addr   :   sval 파라메터로 주소가 전달된다.
// dtend : true 경우 
//             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
//             dates >=  회원등록일  <= datee 조건으로 이용됨

    response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition","attachment;filename=member.xls");

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
	DaoUser daoU = new DaoUser();
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
			out.println("FAIL\tparameter mismatch ( stype)");
			return ;
		}
		dateST = EtcUtils.getJavaDate(strDateS);
		dateEnd = EtcUtils.getJavaDate(strDateE);
		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);
		strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoU.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoU.m_strDBType) + ")";
	}


	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	if(!strSearchValue.isEmpty())
	{
		
		if(strSearchType.equals("id"))
		{
			strWhereVal = "USER_ID like  '%" + strSearchValue + "%'";
		}
		else if(strSearchType.equals("name"))
		{
			strWhereVal = "USER_NAME  like  '%" + strSearchValue + "%'";
		}

	}
	
	if(!strWhereVal.isEmpty())
	{
		strWhere = strWhereVal;
		if(!strWhereDate.isEmpty())
		{
			strWhere += " and " + strWhereDate;
		}
	}
	else
	{
		if(!strWhereDate.isEmpty())
		{
			strWhere = strWhereDate;
		}
		else
		{
			out.println("FAIL\tparameter mismatch ( stype)");
			return ;
		}
	}

	UserExpireCheck bizUEC = new UserExpireCheck();

	try
	{
	
		if(!daoU.connection())
		{
			out.println("FAIL\tdatabase connection fail");
			return ;	
		}
		
		strQuery = "select * from DM_USER where " + strWhere;
		int nRecordCnt = 1;
		ArrayList<DaoUserRecord> aryUsers = daoU.selectUser(strWhere,"REG_DATE desc",false);
		
		daoU.disConnection();
		
		if(!bizUEC.connection())
		{
			out.println("FAIL\tdatabase connection fail");
			return ;
		}

		
		Date dateTemp = null;
		StringBuffer strbList = new StringBuffer();
		StringBuffer strbLine = new StringBuffer();
		strbLine.append("no\t");
		strbLine.append("name\t");
		strbLine.append("id\t");	
		strbLine.append("reg_dt\t");		
		strbLine.append("dev_info\r\n");
		
		//out.write(strbLine.toString());
		strbList.append(strbLine.toString());

		for(DaoUserRecord rU : aryUsers)
		{
			strbLine.setLength(0);
			strbLine.append("" + nRecordCnt++ + "\t");
			strbLine.append(rU.m_strName + "\t");
			strbLine.append(rU.m_strID + "\t");
			strbLine.append(EtcUtils.getStrDate(rU.m_dateReg,"yyyy-MM-dd") + "\t");
			strbLine.append(rU.m_strDeviceModel + "\r\n");
			
			//out.write(strbLine.toString());
			strbList.append(strbLine.toString());
		}

		out.clear(); 
		EtcUtils.sendResponseData(response , strbList.toString().getBytes("euc-kr")); 
		out.flush();
	}
	finally
	{
		if(daoU.isConnected())
			daoU.disConnection();
		bizUEC.disConnection();
	}
%>