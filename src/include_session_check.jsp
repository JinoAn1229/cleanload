<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%


String p_strSessionID = "";
HttpSession p_Session = request.getSession(false);

if(p_Session == null)
{
	response.sendRedirect("/SensorManager/login.jsp");
	return;
}
p_strSessionID = (String)p_Session.getAttribute("ID");
if(p_strSessionID == null)
{
	response.sendRedirect("/SensorManager/login.jsp");
	return;
}

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>