<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="wguard.dao.DaoUser" %>   
<%@ page import="wguard.dao.DaoUser.DaoUserRecord"%>
<%@ page import="wguard.dao.DaoGuestHistory"%>
<%@ page import="wguard.dao.DaoGuestHistory.DaoGuestHistoryRecord"%> 
<%@ page import="common.util.EtcUtils" %>      
<%!
public DaoUser.DaoUserRecord checkLogin(String id, String pw) 
{
	DaoUser daoUser = new DaoUser();
	return daoUser.checkLogin(id,pw);
 }
%>
<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
	String sAccount = "";
	String strID = EtcUtils.NullS(request.getParameter("id"));
	String strPW = EtcUtils.NullS(request.getParameter("pw"));
	DaoUser.DaoUserRecord rUser = null;
	boolean bLogin = false;
	try
	{
		rUser = checkLogin(strID,strPW);
		if (rUser != null )
		{
			HttpSession loginsession = request.getSession(true); // true : 없으면 세션 새로 만듦
			loginsession.setAttribute("ID", strID);
			loginsession.setAttribute("NAME",rUser.m_strName);
			bLogin = true;
			//게스트 권한을 가진 유저가 로그인 시 로그인 기록을 남긴다.
			if(rUser.m_strAccount.equals("guest"))
			{
				DaoGuestHistory daoGH = new DaoGuestHistory();
				DaoGuestHistory.DaoGuestHistoryRecord rGH = daoGH.new DaoGuestHistoryRecord();
				rGH.m_strGID = strID;
				daoGH.insertGuestHistory(rGH);
			}
		}
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	if(bLogin)
		out.println("OK");
	else
		out.println("FAIL");
%>