<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%
boolean bSessionOK = true;

HttpSession p_Session = request.getSession(false);
String p_strSessionID = "";
/*
if(p_Session == null)
{
	bSessionOK = false;
}
p_strSessionID = (String)p_Session.getAttribute("ID");
if(p_strSessionID == null)
{
	bSessionOK = false;
	p_strSessionID = "";
}
*/
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>