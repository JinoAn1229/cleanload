<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.io.*"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="wguard.dao.DaoSensorSt" %>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>
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
    response.setHeader("Content-Disposition","attachment;filename=date.xls");

	if(!bSessionOK)
	{
		out.println("FAIL\tsession not found");
		return ;
	}
	
	int i;
	
	String strSensorType = EtcUtils.NullS(request.getParameter("sensorType"));
	if(strSensorType.isEmpty())
	{
		out.println("FAIL\tparameter mismatch ( sensorType)");
		return ;
	}
	
	String strSearchType = EtcUtils.NullS(request.getParameter("stype"));
	if(strSearchType.isEmpty())
	{
		out.println("FAIL\tparameter mismatch ( stype)");
		return ;
	}
	DaoSensorSt daoSensorSt = new DaoSensorSt();
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

	String strQuery = "";
	Date dateST = null;
	Date dateEnd = null;
	String strSearchValue = "";
	String strWhereDate = "";
	String strWhereVal = "";
	String strWhere = "";	
	String strOrderBy = "REG_DATE desc";	
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
		strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoSensorSt.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoSensorSt.m_strDBType) + ")";
	}



	
	
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
		out.println("FAIL\tparameter mismatch ( stype)");
		return ;
	}

	UserExpireCheck bizUEC = new UserExpireCheck();

	try
	{
	
		if(!daoSensorSt.connection())
		{
			out.println("FAIL\tdatabase connection fail");
			return ;	
		}
		
		strQuery = "select * from DM_SENSOR_ST where " + strWhere;
		int nRecordCnt = 1;
		ArrayList<DaoSensorStRecord> arySensorSt = daoSensorSt.selectSensorManagerList(strWhere,strOrderBy,false);
		
		daoSensorSt.disConnection();
		
		if(!bizUEC.connection())
		{
			out.println("FAIL\tdatabase connection fail");
			return ;
		}

		
		Date dateTemp = null;
		StringBuffer strbList = new StringBuffer();
		StringBuffer strbLine = new StringBuffer();
		
		strbLine.append("시간\t");
		
		if(strSensorType.equals("t"))
		{
			strbLine.append("온도\r\n");
		}
		else if(strSensorType.equals("h"))
		{
			strbLine.append("습도\r\n");
		}
		else if(strSensorType.equals("c"))
		{
			strbLine.append("이산화탄소\r\n");
		}
		else if(strSensorType.equals("p"))
		{
			strbLine.append("미세먼지\r\n");
		}
		else if(strSensorType.equals("u"))
		{
			strbLine.append("초미세먼지\r\n");
		}
		else if(strSensorType.equals("o"))
		{
			strbLine.append("소음\r\n");
		}
		else if(strSensorType.equals("i"))
		{
			strbLine.append("화학성유기화합물\r\n");
		}
		else if(strSensorType.equals("n"))
		{
			strbLine.append("질소산화물\r\n");
		}
		else if(strSensorType.equals("s"))
		{
			strbLine.append("황산화물\r\n");
		}
		else
		{
			strbLine.append("온도\t");
			strbLine.append("습도\t");
			strbLine.append("이산화탄소\t");
			strbLine.append("미세먼지\t");
			strbLine.append("초미세먼지\t");
			strbLine.append("소음\t");
			strbLine.append("휘발성유기화학물\t");
			strbLine.append("질소산화물\t");
			strbLine.append("황산화물\r\n");
		}
		
		strbList.append(strbLine.toString());
		
		String strT = "";
		String strH = "";
		String strC = "";
		String strP = "";
		String strU = "";
		String strO = "";
		String strI = "";
		String strN = "";
		String strS = "";

		for(DaoSensorStRecord rSt : arySensorSt)
		{
			String[] astrExp= EtcUtils.splitString(rSt.m_strExpansion,"=\\",true,false);
			for(int nIndex=0; nIndex<astrExp.length; nIndex+=2 )
			{
				if(astrExp.length > nIndex+1)
				{
					if(astrExp[nIndex].equals("t")) strT = astrExp[nIndex+1];
					else if(astrExp[nIndex].equals("h")) strH = astrExp[nIndex+1];
					else if(astrExp[nIndex].equals("c")) strC = astrExp[nIndex+1];
					else if(astrExp[nIndex].equals("p")) strP = astrExp[nIndex+1];
					else if(astrExp[nIndex].equals("u")) strU = astrExp[nIndex+1];
					else if(astrExp[nIndex].equals("o")) strO = astrExp[nIndex+1];
					else if(astrExp[nIndex].equals("i"))  strI = astrExp[nIndex+1];
					else if(astrExp[nIndex].equals("n")) strN = astrExp[nIndex+1];
					else if(astrExp[nIndex].equals("s")) strS = astrExp[nIndex+1];
				}
			}
			
			strbLine.setLength(0);
			strbLine.append(EtcUtils.getStrDate(rSt.m_dateReg,"yyyy-MM-dd HH:mm:ss") + "\t");
			if(strSensorType.equals("t"))
			{
				strbLine.append(strT + "\r\n");
			}
			else if(strSensorType.equals("h"))
			{
				strbLine.append(strH + "\r\n");
			}
			else if(strSensorType.equals("c"))
			{
				strbLine.append(strC + "\r\n");
			}
			else if(strSensorType.equals("p"))
			{
				strbLine.append(strP + "\r\n");
			}
			else if(strSensorType.equals("u"))
			{
				strbLine.append(strU + "\r\n");
			}
			else if(strSensorType.equals("o"))
			{
				strbLine.append(strO + "\r\n");
			}
			else if(strSensorType.equals("i"))
			{
				strbLine.append(strI + "\r\n");
			}
			else if(strSensorType.equals("n"))
			{
				strbLine.append(strN + "\r\n");
			}
			else if(strSensorType.equals("s"))
			{
				strbLine.append(strS + "\r\n");
			}
			else
			{
				strbLine.append(strT + "\t");
				strbLine.append(strH + "\t");
				strbLine.append(strC + "\t");
				strbLine.append(strP + "\t");
				strbLine.append(strU + "\t");
				strbLine.append(strO + "\t");
				strbLine.append(strI + "\t");
				strbLine.append(strN + "\t");
				strbLine.append(strS + "\r\n");
			}
			
			
			strbList.append(strbLine.toString());
		}

		out.clear(); 
		EtcUtils.sendResponseData(response , strbList.toString().getBytes("euc-kr")); 
		out.flush();
	}
	finally
	{
		if(daoSensorSt.isConnected())
			daoSensorSt.disConnection();
		bizUEC.disConnection();
	}
%>