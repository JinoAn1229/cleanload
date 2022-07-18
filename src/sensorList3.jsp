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
<%@ page import="wguard.dao.DaoUser"%>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord"%>
<%@ page import="wguard.dao.DaoGuestHistory"%>
<%@ page import="wguard.dao.DaoGuestHistory.DaoGuestHistoryRecord"%> 
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

DaoUser daoU = new DaoUser(); 
DaoUserRecord rUR = daoU.getUser(p_strUserID);	
DaoSite daoS = new DaoSite();
if(rUR != null)
{
	if(rUR.m_strAccount.equals("guest"))
	{ 
		ArrayList<DaoSiteRecord> aryGuestSite = daoS.selectGuestSite(p_strUserID);
		for(DaoSiteRecord rSR : aryGuestSite)
		if(rSR != null)
		{
			p_strSTID = rSR.m_strSTID;
		}
	}
	else if(rUR.m_strAccount.equals("user"))
	{ 
		DaoSiteRecord rSR = daoS.getUID(p_strUserID);
		if(rSR != null)
		{
			p_strSTID = rSR.m_strSTID;
		}
	}
}


/*
매립지 시범설치 지도와 엑스코 지도를 아이디에 따라서 구분한다.
*/
String p_strMap = "";
String p_strIP = "";
String p_strLogo = "";
String p_strLocation = "";

if(p_strUserID.equals("test@clean.com")) p_strMap = "MainBg.png";  
else if(p_strUserID.equals("daegu@clean.com")) p_strMap = "excoBg.png"; 
else  p_strMap = "excoBg.png"; if(p_strUserID.equals("test@clean.com")) 
{
	p_strMap = "MainBg.png";  
	p_strIP = "223.171.47.244";
	p_strLogo = "logo.png";
	p_strLocation = "Smart  IoT Clean Cooling System";
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

JSONObject joTable = null;
JSONArray p_jaTable = new JSONArray();

joTable = new JSONObject();
joTable.put("id", "id_sensor2_list");
joTable.put("x1", 1);
joTable.put("y1", 1);
joTable.put("x2", 3);
joTable.put("y2", 5);
p_jaTable.put(joTable);

joTable = new JSONObject();
joTable.put("id", "id_sensor3_list");
joTable.put("x1", 10);
joTable.put("y1", 10);
joTable.put("x2", 13);
joTable.put("y2", 15);
p_jaTable.put(joTable);

JSONObject joLine = null;
JSONArray p_jaLineX = new JSONArray();
JSONArray p_jaLineY = new JSONArray();

joLine = new JSONObject();
joLine.put("x1", 3);
joLine.put("y1", 5);
joLine.put("x2", 3);
joLine.put("y2", 8);
p_jaLineY.put(joLine);

joLine = new JSONObject();
joLine.put("x1", 1);
joLine.put("y1", 8);
joLine.put("x2", 3);
joLine.put("y2", 8);
p_jaLineX.put(joLine);



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
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
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
		var p_strPoleBg = "";
		var p_strCamIp = "";
		var p_strCamClassId = "";
		var p_strAgent = "";
		var j_jaTable = <%=p_jaTable.toString()%>;
		var j_jaLineX = <%=p_jaLineX.toString()%>;
		var j_jaLineY = <%=p_jaLineY.toString()%>;

		if("<%=p_strUserID%>" == "test@clean.com")  //시범설치 지역(인천매립지)
		{
			p_strPoleBg = "testPoleBg.png";
			p_strCamIp = "223.171.47.244";	  
			p_strCamClassId = "ED4850BF-32D8-4e73-A231-52560EE27A5E";			
		}
		else if("<%=p_strUserID%>" == "daegu@clean.com")//대구 전시회
		{
			p_strPoleBg = "excoPoleBg.png";
			p_strCamIp = "223.171.46.17"; 
			p_strCamClassId = "ED4850BF-32D8-4e73-A231-52560EE27A5E";
		}
		else
		{
			p_strPoleBg = "testPoleBg.png";
			p_strCamIp = "192.168.0.198";
			p_strCamClassId = "ED4850BF-32D8-4e73-A231-52560EE27A5E";
		}
      	$(function()
     	{	     		
			p_strAgent = getBrower();
			makeMainTable();
			resetListTable();
     	});

       	function resetListTable()
       	{   		
			var strQuery = "./query/query_cleanload_list.jsp?stid="+ "<%=p_strSTID%>";			
       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{        		 	
        			if(root.result =="OK")
        			{
						var aryRecord =  root.members;
						$('#id_total_count').text("" + root.tot_count);
						for(var i = 0; i < aryRecord.length; i ++)
						{
							objItem = aryRecord[i];
							addListTable(objItem);
						}

         			
        			}
       			}
       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
       	 }
		 
       	 function addListTable(jM)
       	 {  
			if(jM.action == "0")
			{
				if(jM.usegoal == 169)
				{	
					var tr_html ='<tr align ="center" style="border-bottom: 1px solid #dddddd; " height="30">'
						+ '<td bgcolor="#FF8000"colspan="2" style="width:30%; font-weight:bold;"><font color="white"><button type="button" onclick=\"location.href= \'poles.jsp?sid=' +  jM.sid + '\'\">' +  jM.name + '</button></font></td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
//						+ '<td  align ="center" style="width:95%; font-weight:bold;  padding:0px 0px 0px 0px;" bgcolor="#FFFFFF" ><a href="rtsp://admin:c@ot7np%@192.168.0.198:554/trackID=1"><img src="./images/excoPoleBg.png" width=350  height=200 style="padding:0px px 0px 0px;"></td>'
						+ '<td  align ="center" style="width:95%; font-weight:bold;  padding:0px 0px 0px 0px;" bgcolor="#FFFFFF" ><a onclick=OnCameraMove(); style="cursor: pointer">';

					if(p_strAgent == "msie")
					{	
						tr_html += '<OBJECT id="WatSearCtrl" codebase="http://bs2.blakstone.co.kr/CleanLoad/WatSearCtrl.cab#Version=2,8,3,26"'
							+ 'classid="clsid:' + p_strCamClassId  +'" standby="Downloading the ActiveX Control..."'
							+ 'width=352 height=240 align=center hspace=0 vspace=0><PARAM name="RBTN" value="false"></OBJECT>'
					}
					else
					{

						tr_html += '<img src="./images/' + p_strPoleBg +'" width=300  height=150 style="padding:0px px 0px 0px;">';
					}
				
					tr_html += '</td></tr>'
						+ '<tr align ="center" height="30">'
						+ '<td  bgcolor="#848484" colspan="2" style="width:50%; font-weight:bold;"><font color="white">'+ jM.date +'</font></td>'
						+ '</tr>';
					$('#id_sensor3_list').append(tr_html);
				}
				
				if(jM.usegoal == 168)	
				{
					var tr2_html = '<tr align ="center" style="border-bottom: 1px solid #dddddd;">'
						+ '<td bgcolor="#00c1ff"colspan="2" style="font-weight:bold;"><font color="white"><button type="button" onclick=\"location.href= \'enclosure.jsp?sid=' +  jM.sid + '\'\">' +  jM.name + '</button></font></td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
						+ '<td style="font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">온도</td>'
						+ '<td align ="center" style="font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.t + '°C</td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
						+ '<td style="font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">습도</td>'
						+ '<td align ="center" style="font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.h + '%</td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
						+ '<td style="font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">이산화탄소(CO<sub>2</sub>)</td>'
						+ '<td align ="center" style="font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.c + 'ppm</td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
						+ '<td style="font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">미세먼지(PM<sub>10</sub>)</td>'
						+ '<td align ="center" style="font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.p + '㎍/m³</td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
						+ '<td style="font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">초미세먼지(PM<sub>25</sub>)</td>'
						+ '<td align ="center" style="font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.u + '㎍/m³</td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
						+ '<td style="font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">이산화질소(NO<sub>2</sub>)</td>'
						+ '<td align ="center" style="font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.n + 'ppm</td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
						+ '<td style="font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">아황산가스(SO<sub>2</sub>)</td>'
						+ '<td align ="center" style="font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.s + 'ppm</td>'
						+ '</tr>'
						+ '<tr align ="center">'
						+ '<td bgcolor="#848484" colspan="2" style="font-weight:bold;"><font color="white">'+ jM.date +'</font></td>'
						+ '</tr>';
   				  
					$('#id_sensor2_list').append(tr2_html);
				}
			}	
			
			if(jM.action == "1")
			{
				if(jM.usegoal == 169)
				{	
					var tr_html ='<tr align ="center" style="border-bottom: 1px solid #dddddd; " height="30">'
						+ '<td bgcolor="#FF8000"colspan="2" style="width:30%; font-weight:bold;"><font color="white"><button type="button" onclick=\"location.href= \'poles.jsp?sid=' +  jM.sid + '\'\">' +  jM.name + '</button></font></td>'
						+ '</tr>'
						+ '<tr style="border-bottom: 2px solid #dddddd;">'
//						+ '<td  align ="center" style="width:95%; font-weight:bold;  padding:0px 0px 0px 0px;" bgcolor="#FFFFFF" ><a href="rtsp://admin:c@ot7np%@192.168.0.198:554/trackID=1"><img src="./images/excoPoleBg.png" width=350  height=200 style="padding:0px px 0px 0px;"></td>'
						+ '<td  align ="center" style="width:95%; font-weight:bold;  padding:0px 0px 0px 0px;" bgcolor="#FFFFFF" ><a onclick=OnCameraMove(); style="cursor: pointer">';

					
				
						tr_html += '</td></tr>'
							+ '<tr align ="center" height="30">'
							+ '<td  bgcolor="#848484" colspan="2" style="width:50%; font-weight:bold;"><font color="white">'+ jM.date +'</font></td>'
							+ '</tr>';
						$('#id_sensor3_list').append(tr_html);
				}
				
				
			}
			
       	 }

       	 function makeMainTable()
		 {
			 var strTableHtml = "";
			 var strTemp = "";
			 var strStyle = "";
			 for(var i=0 ; i < 20 ; i++)
			 {
				strTableHtml += "<tr height='5%'>";
	 			 for(var j=0 ; j < 20 ; j++)
				 {
					strTemp = "";
					strStyle = "";
					var nIndex = 0;
					for(nIndex = 0; nIndex < j_jaTable.length ; nIndex++)
					{
						if(j_jaTable[nIndex].x1 == j && j_jaTable[nIndex].y1 == i)
						{
							strTemp = "<td width='5%' colspan='"+(j_jaTable[nIndex].x2 - j_jaTable[nIndex].x1 + 1)+"' rowspan='"+(j_jaTable[nIndex].y2 - j_jaTable[nIndex].y1 + 1)+"'>";
							strTemp += "<table id='" +j_jaTable[nIndex].id+ "' border='1' width='100%' height='100%' ></table>";
							strTemp += "</td>";
						}
						else if(j_jaTable[nIndex].x1 <= j && j_jaTable[nIndex].y1 <= i && j_jaTable[nIndex].x2 >= j && j_jaTable[nIndex].y2 >= i)
						{
							strTemp = "none";
						}
					}
					
					for(nIndex = 0; nIndex < j_jaLineX.length ; nIndex++)
					{
						if(j_jaLineX[nIndex].x1 <= j && j_jaLineX[nIndex].y1 <= i && j_jaLineX[nIndex].x2 >= j && j_jaLineX[nIndex].y2 >= i)
						{
							strStyle += " border-bottom: 3px solid red;";
						}
					}

					for(nIndex = 0; nIndex < j_jaLineY.length ; nIndex++)
					{
						if(j_jaLineY[nIndex].x1 <= j && j_jaLineY[nIndex].y1 <= i && j_jaLineY[nIndex].x2 >= j && j_jaLineY[nIndex].y2 >= i)
						{
							strStyle += " border-right: 3px solid red;";
						}
					}

					if(strTemp == "")
					{
						if(strStyle == "") strTableHtml += "<td width='5%'>&nbsp;</td>";
						else strTableHtml += "<td style='"+strStyle+"' width='5%'>&nbsp;</td>";
					}
					else if(strTemp == "none") strTableHtml += "";
					else strTableHtml += strTemp;
				 }
				strTableHtml += "</tr>";
			 }
			 $('#id_main_table').append(strTableHtml);
		 }

		 function  OnCameraMove()
		 {
			 //일단은 아이디에 카메라가 한개밖에 없기 떄문에 이렇게 임시코딩			
			 location.href="camera.jsp";
			 //location.href="rtsp://admin:c@ot7np%@192.168.0.198:554/trackID=1";
			 //location.href="IE.HTTP:// bs2.blakstone.co.kr/CleanLoad/camera.jsp";
		 }

		function LoadDefault()
		{
			if(p_strAgent == "msie")
			{
				WatSearCtrl.setLayout(0);
				WatSearCtrl.setCameraMap(0, 0, 'Web Watch', p_strCamIp, 0,'anonymous', '', 8016, false, false, false, '', 0, 0);
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
					<img  src='./images/<%=p_strLogo%>'    style='float:left;'>
                <div  style="float:left;  width:80%;  font-size:230%; margin:25px 0px 0px 50px;"><%=p_strLocation%></div>
					<!--<div><button  style="float:left;  width:5%; margin:40px 0px 0px 0px; white: gold; background:gray; font-size:1em;"onClick="window.open('sensorCheck.jsp', '_blank', 'width=550 height=500')">Cheak</button></div> --> <!-- onClick안에는 임시코드 -->
            </header>  	
			<div class="content-wrap" >
				<jsp:include page="./left_menu.jsp"></jsp:include>
						

				<div id="contents">
				<table id='id_main_table' border="0" width="1600" height="750" style="background: url('./images/<%=p_strMap%>') center 0 no-repeat;"></table>
				</div>
            
            <!-- //content-wrap -->
				
			</div>
            <!-- //wrapper -->
		</div>
	</body>
</html>
