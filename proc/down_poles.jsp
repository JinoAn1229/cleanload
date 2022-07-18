<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.io.*"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="wguard.dao.DaoSensorSt" %>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord" %>
<%@ page import="wguard.dao.DaoPolesSt"%>
<%@ page import="wguard.dao.DaoPolesSt.DaoPolesStRecord"%>
<%@ page import="common.util.ListPagingUtil" %>
<%@ page import="wguard.biz.UserExpireCheck" %>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.sql.ResultSet"%>


<%@ include file="./include_session_proc.jsp" %> 

<%!
	int GetPoleExp(ArrayList<DaoSensorStRecord> arySensonSts, boolean bOpenSt)
	{
		String strWater = "";
		String sExp = "";

		for(int nIndex = 0 ; nIndex < arySensonSts.size(); nIndex++)
		{
			sExp = arySensonSts.get(nIndex).m_strExpansion;
			String[] astrExp= EtcUtils.splitString(sExp,"=\\",true,false);
			strWater = "";
			for(int i=0; i<astrExp.length; i+=2 )
			{
				if(astrExp.length > i+1)
				{
					if(astrExp[i].equals("w")) strWater = astrExp[i+1];
				}
			}

			if(bOpenSt == true)
			{
				if(strWater.equals("1")) return nIndex;
			}
			else
			{
				if(strWater.equals("0")) return nIndex;
			}
		}
		return -1;
		
	}
%>

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
	
		JSONObject joReturn = new JSONObject();
	if(!bSessionOK)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}
	
	
	String strSearchType = EtcUtils.NullS(request.getParameter("stype"));
	if(strSearchType.isEmpty())
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","parameter mismatch ( stype)");
		out.println(joReturn.toString());
		return ;
	}
	
	DaoSensorSt daoS = new DaoSensorSt();

	DaoPolesSt daoPS = new DaoPolesSt();   //폴대의 열린시간과 닫힌시간을 알기 위함 
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

	String strQuery = "";
	Date dateST = null;
	Date dateEnd = null;
	String strSearchValue = "";
	String strWhereDate = "";
	String strWhereVal = "";
	
	String strWhere = "";	
	
	String strOrderBy = "REG_DATE DESC";
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
		strWhereDate = " ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,daoPS.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,daoPS.m_strDBType) + ")";    //바꿀부분  
	}


	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	
	
	if(!strSearchType.isEmpty())
	{
		strWhere =  "POLES_ID  like  '%" + strSearchType + "%'";
	}
	if(!strWhereDate.isEmpty())
	{
		strWhere += " and  POLES_ST = '1' and "+ strWhereDate;
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
		if(!daoPS.connection())
		{
			joReturn.put("result","FAIL");
			joReturn.put("msg","database connection fail");
			out.println(joReturn.toString());
			return ;	
		}

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
	

		nTotalRecordCnt = (int)daoPS.getQueryCount(daoPS.getTableName(),strWhere, false);    //바꿀부분
		ListPagingUtil listPager = new ListPagingUtil("Pager",nPageLinkPerDoc,nListPerUage,nDispPage,nTotalRecordCnt,false);

		nFirstRecordNo = listPager.getPageFirstRecordNo();
	
		
		ArrayList<DaoPolesStRecord> aryPolesSts = daoPS.selectUserForList(strWhere,strOrderBy,nFirstRecordNo,nFirstRecordNo+nListPerUage-1,false);   //바꿀부분

	UserExpireCheck bizUEC = new UserExpireCheck();

	
		
		
		if(!bizUEC.connection())
		{
			out.println("FAIL\tdatabase connection fail");
			return ;
		}
	
		StringBuffer strbList = new StringBuffer();
		StringBuffer strbLine = new StringBuffer();
		strbLine.append("물 분사 시작 시간\t");
		strbLine.append("물 분사 종료 시간\t");
		strbLine.append("물 사용량\t");
		strbLine.append("전력 사용량\r\n");
		
		//out.write(strbLine.toString());
		strbList.append(strbLine.toString());
		

		//ArrayList<DaoPolesStRecord> aryPolesSts = daoPS.selectForPolesList(strWhere,strOrderBy,false);  //바꿀부분
		

		JSONObject joPS = null;
		JSONArray jaPS = new JSONArray();

	String sStartExp = "";
		String sEndExp = "";
		String sStartWater = "";
		String sEndWater = "";
		String sStartElec = "";
		String sEndElec = "";
		String[] astrExp;
		int nPoleIndex = 0;
		
		ArrayList<DaoSensorStRecord> arySensonSts = null;

		for(int nIndex = 0 ; nIndex < aryPolesSts.size(); nIndex++)
		{
			Date dStime =  aryPolesSts.get(nIndex).m_dateReg;
			Date dEtime =  new Date(aryPolesSts.get(nIndex).m_dateReg.getTime());
			dEtime.setMinutes(dStime.getMinutes() + aryPolesSts.get(nIndex).m_nWaterTime);
			
			DaoPolesStRecord PsR = daoPS.getEndTime(strSearchType,dStime,dEtime,false);
			if(PsR != null) dEtime = PsR.m_dateReg;	
			
			arySensonSts = daoS.selectAfterTimeSensorList(strSearchType,"100",dStime,false);
			nPoleIndex = GetPoleExp(arySensonSts, true);

			//데이터 오류가 많아 하나 전 값을 가져온다
			if(nPoleIndex > 0) nPoleIndex--;
			//없을덴 걍 첫 값으로 한다
			if(nPoleIndex < 0) nPoleIndex = 0;

			sStartExp = arySensonSts.get(nPoleIndex).m_strExpansion;
			
			astrExp= EtcUtils.splitString(sStartExp,"=\\",true,false);
			for(int i=0; i<astrExp.length; i+=2 )
			{
				if(astrExp.length > i+1)
				{
					if(astrExp[i].equals("f")) sStartWater = astrExp[i+1];
					else if(astrExp[i].equals("e")) sStartElec = astrExp[i+1];
				}
			}
			
			if(dEtime.getTime() < arySensonSts.get(nPoleIndex).m_dateReg.getTime()) dEtime = arySensonSts.get(nPoleIndex).m_dateReg;

			arySensonSts = daoS.selectAfterTimeSensorList(strSearchType,"10",dEtime,false);
			nPoleIndex = GetPoleExp(arySensonSts, false);
			
			//데이터 오류가 많아 하나 후 값을 가져온다
			if(nPoleIndex < arySensonSts.size()-1) nPoleIndex++;
			//없을덴 걍 끝 값으로 한다
			if(nPoleIndex < 0) nPoleIndex = arySensonSts.size()-1;

			sEndExp = arySensonSts.get(nPoleIndex).m_strExpansion;

			astrExp= EtcUtils.splitString(sEndExp,"=\\",true,false);
			for(int i=0; i<astrExp.length; i+=2 )
			{
				if(astrExp.length > i+1)
				{
					if(astrExp[i].equals("f")) sEndWater = astrExp[i+1];
					else if(astrExp[i].equals("e")) sEndElec = astrExp[i+1];
				}
			}
			
			float fStartWater = Float.parseFloat(sStartWater);
			float fEndWater = Float.parseFloat(sEndWater);
			float fStarElec = Float.parseFloat(sStartElec);
			float fEndElec = Float.parseFloat(sEndElec);
			
			strbLine.setLength(0);
			strbLine.append(EtcUtils.getStrDate(dStime,"yyyy-MM-dd HH:mm:ss") + "\t");
			strbLine.append(EtcUtils.getStrDate(dEtime,"yyyy-MM-dd HH:mm:ss") + "\t");		
			strbLine.append((fEndWater - fStartWater) + "\t");
			strbLine.append((fEndElec - fStarElec) + "\r\n");
			
			//out.write(strbLine.toString());
			strbList.append(strbLine.toString());
		}

		out.clear(); 
		EtcUtils.sendResponseData(response , strbList.toString().getBytes("euc-kr")); 
		out.flush();
	}
	finally
	{
		if(daoS.isConnected())
			daoS.disConnection();
		if(daoPS.isConnected())
			daoPS.disConnection();
		//bizUEC.disConnection();
	}
%>