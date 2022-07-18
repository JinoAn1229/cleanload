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

/*
매립지 시범설치 지도와 엑스코 지도를 아이디에 따라서 구분한다.
*/
String p_strMap = "";
String p_strIP = "";
String p_strLogo = "";
String p_strLocation = "";

if(p_strUserID.equals("test@clean.com")) 
{
	p_strMap = "MainBg.png";  
	p_strIP = "223.171.47.244";
	p_strLogo = "logo.png";
	p_strLocation = "서구청 Smart  IoT Clean Cooling System";
}
else if(p_strUserID.equals("daegu@clean.com"))  
{
	p_strMap = "excoBg.png";
	p_strIP = "223.171.46.17";
	p_strLogo = "logoExco.png";
	p_strLocation = "쿨산업전 Smart  IoT Clean Cooling System";
}
else   
{
	p_strMap = "excoBg.png"; 
	p_strIP = "192.168.0.198";
	p_strLogo = "logo.png";
	p_strLocation = "Smart  IoT Clean Cooling System";
} 
	
	
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

		var p_strAgent = "";
		
		$(function()
     	{	   
//			var agent = navigator.userAgent.toLowerCase();
//			if ( (navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1) ) 	  
//			{		
//				//alert('크롬에서는 영상이 재생 되지않습니다.');
//			}	
//			else
			p_strAgent = getBrower();
			if(p_strAgent != "msie")
			{
				//alert('크롬에서는 영상이 재생 되지않습니다.'); 
				var sLine = "";
				var oHist = $('#id_none');	
				oHist.html(""); 	
				sLine = "<img  src='./images/notCamera.png'  height='500px'  style='width:750px;  margin:100px 0px 0px 350px;' > ";
				//sLine += "</div>"
				oHist.append(sLine);
			}				
     	});
		
		function LoadDefault()
		{
			if(p_strAgent == "msie")
			{
				WatSearCtrl.setLayout(0);
				WatSearCtrl.setCameraMap(0, 0, 'Web Watch', '<%=p_strIP%>', 0,'anonymous', '', 8016, false, false, false, '', 0, 0);
				WatSearCtrl.connect();
			}
		}

	</script>         

	<script language='VBScript'>
		Sub WatSearCtrl_CameraStream
		WatSearCtrl.setCameraStream 0, 2
		End Sub
		Sub WatSearCtrl_ConnectedWatch(hostId)
		window.setTimeout "WatSearCtrl_CameraStream", 500, "VBScript"
		End Sub
	</script>

    </head>

    <body onLoad='window.setTimeout("LoadDefault()",  500)' onUnload='WatSearCtrl.finalize()'>
	 
       <div  style="min-width: 400px" >
            <!-- //  header -->
			  <header style="background: url('./images/header.png') center 0 no-repeat; background-size:100%; background-color: #00c1ff;">
					<img  src='./images/<%=p_strLogo%>'  height='100px'  style='width:220px;  float:left;'>
                <div  style="float:left;  width:80%;  font-size:230%; margin:25px 0px 0px 50px;"><%=p_strLocation%></div>
					<!--<div><button  style="float:left;  width:5%; margin:40px 0px 0px 0px; white: gold; background:gray; font-size:1em;"onClick="window.open('sensorCheck.jsp', '_blank', 'width=550 height=500')">Cheak</button></div> --> <!-- onClick안에는 임시코드 -->
            </header>  	
          <div class="content-wrap" >
           	<jsp:include page="./left_menu.jsp"></jsp:include>
                

			<div id="contents">
				<div id='id_none'>
				</div>
            <!-- // contents -->
 <OBJECT id='WatSearCtrl' codebase='http://bs2.blakstone.co.kr/CleanLoad/WatSearCtrl.cab#Version=2,8,3,26' 
    classid='clsid:ED4850BF-32D8-4e73-A231-52560EE27A5E' standby='Downloading the ActiveX Control...' 
    width=1600 height=830 align=center hspace=30 vspace=0>
    <PARAM name='RBTN' value='false'>
  </OBJECT>
            
            <!-- //content-wrap -->
		</div>		
		</div>
            <!-- //wrapper -->
		
	</body>
</html>
