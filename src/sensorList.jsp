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

// 사용자가 관리하는 SITE별 센서 목록을 보여준다.
DaoSite daoSite = new DaoSite();
ArrayList<DaoSiteRecord> p_arySite = daoSite.selectOwnerSite(p_strUserID);
JSONObject joSite = null;
JSONObject joSitePool = new JSONObject();
	
for(DaoSiteRecord rSTR : p_arySite)
{
	joSite = new JSONObject();
	joSite.put("stid",rSTR.m_strSTID);
	joSite.put("name",rSTR.m_strSTName);
	joSite.put("bgroot",rSTR.m_strRoot);
	joSite.put("auto",rSTR.m_strAuto);
	joSite.put("schedule",rSTR.m_strScheduleMode);
	joSite.put("account","1"); // 이사이트는 소유권이 있음 	
	joSitePool.put(rSTR.m_strSTID,joSite);
}
    
// 사용자가 Family로 등록된 SITE를 구한다
String strSTName = "";
ArrayList<DaoSiteRecord> aryFamilySite = daoSite.selectFailySite(p_strUserID);
for(DaoSiteRecord rSTR : aryFamilySite)
{
	joSite = new JSONObject();
	joSite.put("stid",rSTR.m_strSTID);
	joSite.put("name","GUEST_" + rSTR.m_strSTName);
	joSite.put("bgroot",rSTR.m_strRoot);
	joSite.put("auto",rSTR.m_strAuto);
	joSite.put("schedule",rSTR.m_strScheduleMode);
	joSite.put("account","0"); // 이사이트는 소유권이 없음 	
	joSitePool.put(rSTR.m_strSTID,joSite);
	
	p_arySite.add(rSTR);
}

String p_strSTID = EtcUtils.NullS(request.getParameter("stid"));

if(!p_strSTID.isEmpty())
{
	int nCheck = 0;
	for(int nIndex = 0 ; nIndex < p_arySite.size() ; nIndex++)
	{
		if(p_arySite.get(nIndex).m_strSTID.equals(p_strSTID))
		{
			nCheck = 1;
			break;
		}
	}
	if(nCheck == 0) p_strSTID = "";
}

if(p_strSTID.isEmpty())
{
	if(p_arySite.size() > 0) p_strSTID = p_arySite.get(0).m_strSTID;
}


String p_strLogo = "";
String p_strLocation = "";

p_strLogo = "logo.png";
p_strLocation = "Smart  IoT Clean Cooling System";
	
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

        <title>클린로드</title>

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
		var p_joSitePool = <%=joSitePool.toString()%>;
		var p_strSiteID = "<%=p_strSTID%>";
		
      	$(function()
     	{	     
			CheckWaterState();		
			p_strAgent = getBrower();
			addAutoState();
			resetContents();
     	});

		function addAutoState()
		{
			var strHrml = "";
			strHrml = "<tr align ='left'>";
			strHrml += "<td colspan='3'>";
			strHrml += "<button  style='border:0' onClick=\"window.open('editPW.jsp', '_blank', 'width=550 height=500')\">";
			strHrml += "<img src='./images/editPW.png' height='30px'></button></td>";
			strHrml += "</tr>";
			
			strHrml += "<tr align ='left' style='border-bottom: 1px solid #dddddd; height:25px'>"
			strHrml += "<td style=\"background: url('./images/autoWater.png') left 0 no-repeat; background-size:contain; width:25px;\"></td>";
			strHrml += "<td style='width:60%; font-weight:bold; background-color:white; padding-left:10px'><font color='black'>자동 물 분사 설정</font></td>";
			strHrml += "<td align ='center' style='width:30%; font-weight:bold; background-color:white;'>";

			if(p_joSitePool[p_strSiteID].auto == "on")
				strHrml += "<img src='./images/waterON.png' height='20px' style='display: block;' />";
			else
				strHrml += "<img src='./images/waterOFF.png' height='20px' style='display: block;' />";

			strHrml += "</td></tr>";
			strHrml += "<tr align ='left' style='border-bottom: 1px solid #dddddd; height:25px'>"
			strHrml += "<td style=\"background: url('./images/timeWater.png') left 0 no-repeat; background-size:contain; width:25px;\"></td>";
			strHrml += "<td style='width:60%; font-weight:bold; background-color:white; padding-left:10px'><font color='black'>시간별 물 분사 설정</font></td>";
			strHrml += "<td align ='center' style='width:30%; font-weight:bold; background-color:white;'>";

			if(p_joSitePool[p_strSiteID].schedule == "on")
				strHrml += "<img src='./images/waterON.png' height='20px' style='display: block;' />";
			else
				strHrml += "<img src='./images/waterOFF.png' height='20px' style='display: block;' />";

			strHrml += "</td></tr>";	
			$('#id_autostate_list').append(strHrml);			
		}
		
       	function resetContents()
       	{ 
			var i = 0;  		
			var strQuery = "./query/query_cleanload_list.jsp?stid="+ p_strSiteID;			
       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{        		 	
        			if(root.result =="OK")
        			{
						var aryRecord =  root.members;
						
						$('#id_svg_img').empty();
						
						var strBGImg = p_joSitePool[p_strSiteID].bgroot + ".png";
						
						for(i = 0; i < aryRecord.length; i ++)
						{
							if(aryRecord[i].usegoal == 169)
							{
								if(aryRecord[i].exp.w == 1)
								{
									strBGImg = p_joSitePool[p_strSiteID].bgroot + "_On.png";
									break;
								}
							}
						}
						
						var strSvgHtml = "<svg width='1680' height='860' style='background: url(\"./images/" + strBGImg + "\") center 0 no-repeat; background-size:contain;'>";

						for(i = 0; i < aryRecord.length; i ++)
						{
							strSvgHtml += "<line x1='" + aryRecord[i].svg.l1x1 + "' y1='" + aryRecord[i].svg.l1y1 + "' x2='" + aryRecord[i].svg.l1x2 + "' y2='" + aryRecord[i].svg.l1y2 + "' stroke = '#00aeea' stroke-width='5'> </line>";
							strSvgHtml += "<line x1='" + aryRecord[i].svg.l2x1 + "' y1='" + aryRecord[i].svg.l2y1 + "' x2='" + aryRecord[i].svg.l2x2 + "' y2='" + aryRecord[i].svg.l2y2 + "' stroke = '#00aeea' stroke-width='5'> </line>";
							strSvgHtml += "<circle cx='" + aryRecord[i].svg.l2x2 + "' cy='" + aryRecord[i].svg.l2y2 + "' r='10' fill='#00aeea' />";
							if(aryRecord[i].usegoal == 168)
								strSvgHtml += "<image xlink:href='./images/enclosureImg.png' x='" + (aryRecord[i].svg.l2x2-10) + "' y='" + (aryRecord[i].svg.l2y2 - 70) +"' width='50' height='70' />";
							
						}
						
						strSvgHtml += "<foreignObject x='0' y='0' width='1600' height='800'>";
						strSvgHtml += "<body xmlns='http://www.w3.org/1999/xhtml'>";

						for(i = 0; i < aryRecord.length; i ++)
						{
							strSvgHtml += "<div style='position:absolute; top:" + aryRecord[i].svg.ttop + "px;left:" + aryRecord[i].svg.tleft + "px;'>";
							if(aryRecord[i].usegoal == 168)	
								strSvgHtml += "<table id='id_sensor" + i + "_list' style='width:250px; height:300px; border:3px solid #008BC4;'>";
							else 
								strSvgHtml += "<table id='id_sensor" + i + "_list' style='width:250px; height:160px; border:3px solid #008BC4;'>";	
							strSvgHtml += makeListTable(aryRecord[i]);
							strSvgHtml += "</table></div>";
						}
						
						strSvgHtml += "</body></foreignObject></svg>";
						$('#id_svg_img').append(strSvgHtml);
        			}
       			}
       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
       	}
		
		function CheckWaterState()
       	{
			//30초마다 확인 쿼리 실행
			CheckQuery = setInterval(function() { resetContents(); }, 30000);			
		}
	
		 
       	function makeListTable(jM)
       	{  
			var sTHtml = "";
			var strTemp = "";
			
			if(jM.usegoal == 168)	
			{
				sTHtml = '<tr align ="center" style="border-bottom: 1px solid #dddddd; width:5%; border-radius:20px;">';
				sTHtml += '<td bgcolor="#00aeea" colspan="2" style="background:linear-gradient(to bottom,#00BBF2,#0095DA); width:85%; font-weight:bold;"><font color="white"><button type="button" onclick=\"location.href= \'enclosure.jsp?sid=' +  jM.sid + '\'\">' +  jM.name + '</button></font></td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:5%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">온도</td>';
				sTHtml += '<td align ="center" style="width:15%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.d + '°C</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:25%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">습도</td>';
				sTHtml += '<td align ="center" style="width:15%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.h + '%</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:25%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">이산화탄소(CO<sub>2</sub>)</td>';
				sTHtml += '<td align ="center" style="width:15%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.c + 'ppm</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:25%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">미세먼지(PM<sub>10</sub>)</td>';
				sTHtml += '<td align ="center" style="width:15%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.p + '㎍/m³</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:25%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">초미세먼지(PM<sub>25</sub>)</td>';
				sTHtml += '<td align ="center" style="width:15%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.u + '㎍/m³</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:25%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">이산화질소(NO<sub>2</sub>)</td>';
				sTHtml += '<td align ="center" style="width:15%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.n + 'ppm</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:25%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">아황산가스(SO<sub>2</sub>)</td>';
				sTHtml += '<td align ="center" style="width:15%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.s + 'ppm</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr align ="center">';
				sTHtml += '<td bgcolor="#00aeea" colspan="2" style="background:linear-gradient(to top,#00BBF2,#0095DA); width:50%; font-weight:bold;"><font color="white">'+ jM.date +'</font></td>';
				sTHtml += '</tr>';
			}
			else if(jM.usegoal == 169)
			{
				sTHtml = '<tr align ="center" style="border-bottom: 1px solid #dddddd; width:5%; ">'
				sTHtml += '<td bgcolor="#00aeea"colspan="2" style="background:linear-gradient(to bottom,#00BBF2,#0095DA); width:85%; font-weight:bold;"><font color="white"><button type="button" onclick=\"location.href= \'poles.jsp?sid=' +  jM.sid + '\'\">' +  jM.name + '</button></font></td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:5%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">살수 상태</td>';
				strTemp = "살수안함";
				if(jM.exp.w == 1) strTemp = "살수중";
				sTHtml += '<td align ="center" style="width:25%; font-weight:bold;" bgcolor="#E6E6E6">' + strTemp + '</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:5%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">물사용량</td>';
				sTHtml += '<td align ="center" style="width:25%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.f + 'm³</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr style="border-bottom: 2px solid #dddddd;">';
				sTHtml += '<td style="width:25%; font-weight:bold; padding:0px 0px 0px 10px;" bgcolor="#FFFFFF" ><img src="./images/bull_title.png" width=10  height=10 style="padding:0px 5px 0px 0px;">전력</td>';
				sTHtml += '<td align ="center" style="width:25%; font-weight:bold;" bgcolor="#E6E6E6">' + jM.exp.e + 'kWh</td>';
				sTHtml += '</tr>';

				sTHtml += '<tr align ="center">';
				sTHtml += '<td bgcolor="#00aeea" colspan="2" style="background:linear-gradient(to top,#00BBF2,#0095DA); width:50%; font-weight:bold;"><font color="white">'+ jM.date +'</font></td>';
				sTHtml += '</tr>';
			}
			return sTHtml;
		}
		
		
	</script>         

    </head>

    <body>
       <div  style="min-width: 400px" >
            <!-- //  header -->
			<jsp:include page="./header.jsp"></jsp:include>  	
			<div class="content-wrap">
				<jsp:include page="./left_menu.jsp"></jsp:include>
						

				<div id="contents">
					<div id="id_svg_img"></div>

            <!-- // contents -->
				</div>
            
            <!-- //content-wrap -->
				
				
			














			
			</div>
            <!-- //wrapper -->
		</div>
	</body>
</html>
