<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoSite"%>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord"%>
<%@ page import="wguard.dao.DaoSensor"%>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord"%>
<%@ page import="wguard.dao.DaoSensorSt"%>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>

<%
HttpSession p_Session = request.getSession(false);
if(p_Session == null)
{
	response.sendRedirect("login.jsp");
	return;
}
String p_strUserID = (String)p_Session.getAttribute("ID");
if(p_strUserID == null)
{
	response.sendRedirect("login.jsp");
	return;
}
/*
일단 아이디에 있는 사이트가 하나일 경우 이렇게 처리
아이디에 사이트를 여러개 쓰게 되면 리스트로 사이트 선택할 수 있게 만들기
*참고 - SensorStRecord소스
*/
String p_strSTID = ""; 

DaoSite daoS = new DaoSite(); 
DaoSiteRecord rSR = daoS.getUID(p_strUserID);
if(rSR != null)
{
	p_strSTID = rSR.m_strSTID;
}
long p_lTime = new java.util.Date().getTime();

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if lt IE 10]>     <html class="no-js lt-ie10"> <![endif]-->
<!--[if gt IE 10]><!-->
<html class="no-js">
<!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>리스트</title>

        <link rel="stylesheet" href="css/normalize_custom.css">
        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <link rel="stylesheet" href="css/jquery.mCustomScrollbar.min.css">
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/index.css">
        <script src="js/jquery-1.12.1.min.js"></script>
        <script src="js/jquery-ui.min.js"></script>
        <script src="js/jquery.mCustomScrollbar.concat.min.js"></script>
        <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
		 <script type="text/javascript">
		
		

      	$(function()
     	{	     		
			
     	});
       	
		function FnChangePW()
		{
			var sID = "<%=p_strUserID%>"
			var sPW = document.getElementById('id_pw').value;
			var sPW2 = document.getElementById('id_pw2').value;
	

			if(!checkValue(sPW) || !checkValue(sPW2))
			{
				alert('값을 입력해주세요.');
				return ;
			}

			if(sPW != sPW2)
			{
				alert('확인 비밀번호가 일치하지 않습니다.');
				return ;	
			}	

			var sData = "id=" + sID +"&pw=" + sPW;

			$.post("./query/query_change_pw.jsp",sData, function(data, status)
			{
				if(status=="success")
				{
					var joReturn = JSON.parse(data)
					var sResult = joReturn.result;
					if(sResult == "OK")
					{
						alert("변경되었습니다.");
						//location.href="home.jsp";
					}					
				}
				else if(status=="error" ||  status=="timeout") // notmodified, parsererror 
				{
					alert('변경 실패'); 
				} 
			});
		}

		function clearText(y)
		{ 	
			if (y.defaultValue==y.value) 
				y.value = "";
		} 

		function checkValue(str)
		{ 
			if(str == null)
				return false;
			var v = str.trim();
				if (v == "")
				return false;
			return true;
		}

       	
      

		

       	</script>         
    </head>

    <body>
			<h3 class="tit-list">비밀번호 변경</h3>
			<div class="search-wrap" >
				<div class="list-wrap">
					<div class="list-def">
							
			<div style="background-color: #6c6c6c; height: 50px; width: 100%; vertical-align:middle;  float:left; margin-top:20px"> 
				<div style="margin:10px 20px 0px 20px; float:left; font-weight: bold ; font-size:180%; color: #FFFFFF;">
					ID :
				</div>
				<div style="margin:13px 20px 0px 20px; float:left; font-weight: bold ; font-size:130%; color: #FFFFFF;">
					<%=p_strUserID%>
				</div>
			</div>		
			
			<div style="background-color: #6c6c6c; height: 50px; width: 100%; vertical-align:middle;  float:left;  margin-top:20px"> 
				<div style="margin:15px 20px 0px 20px; float:left; font-weight: bold ; font-size:100%; color: #FFFFFF;">
					비밀번호 입력 :
				</div>
				<div style="margin:10px 20px 0px 25px; float:left;">
					<div class="loginInput" ><input id="id_pw" name="pw"  type="text" style="font-size:100%; color:#FFFFFF ; background: url(./images/login/historyBg.png) left center no-repeat; margin:0px 0px 0px 0px;" value="Password" onFocus="clearText(this)"  class="loginInput"> </div>
				</div>
			</div>
				
			<div style="background-color: #6c6c6c; height: 50px; width: 100%; vertical-align:middle;  float:left;  margin-top:20px"> 
				<div style="margin:15px 20px 0px 20px; float:left; font-weight: bold ; font-size:100%; color: #FFFFFF;">
					비밀번호 확인 입력 :
				</div>
				<div style="margin:10px 20px 0px 25px; float:left;">
					<div class="loginInput" ><input id="id_pw2"   type="text" style="font-size:100%; color:#FFFFFF ; background: url(./images/login/historyBg.png) left center no-repeat; margin:0px 0px 0px 0px;" value="Re-enter password" onFocus="clearText(this)"  class="loginInput"> </div>
				</div>
			</div>
			
			<div style="width:100%; " class="hCenter">
					<div><button  style="  width:20%; margin:30px 0px 0px 200px; white: gold; background:#00c1ff; font-size:2em; color: #FFFFFF;border-radius:0.5em"onClick="javascript:FnChangePW();">변경</div>
			</div>
					</div>
				</div>
			</div>
	</body>
</html>
