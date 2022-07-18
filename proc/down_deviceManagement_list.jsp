<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils" %>
<%@ page import="bsmanager.biz.BizDevice" %>
<%@ page import="bsmanager.biz.BizDevice.BizDeviceRecord" %>

<%@ include file="./include_session_proc.jsp" %> 

<%

//-----------------------------	
// 회원 리스트와 회위의 소유 장치를 검색하는  쿼리호출이다.
// stype : 검색조건 형식, 
//     name  :   sval 파라메터로 회원 이름 이 전달된다.
//     id       :   sval 파라메터로 회원 ID가 전달된다.
//     addr   :   sval 파라메터로 주소가 전달된다.
// dtend : true 경우 
//             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
//             dates >=  회원등록일  <= datee 조건으로 이용됨

    response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition","attachment;filename=deviceManagement.txt");
    
	if(!bSessionOK)
	{
		out.println("FAIL\tsession not found");
		return ;
	}
	
	int i;
	
	String strSearchValue = "";
	String strSearchType = EtcUtils.NullS(request.getParameter("stype"));
	if(strSearchType.isEmpty())
	{
		out.println("FAIL\tparameter mismatch (stype)");
		return ;
	}
	
	strSearchValue = EtcUtils.NullS(request.getParameter("sval"));
	if(strSearchValue.isEmpty())
	{
		out.println("FAIL\tparameter mismatch (sval)");
		return ;	
	}
	
	BizDevice bizD = new BizDevice();
	String strDateAnd = EtcUtils.NullS(request.getParameter("dtand"));

	String strQuery = "";
	Date dateST = null;
	Date dateEnd = null;
	String strWhereDate = "";
	String strWhereVal = "";
	
	String strWhere = "";		
	
	if(strDateAnd.equals("true"))
	{  // 기간  and 조건 추가
		String strDateS = EtcUtils.NullS(request.getParameter("dates"));
		String strDateE = EtcUtils.NullS(request.getParameter("datee"));
		if(strDateS.isEmpty() || strDateE.isEmpty())
		{
			out.println("FAIL\tparameter mismatch (date)");
			return ;
		}
		dateST = EtcUtils.getJavaDate(strDateS);
		dateEnd = EtcUtils.getJavaDate(strDateE);
		dateEnd = EtcUtils.addDateDay(dateEnd,1,true);
	}


	int nQueryType = 0;
	if(strSearchType.equals("id"))
	{
		strWhereVal = "USER_ID like  '%" + strSearchValue + "%'";
		nQueryType = 0;
	}
	else if(strSearchType.equals("name"))
	{
		strWhereVal = "USER_NAME like '%" + strSearchValue + "%'";
		nQueryType = 0;
	}
	else if(strSearchType.equals("sid"))
	{
		strWhereVal = "SENSOR_ID like '%" + strSearchValue + "%'";
		nQueryType = 1;
	}
	else if(strSearchType.equals("gid"))
	{
		strWhereVal = "GATE_ID like '%" + strSearchValue + "%'";
		nQueryType = 1;
	}
	else if(strSearchType.equals("cmid"))
	{
		strWhereVal = "CAMERA_MID like '%" + strSearchValue + "%'";
		nQueryType = 2;
	}
	else if(strSearchType.equals("cuid"))
	{
		strWhereVal = "CAMERA_UID like '%" + strSearchValue + "%'";
		nQueryType = 2;
	}
	else
	{
		out.println("FAIL\tparameter mismatch (stype)");
		return ;	
	}

	String strBaseQuery = "";
	switch(nQueryType)
	{
		case 0:
		{
			if(strDateAnd.equals("true"))
				strWhereDate = " and ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,bizD.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,bizD.m_strDBType) + ")";
			else
				strWhereDate = "";
			
			strBaseQuery = "(select USER_ID,USER_NAME,REG_DATE from DM_USER where " + strWhereVal + strWhereDate + ")";
		
			strQuery = "select a.USER_ID as ID, a.USER_NAME as NAME," 
				+ "b.SENSOR_ID as SID , b.SENSOR_NAME as SNAME, b.GATE_ID as GID , b.REG_DATE as SDATE," 
				+ "null as CUID, null as CMID , null as CNAME , null as CDATE,"
				+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
				+ " from " + strBaseQuery + " a , DM_SENSOR b , DM_SITE d where a.USER_ID = b.USER_ID and b.SITE_ID = d.SITE_ID" 
				+ " union "
				+ "select a.USER_ID as ID, a.USER_NAME as NAME," 
				+ "null as SID , null as SNAME,null as GID , null as SDATE," 
				+ "c.CAMERA_UID as CUID, c.CAMERA_MID as CMID , c.CAMERA_NAME as CNAME , c.CODE_DATE as CDATE,"
				+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
				+ " from " + strBaseQuery + " a , DM_CAMERA c , DM_SITE d where a.USER_ID = c.USER_ID and c.SITE_ID = d.SITE_ID" 
				+ " order by ID";
			


			break;
		}
		case 1:
		{
			if(strDateAnd.equals("true"))
				strWhereDate = " and ( REG_DATE >= " + EtcUtils.getSqlDate(dateST,bizD.m_strDBType) + " and REG_DATE < " + EtcUtils.getSqlDate(dateEnd,bizD.m_strDBType) + ")";
			else
				strWhereDate = "";
			
			strBaseQuery = "(select USER_ID,SENSOR_ID,GATE_ID,REG_DATE from DM_SENSOR where " + strWhereVal + strWhereDate + ")";
		
			strQuery = "select a.USER_ID as ID, a.USER_NAME as NAME," 
					+ "b.SENSOR_ID as SID ,b.SENSOR_NAME as SNAME, b.GATE_ID as GID , b.REG_DATE as SDATE," 
					+ "null as CUID, null as CMID , null as CNAME , null as CDATE,"
					+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
					+ " from " + strBaseQuery + " a , DM_SENSOR b , DM_SITE d where a.USER_ID = b.USER_ID and b.SITE_ID = d.SITE_ID"; 

			break;
		}
		case 2:
		{
			if(strDateAnd.equals("true"))
				strWhereDate = " and ( CODE_DATE >= " + EtcUtils.getSqlDate(dateST,bizD.m_strDBType) + " and CODE_DATE < " + EtcUtils.getSqlDate(dateEnd,bizD.m_strDBType) + ")";
			else
				strWhereDate = "";
			
			strBaseQuery = "(select USER_ID,CAMERA_UID,CAMERA_MID,CODE_DATE from DM_CAMERA where " + strWhereVal + strWhereDate + ")";
		
			strQuery = "select a.USER_ID as ID, a.USER_NAME as NAME," 
					+ "null as SID , null as SNAME, null as GID , null as SDATE ," 
					+ "c.CAMERA_UID as CUID, c.CAMERA_MID as CMID , c.CAMERA_NAME as CNAME , c.CODE_DATE as CDATE,"
					+ "d.SITE_ID as STID , d.SITE_NAME as STNAME"
					+ " from " + strBaseQuery + " a , DM_CAMERA c , DM_SITE d where a.USER_ID = c.USER_ID and c.SITE_ID = d.SITE_ID"; 


			break;
		}
	}

	try
	{
		if(!bizD.connection())
		{
			out.println("FAIL\tdatabase connection fail");
			return ;	
		}

		int nRecordCnt = 1;
		ArrayList<BizDeviceRecord> aryBD = bizD.selectDevice(strQuery, false);
		

		StringBuffer strbList = new StringBuffer();
		StringBuffer strbLine = new StringBuffer();
		strbLine.append("no\t");
		strbLine.append("사용자\t");
		strbLine.append("사용자ID\t");
		strbLine.append("설치일\t");
		strbLine.append("센서ID\t");
		strbLine.append("GWID\t");
		strbLine.append("장소ID\t");
		strbLine.append("카메라\t");
		strbLine.append("센서\t");
		strbLine.append("설치장소\t");
		strbLine.append("C코드부여일\t");
		strbLine.append("C판매ID\t");
		strbLine.append("C제조ID\t");
		
		//out.write(strbLine.toString());
		strbList.append(strbLine.toString());

		for(BizDeviceRecord rD : aryBD)
		{
			strbLine.setLength(0);
			strbLine.append("" + nRecordCnt++ + "\t");
			strbLine.append(rD.m_strName);
			strbLine.append(rD.m_strID);
			strbLine.append(EtcUtils.getStrDate(rD.m_dateSensor,"yyyy-MM-dd",""));
			strbLine.append(rD.m_strSensorID);
			strbLine.append(rD.m_strGateID);
			strbLine.append(rD.m_strSiteID);
			strbLine.append(rD.m_strCameraName);
			strbLine.append(rD.m_strSensorName);
			strbLine.append(rD.m_strSiteName);
			strbLine.append(EtcUtils.getStrDate(rD.m_dateCode,"yyyy-MM-dd",""));
			strbLine.append(rD.m_strCameraMID);
			strbLine.append(rD.m_strCameraUID);
			
			//out.write(strbLine.toString());
			strbList.append(strbLine.toString());
		}
		
		out.clear(); 
		EtcUtils.sendResponseData(response , strbList.toString().getBytes("euc-kr")); 
		out.flush();
	}
	finally
	{
		if(bizD.isConnected())
			bizD.disConnection();
	}
%>