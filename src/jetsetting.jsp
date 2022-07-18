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
<%@ page import="wguard.dao.DaoCleanloadInfo"%>
<%@ page import="wguard.dao.DaoCleanloadInfo.DaoCleanloadInfoRecord"%>
<%@ page import="wguard.dao.DaoFamily" %>  
<%@ page import="wguard.dao.DaoFamily.DaoFamilyRecord" %>
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

String strSID = EtcUtils.NullS(request.getParameter("sid"));

JSONObject joS = null;
JSONArray p_jaSList = new JSONArray();

String p_strSTID = "";
String p_strSchedule = "";
int p_nWaterTime = 0; 
boolean p_bManager = false;

DaoUser daoU = new DaoUser(); 
DaoUserRecord rUR = daoU.getUser(p_strUserID);	
DaoSite daoS = new DaoSite();



	
		
if(rUR != null)
{
	if(rUR.m_strAccount.equals("user"))
	{ 
		DaoFamily daoFamily = new DaoFamily();
		DaoFamilyRecord rFR = daoFamily.getUser(p_strUserID);
		DaoSiteRecord rSR = daoS.getUID(rFR.m_strUID);
		if(rSR != null)
		{
			p_strSTID = rSR.m_strSTID;
			p_strSchedule = rSR.m_strScheduleMode;
		}
	}
	else if(rUR.m_strAccount.equals("manager"))
	{ 
		DaoSiteRecord rSR = daoS.getUID(p_strUserID);
		if(rSR != null)
		{
			p_strSTID = rSR.m_strSTID;
			p_strSchedule = rSR.m_strScheduleMode;
		}
		p_bManager = true;
	}
}


String p_strExp = "";

if(p_strSTID != null)
{
	DaoSensor daoSensor = new DaoSensor();
	ArrayList<DaoSensorRecord> arySensor =  daoSensor.selectSensor(p_strSTID,true);
	ArrayList<String> arySIDs =  new ArrayList<String>();
	HashMap<String, JSONObject> mapSensor = new HashMap<String, JSONObject>();

	if(arySensor.size() > 0)
	{
		DaoCleanloadInfo daoCleanloadInfo = new DaoCleanloadInfo();	
		DaoCleanloadInfoRecord rCt = daoCleanloadInfo.getCleanloadInfo(arySensor.get(0).m_strSID,true);
		if(rCt != null)
		{
			p_nWaterTime = rCt.m_nWatertime;
		}
	}

	for(DaoSensorRecord rSR : arySensor)
	{
		joS = new JSONObject();
		joS.put("sid",rSR.m_strSID);
		joS.put("sname",rSR.m_strSName);
		joS.put("usegoal",160);
		p_strExp = rSR.m_strAlarmVal;
		p_jaSList.put(joS);

		//센서 최종 상태를 조회 하기위해 SID모음
		arySIDs.add(rSR.m_strSID);
		mapSensor.put(rSR.m_strSID,joS);
	}

	DaoSensorSt daoSSt = new DaoSensorSt();	
	ArrayList<DaoSensorStRecord> arySStR =  daoSSt.selectLastSensorSt(arySIDs);
	for(DaoSensorStRecord rSSt :  arySStR)
	{
		joS = mapSensor.get(rSSt.m_strSensorID);
		if(joS != null) joS.put("usegoal",rSSt.m_nUseGoal);
	}
}

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

        <title>클린로드</title>

        <link rel="stylesheet" href="css/normalize_custom.css">
        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <link rel="stylesheet" href="css/jquery.mCustomScrollbar.min.css">
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/index.css?ver=1">
        <link rel="stylesheet" href="css/view.css?ver=6">
        <link rel="stylesheet" href="css/jquery-ui-timepicker-addon.css">
        <script src="js/jquery-1.12.1.min.js"></script>
        <script src="js/jquery-ui.min.js"></script>
        <script src="js/jquery.mCustomScrollbar.concat.min.js"></script>
         <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
        <script src="js/jquery-ui-timepicker-addon.js"></script>
		<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

    	<script type="text/javascript">
		var j_jaSList = <%=p_jaSList.toString()%>;
		var j_jaTimeTable = null;
		var j_sAuto = "<%=p_strSchedule%>";
		var p_AryTime = new Array('10', '20', '30');
		var p_strSid = "";	
      	$(function()
     	{
			
			<%
			out.println("FnSensorList();");
			%>
			FnTimeTable();
			FnSchedule();
			FnWaterTimeList();
     		$(".tbl-body").mCustomScrollbar();	
     	});
         
		 /**
		* 설명 : 문자열에 값이 있는지 확인한다.
		* @param str : 확인할 문자열
		* @return
		*/
		 function checkValue(str)
		{ 
			if(str == null)
			return false;
			var v = str.trim();
			if (v == "")
			return false;
			return true;
		}
       	var	j_nDispPageNum = 1;  // 현재 페이지 번호(1base) 
			var j_sLastSearchParam = ""; // 마지막 조회 조건문 
       	//==================================
       	// 목록 갱신

		function FnSensorList()
		{
			var sLine = "";
			var oHist = $('#id_sensor_list');	
			oHist.html(""); 	

			sLine = "<div><select id='id_select_sensor' name='select_sensor'  style='width:100px;' onchange='FnSensorSelection()'>";

			if(j_jaSList.length>=0) 
			{	
				for(var i =0; i <  j_jaSList.length; i++)
				{
					if(j_jaSList[i].usegoal == 169)  
					{	
						if( j_jaSList[i].sid == "<%=strSID%>") 
						{
							sLine += "<option value='" + j_jaSList[i].sid + "' selected='selected'>" + j_jaSList[i].sname + "</option>";
						}
						else									
							sLine += "<option value='" + j_jaSList[i].sid + "'>" + j_jaSList[i].sname + "</option>";
						}
					}
				}
			sLine += "</select>";
			sLine += "</div>"
			oHist.append(sLine);
			

			return ;
		}
		
		function FnSensorSelection()
		{		
			p_strSid = $('#id_select_sensor').val();
			FnTimeTable();
		}
		
		function FnTimeTable()
		{
			var strSID = $('#id_select_sensor').val();
			var strQuery = "./query/query_jet_setting_list.jsp?stid=<%=p_strSTID%>" ;
			
       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{
        			if(root.result =="OK")
        			{
						j_jaTimeTable =  root.jetsetting;
						for(var i =1; i <= 12; i++)
						{
							FnTimeOneTable(i);
						}
        			}
       			}
       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
		}

		

		function FnTimeOneTable(month)
		{
			var sTHtml = "";
			var strTableID = "id_time_table_" + month;
			var oHist = document.getElementById(strTableID);
			sTHtml = "<div class='list-wrap'>";
			sTHtml += "<div class='list-def'>";

			sTHtml += "<div class='tbl-head'>";
			sTHtml += "<table>";
			sTHtml += "<colgroup><col style='width:95%'></colgroup>";
			sTHtml += "<thead><tr><th>"+month+"월</th></tr></thead>"
			sTHtml += "</table></div>";

			sTHtml += "<div class='tbl-body' style='height:300px'>";
			sTHtml += "<table>";
			sTHtml += "<colgroup><col style='width:40%'><col style='width:30%'></colgroup><col style='width:30%'>"
			sTHtml += "<tbody>";
			sTHtml += "<tr><td>동작시간</td><td>"+FnSTimeSelete(month)+"</td><td>"+FnETimeSelete(month)+"</td></tr>";
			sTHtml += "<tr><td>평시</td><td>"+FnNomalCountSelete(month)+"</td><td>"+FnNomalIntervalSelete(month)+"</td></tr>";
			sTHtml += "<tr><td>미세먼지특보</td><td>"+FnDustCountSelete(month)+"</td><td>"+FnDustIntervalSelete(month)+"</td></tr>";
			sTHtml += "<tr><td>폭염특보</td><td>"+FnHeatCountSelete(month)+"</td><td>"+FnHeatIntervalSelete(month)+"</td></tr>";
			

			sTHtml += "</tbody></table></div>"
			sTHtml += "</div></div>"


			oHist.innerHTML = sTHtml;
		}

		
		
		function FnSTimeSelete(month)
		{
			var sSHtml = "<div><select id='id_select_shour_"+month+"' style=width:50px;'>";
			
			for(var nIndex = 0; nIndex < j_jaTimeTable.length; nIndex++)
			{
				if(j_jaTimeTable[nIndex].month == month)
					sSHtml +="<option selected='selected' value='" + j_jaTimeTable[nIndex].shour + "'>" + j_jaTimeTable[nIndex].shour + "시</option>";
			}
	
			for(var i =0; i < 24; i++)
			{
				sSHtml += "<option value='" + i + "'>" + i + "시</option>";
			}
			sSHtml += "</select></div>";

			return sSHtml;
		}
		
		function FnETimeSelete(month)
		{
			var sSHtml = "<div><select id='id_select_ehour_"+month+"' style=width:50px;'>";
			
			for(var nIndex = 0; nIndex < j_jaTimeTable.length; nIndex++)
			{
				if(j_jaTimeTable[nIndex].month == month)
					sSHtml +="<option selected='selected' value='" + j_jaTimeTable[nIndex].ehour + "'>" + j_jaTimeTable[nIndex].ehour + "시</option>";
			}
	
			for(var i =0; i < 24; i++)
			{
				sSHtml += "<option value='" + i + "'>" + i + "시</option>";
			}
			sSHtml += "</select></div>";

			return sSHtml;
		}

		function FnNomalCountSelete(month)
		{
			var sSHtml = "<div><select id='id_select_nomal_count_"+month+"' style=width:50px;'>";
			
			for(var nIndex = 0; nIndex < j_jaTimeTable.length; nIndex++)
			{
				if(j_jaTimeTable[nIndex].month == month)
					sSHtml +="<option selected='selected' value='" + j_jaTimeTable[nIndex].nomalcount + "'>" + j_jaTimeTable[nIndex].nomalcount + "번</option>";
			}
	
			for(var i =0; i < 10; i++)
			{
				sSHtml += "<option value='" + i + "'>" + i + "번</option>";
			}
			sSHtml += "</select></div>";

			return sSHtml;
		}

		function FnNomalIntervalSelete(month)
		{
			var sSHtml = "<div><select id='id_select_nomal_interval_"+month+"' style=width:50px;'>";
			
			for(var nIndex = 0; nIndex < j_jaTimeTable.length; nIndex++)
			{
				if(j_jaTimeTable[nIndex].month == month)
					sSHtml +="<option selected='selected' value='" + j_jaTimeTable[nIndex].nomalinterval + "'>" + j_jaTimeTable[nIndex].nomalinterval + "분</option>";
			}
	
			for(var i =0; i <= 180; i+=30)
			{
				sSHtml += "<option value='" + i + "'>" + i + "분</option>";
			}
			sSHtml += "</select></div>";

			return sSHtml;
		}
		
		function FnDustCountSelete(month)
		{
			var sSHtml = "<div><select id='id_select_dust_count_"+month+"' style=width:50px;'>";
			
			for(var nIndex = 0; nIndex < j_jaTimeTable.length; nIndex++)
			{
				if(j_jaTimeTable[nIndex].month == month)
					sSHtml +="<option selected='selected' value='" + j_jaTimeTable[nIndex].dustcount + "'>" + j_jaTimeTable[nIndex].dustcount + "번</option>";
			}
	
			for(var i =0; i < 10; i++)
			{
				sSHtml += "<option value='" + i + "'>" + i + "번</option>";
			}
			sSHtml += "</select></div>";

			return sSHtml;
		}

		function FnDustIntervalSelete(month)
		{
			var sSHtml = "<div><select id='id_select_dust_interval_"+month+"' style=width:50px;'>";
			
			for(var nIndex = 0; nIndex < j_jaTimeTable.length; nIndex++)
			{
				if(j_jaTimeTable[nIndex].month == month)
					sSHtml +="<option selected='selected' value='" + j_jaTimeTable[nIndex].dustinterval + "'>" + j_jaTimeTable[nIndex].dustinterval + "분</option>";
			}
	
			for(var i =0; i <= 180; i+=30)
			{
				sSHtml += "<option value='" + i + "'>" + i + "분</option>";
			}
			sSHtml += "</select></div>";

			return sSHtml;
		}
		
		function FnHeatCountSelete(month)
		{
			var sSHtml = "<div><select id='id_select_heat_count_"+month+"' style=width:50px;'>";
			
			for(var nIndex = 0; nIndex < j_jaTimeTable.length; nIndex++)
			{
				if(j_jaTimeTable[nIndex].month == month)
					sSHtml +="<option selected='selected' value='" + j_jaTimeTable[nIndex].heatcount + "'>" + j_jaTimeTable[nIndex].heatcount + "번</option>";
			}
	
			for(var i =0; i < 10; i++)
			{
				sSHtml += "<option value='" + i + "'>" + i + "번</option>";
			}
			sSHtml += "</select></div>";

			return sSHtml;
		}

		function FnHeatIntervalSelete(month)
		{
			var sSHtml = "<div><select id='id_select_heat_interval_"+month+"' style=width:50px;'>";
			
			for(var nIndex = 0; nIndex < j_jaTimeTable.length; nIndex++)
			{
				if(j_jaTimeTable[nIndex].month == month)
					sSHtml +="<option selected='selected' value='" + j_jaTimeTable[nIndex].heatinterval + "'>" + j_jaTimeTable[nIndex].heatinterval + "분</option>";
			}
	
			for(var i =0; i <= 180; i+=30)
			{
				sSHtml += "<option value='" + i + "'>" + i + "분</option>";
			}
			sSHtml += "</select></div>";

			return sSHtml;
		}

		function FnEditJetSetting()
		{
			FnEditScheduleSetting();
			
			var JaSetting = new Array();
			var JoSetting = null;
			for(var nIndex = 1; nIndex <= j_jaTimeTable.length; nIndex++)
			{		
				var JShour = "id_select_shour_" + nIndex;
				var JEhour = "id_select_ehour_" + nIndex;
				var JNcount = "id_select_nomal_count_" + nIndex;
				var JNinterval = "id_select_nomal_interval_" + nIndex;
				var JDcount = "id_select_dust_count_" + nIndex;
				var JDinterval = "id_select_dust_interval_" + nIndex;
				var JHcount = "id_select_heat_count_" + nIndex;
				var JHinterval = "id_select_heat_interval_" + nIndex;
								
				JoSetting =	new Object();	
				JoSetting.Stid = "<%=p_strSTID%>";
				JoSetting.Month = nIndex;				
				JoSetting.Shour = document.getElementById(JShour).value;				
				JoSetting.Ehour = document.getElementById(JEhour).value;			
				JoSetting.Ncount = document.getElementById(JNcount).value;			
				JoSetting.Ninterval = document.getElementById(JNinterval).value;			
				JoSetting.Dcount = document.getElementById(JDcount).value;				
				JoSetting.Dinterval = document.getElementById(JDinterval).value;				
				JoSetting.Hcount = document.getElementById(JHcount).value;
				JoSetting.Hinterval = document.getElementById(JHinterval).value;
							
				JaSetting.push(JoSetting);			
			}	
				 
			$.ajax(
			{
				type: "POST",  
				url: './query/query_jet_setting_set.jsp',
				data: JSON.stringify(JaSetting),
				dataType: 'json',
				async: false,
				success: function(root,status,xhr)
				{
					if(status=="success")
					{
						var sResponse = "";
						if(sResponse.indexOf("OK") >= 0)
							alert("수정실패");
						else
							location.href='jetsetting.jsp';
					}
					else if(status=="error" ||  status=="timeout") // notmodified, parsererror 
					{
						alert("수정실패");
					} 
				}
			});
		}

		
		function FnSchedule()
		{
			if(j_sAuto == 'on') 
			{
				$('#id_auto_on').css("display","inline");
				$('#id_auto_off').css("display","none");
			}
			else
			{
				$('#id_auto_on').css("display","none");
				$('#id_auto_off').css("display","inline");
			}
		}

		function FnAutoSwitchToggle()
		{
			j_sAuto = j_sAuto == 'on' ? 'off' : 'on';
			FnSchedule();
		}
		
		function FnEditScheduleSetting()
		{
			var bSuccess = false;
			if(<%=p_bManager%>)
			{
				var srtWaterTime = $("#id_select_watertime").val();
				//var sData = "stid=<%=p_strSTID%>&auto=" + j_sAuto + "&time=" + srtWaterTime;   //함체는 알람값 선택 없음  
				var sData = "stid=<%=p_strSTID%>&time=" + srtWaterTime;   //함체는 알람값 선택 없음				
				$.get("./query/query_watertime.jsp",sData, function(data, status)
				{
					if(status=="success")
					{
						var sResponse = "";
						if(data != null)
							sResponse = data.trim();
						if(sResponse.indexOf("OK") >= 0)
							bSuccess = true;
						else
							alert('수정실패'); 
					}
					else if(status=="error" ||  status=="timeout") // notmodified, parsererror 
					{
						alert('실행실패'); 
					} 
				});
			}
			else alert('권한이 없습니다.');
		}
	
		function FnWaterTimeList()
		{
			var sLine = "";
			var oHist = $('#id_water_time_list');	
			oHist.html(""); 	

			sLine = "<div><select id='id_select_watertime' name='id_select_watertime'  style='width:50px; margin:0px 0px 0px 0px;'>";

			for(var i = 0; i <  p_AryTime.length; i++)
			{
				if(p_AryTime[i] == <%=p_nWaterTime%> ) sLine += "<option selected='selected' value='" + p_AryTime[i] + "'>" + p_AryTime[i] + "분</option>";
				else  sLine += "<option value='" + p_AryTime[i] + "'>" +p_AryTime[i] + "분</option>";
			
			}				
			sLine += "</select>";
			sLine += "</div>"
			oHist.append(sLine);

			return ;
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
					<div class="container" >
						<h3 class="tit-list">물 분사 상황 설정</h3>
						<div class="search-wrap" >
							<ul>
								<li>
									<!--<div style="float:left; width:10%; margin:5px 0px 0px 0px; font-weight:bold;">자동 물 분사 설정 :</div>
									<div  style="float:left; width:5%; cursor:pointer; "  onClick="FnAutoSwitchToggle()">
									  아래 2개 이미지는 스크립트  FnAlarmDisplay()에서 1개만 선택하여 나타낸다. 
										<img id="id_auto_on" src='./images/autoon.png'  height='20px'  style='width:50px;  margin:5px 0px 0px 0px;'>
										<img id="id_auto_off" src='./images/autooff.png'  height='20px'  style='width:50px;  margin:5px 0px 0px 0px;'>
									</div>-->
									<div style="float:left; width:10%; margin:5px 0px 0px 0px; font-weight:bold;">자동 물 분사 시간 :</div>
									<div id='id_water_time_list' style="float:left; width:5%  margin:5px 0px 0px 0px;"></div>
									<div style= "margin:0px 250px 0px 50px; float:left; width:25%;"><button class="btn-list btn-rowsearch blue" onClick='FnEditJetSetting()'>설정 적용</button></div>
								</li>
							</ul>
							<table style="width: 100%">
								<colgroup>
									<col style="width:13%">
									<col style="width:13%">
									<col style="width:13%">
									<col style="width:13%">       
									<col style="width:13%"> 
									<col style="width:13%">
								</colgroup>
								<tr>
									<td id='id_time_table_1'></td>
									<td id='id_time_table_2'></td>
									<td id='id_time_table_3'></td>
									<td id='id_time_table_4'></td>
									<td id='id_time_table_5'></td>
									<td id='id_time_table_6'></td>
								</tr>
								<tr>
									<td id='id_time_table_7'></td>
									<td id='id_time_table_8'></td>
									<td id='id_time_table_9'></td>
									<td id='id_time_table_10'></td>
									<td id='id_time_table_11'></td>
									<td id='id_time_table_12'></td>
								</tr>
							</table>
						</div>
					</div>
				</div>
            <!-- //wrapper -->
		<footer>
                Copyright BLAKSTONE.CO.,LTD. All Right reserved.
		</footer>
	</div>
	</body>
</html>
