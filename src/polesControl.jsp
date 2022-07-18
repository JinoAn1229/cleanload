<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoSite"%>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord"%>
<%@ page import="wguard.dao.DaoUser"%>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord"%>
<%@ page import="wguard.dao.DaoSensor"%>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord"%>
<%@ page import="wguard.dao.DaoSensorSt"%>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord"%>
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
/*
일단 아이디에 있는 사이트가 하나일 경우 이렇게 처리
아이디에 사이트를 여러개 쓰게 되면 리스트로 사이트 선택할 수 있게 만들기
*참고 - SensorStRecord소스
*/
String p_strSTID = ""; 
String p_strAutoMode = ""; 
int p_nWaterTime = 0; 


boolean p_bManager = false;	

	
	
DaoUser daoU = new DaoUser(); 
DaoSensor daoSensor = new DaoSensor();
DaoFamily daoFamily = new DaoFamily(); 
DaoUserRecord rUR = daoU.getUser(p_strUserID);	
DaoSite daoS = new DaoSite();
if(rUR != null)
{
	if(rUR.m_strAccount.equals("manager"))
	{ 
		DaoSiteRecord rSR = daoS.getUID(p_strUserID);
		if(rSR != null)
		{
			p_strSTID = rSR.m_strSTID;
			p_strAutoMode = rSR.m_strAuto;
		}
		p_bManager = true;
		
		ArrayList<DaoSensorRecord> arySensor =  daoSensor.selectUser(p_strUserID, true);
		if(arySensor.size() > 0)
		{
			DaoCleanloadInfo daoCleanloadInfo = new DaoCleanloadInfo();	
			DaoCleanloadInfoRecord rCt = daoCleanloadInfo.getCleanloadInfo(arySensor.get(0).m_strSID,true);
			if(rCt != null)
			{
				p_nWaterTime = rCt.m_nWatertime;
			}
		}
	}
	
	else if(rUR.m_strAccount.equals("user"))
	{ 
		
		DaoFamilyRecord rFR = daoFamily.getUser(p_strUserID);
	
		DaoSiteRecord rSR = daoS.getUID(rFR.m_strUID);
		if(rSR != null)
		{
			p_strSTID = rSR.m_strSTID;
			p_strAutoMode = "No permission";
		}
		ArrayList<DaoSensorRecord> arySensor =  daoSensor.selectUser(p_strUserID, true);
		if(arySensor.size() > 0)
		{
			DaoCleanloadInfo daoCleanloadInfo = new DaoCleanloadInfo();	
			DaoCleanloadInfoRecord rCt = daoCleanloadInfo.getCleanloadInfo(arySensor.get(0).m_strSID,true);
			if(rCt != null)
			{
				p_nWaterTime = rCt.m_nWatertime;
			}
		}
	}
	
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
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>클린로드</title>

        <link rel="stylesheet" href="css/normalize_custom.css">
        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <link rel="stylesheet" href="css/jquery.mCustomScrollbar.min.css">
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/index.css?ver=8">
        <script src="js/jquery-1.12.1.min.js"></script>
        <script src="js/jquery-ui.min.js"></script>
        <script src="js/jquery.mCustomScrollbar.concat.min.js"></script>
        <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
		 <script type="text/javascript">
		
		var strOpen = "true";
		var strClose = "false";
		var j_sAuto = "<%=p_strAutoMode%>";
		var j_JetColor = "";
		var j_jaJetState = new Array();;
		var j_bCheck = false;
		var j_bControl = true;
		var CheckQuery = null;
		var p_AryTime = new Array('10', '20', '30');
		var aryRecord = new Array();

		
      	$(function()
     	{	     		
			resetListTable();
			FnAutoWater();
			FnWaterTimeList();
			FnAllWaterTimeList();
			FnTimeTable();		
     	});

       	function resetListTable()
       	{   		
       	 	
			var strQuery = "./query/query_cleanload_list.jsp?stid="+ "<%=p_strSTID%>";
			
       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{        		 	
        			if(root.result =="OK")
        			{
						aryRecord =  root.members;
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
		    var  nWaterFlow = Number(jM.exp.w);
			var  strWaterFlow = "";
			if(nWaterFlow == 0)  strWaterFlow = "살수종료";
			else  strWaterFlow = "살수중";
			if(jM.usegoal == 168)
			{	
				var tr_html = "<tr>"
					//+ "<td style='width:5%'>" + jM.sid + "</td>"
					+ "<td style='width:5%'>" + jM.name + "</td>"
					+ "<td style='width:5%'><input id='id_dval' name='' type='text'  value='" + jM.etc.d + "' onFocus='clearText(this);' ></td>"
					+ "<td style='width:5%'><input id='id_uval' name='' type='text'  value='" + jM.etc.u + "' onFocus='clearText(this);' ></td>";
					if(<%=p_bManager%>)
					tr_html += "<td style='width:5%'> <button type='button' onclick=\'javascript:FnRegisterAlramVal(\"" + jM.sid + "\");\'>적용</button></td>"
					else
					tr_html += "<td style='width:5%'> <button type='button' onclick=\'javascript:FnNoControl();\'> 권한없음</button></td>"	
					tr_html += "</tr>";
   				  
				$('#id_sensor_list').append(tr_html);
			}
			else if(jM.usegoal == 169)
			{	
				var	strSelectID = "id_watertime_" + jM.sid;	
				var select_html = "<div><select id='" + strSelectID + "'name='id_watertime_" + jM.sid + "' style='width:50px; margin:0px 0px 0px 0px;'>";
				for(var i = 0; i <  p_AryTime.length; i++)
				{
					if(p_AryTime[i] == <%=p_nWaterTime%> )
					select_html +="<option selected='selected' value='" + p_AryTime[i] + "'>" + p_AryTime[i] + "분</option>";
					else select_html += "<option value='" + p_AryTime[i] + "'>" +p_AryTime[i] + "분</option>";
				}
				select_html += "</select>";
				select_html += "</div>";
				var tr2_html = "<tr>"
					//+ "<td style='width:4%'>" + jM.sid + "</td>"
					+ "<td style='width:3%';>" + jM.name + "</td>"
					+ "<td style='width:3%'>" + strWaterFlow + "</td>"
					+ "<td style='width:3%'>" + jM.exp.f + "m³</td>"
					+ "<td style='width:3%'>" + jM.exp.e + "kWh</td>"
					+ "<td style='width:3%'>" + select_html + "</td>";
					
					if(<%=p_bManager%>)
					{		
						if(nWaterFlow == 0) tr2_html += "<td style='width:3%'> <button type='button' onclick=\'javascript:FnPolesControlEvent(\"" + jM.sid + "\",\"" + strOpen +"\",\"" + strSelectID +"\");\'>Start</button></td>"
						else if(nWaterFlow == 1)  tr2_html += "<td style='width:3%'> <button type='button' onclick=\'javascript:FnPolesControlEvent(\"" + jM.sid + "\",\"" + strClose +"\",\"" + strSelectID +"\");\'>Stop</button></td>"						
					}
					else
					{
						tr2_html += "<td style='width:3%'> <button type='button' onclick=\'javascript:FnNoControl();\'>권한없음</button></td>"
					}
					tr2_html += "</tr>";
   				  
				$('#id_sensor2_list').append(tr2_html);							
			}
			
			FnAllControlState();
       	}
	
	//onclick이벤트로 array값이 배열이 아닌 문자열로 전달되서 함수를 하나 더 만들었다.
	function FnPolesControlEvent(Sid, bStop, time)
	{
		if(!j_bControl)
		{
			alert('명령수행 중입나다.. 기다려주십시오.');
			return;
		}				
		
		var aryStrSid = new Array();
		if(Sid == "all")
		{
			for(var i=0; i < aryRecord.length; i++)
			{	
				var objItem = aryRecord[i];
				if(objItem.usegoal == 169)
				{		
					aryStrSid.push(objItem.sid);
				}
			}
		}
		else
		{
			aryStrSid.push(Sid);
		}
		
		FnPolesControl(aryStrSid, bStop, time)
	}
	
	function FnNoControl()
	{
		alert("권한이 없습니다.");
	}	
		
		
	function FnRegisterAlramVal(sid)
	{
		var sDval = $('#id_dval').val();
		var sUval = $('#id_uval').val();
				
		var sAlramVal = "d="+ sDval + "\\u=" + sUval;
		
		
		var sParam = "salarm=" + sAlramVal + "&sid=" + sid;	
		
		$.getJSON("./query/query_dust_alarm.jsp",encodeURI(sParam), function(data, status)
			{
		
				if(status == "success")
				{
					var sResponse = "";
					if(data != null)
					sResponse = data.result;
					if(sResponse.indexOf("OK") >= 0)
					{
						alert('설정값이 변경되었습니다.')
					}
					else
					alert('변경 실패'); 
				}
				else if(status=="error" ||  status=="timeout") // notmodified, parsererror 
				{
					alert('전송 실패'); 
				} 
			});
	}	
 	
		
	function FnPolesControl(arySid, bStop, time)
	{
		var nSensorCount = 0;
		var bSuccessCheck = false;
		var sid = "";
		var IdWaterSelect = "#" + time;
		var srtWaterTimeMenu = $(IdWaterSelect).val();
		for(var i = 0; i < arySid.length; i++)
		{
			sid = arySid[i];			
			var sParam = "cmd=valves_open&sid=" + sid + "&open=" + bStop + "&time=" + srtWaterTimeMenu;	
			{
				$.getJSON("./query/query_gate_send_msg.jsp",sParam,function(data,status)
				{
					if(status == "success")
					{
						var sResponse = "";
						if(data != null) sResponse = data.result;
						
						if(sResponse.indexOf("OK") >= 0)
						{
							CheckSensorStart(sid, bStop);
							bSuccessCheck = true;
						}
				
						nSensorCount++;
						if(nSensorCount >= arySid.length)
						{
							if(bSuccessCheck)
							{
								if(bStop == "true") alert('물 분사를 시작합니다.'); 
								else if(bStop == "false") alert('물 분사를 중지합니다.');
							}
							else
							{
								if(bStop == "true") alert('물 분사중입니다.'); 
								else if(bStop == "false") alert('중지할 벨브가 없습니다.'); 
							}	
						}
					}
					else  // notmodified, parsererror 
					{
						alert('명령을 수행하지 못했습니다.'); 
					}
					
				});
			}
		}
	}	
 
 	function FnAllControlState()
	{
		var strAllSid = "all"
		var	strSelectID = "id_select_all_watertime"
		var nWaterFlow = 0;
		var strStop = "false";
		for(var i=0; i < aryRecord.length; i++)
		{
			var objItem = aryRecord[i];
			if(objItem.usegoal == 169)
			{
				nWaterFlow = Number(objItem.exp.w);
				if(nWaterFlow == 1) strStop = "true";
			}
		}	
		var sLine = "";
		var oHist = $('#id_all_control');	
		oHist.html(""); 
		if(<%=p_bManager%>)
		{
			if(strStop == "false")
			{
				sLine = "<div><button type='button' onclick=\'javascript:FnPolesControlEvent(\"" + strAllSid + "\",\"" + strOpen +"\",\"" + strSelectID +"\");\'>Start</button>";
			}
			else 
			{
				sLine = "<div><button type='button' onclick=\'javascript:FnPolesControlEvent(\"" + strAllSid + "\",\"" + strClose +"\",\"" + strSelectID +"\");\'>Stop</button>";
			}
			sLine += "</div>"
		}
		else sLine = "<div><button type='button' onclick=\'javascript:FnNoControl();\'>권한없음</button></div>";
		oHist.append(sLine);		
	}
	

	
	function FnAutoWater()
	{
		var oHist = document.getElementById("id_jet_table")
		if(j_sAuto == 'on') 
		{
			$('#id_auto_on').css("display","inline");
			$('#id_auto_off').css("display","none");
			oHist.style.backgroundColor='#b8d6f5';
		}
		else
		{
			$('#id_auto_on').css("display","none");
			$('#id_auto_off').css("display","inline");
			oHist.style.backgroundColor='#848484';
		}
	}
	
	function FnAutoSwitchToggle()
	{
		var oHist = document.getElementById("id_jet_table")
		j_sAuto = j_sAuto == 'on' ? 'off' : 'on';
		FnAutoWater();
		if(j_sAuto == 'on') oHist.style.backgroundColor='#b8d6f5';
		else oHist.style.backgroundColor='#848484';
		
	}

	


	
	function FnEditAutoSetting()
	{
		if(!<%=p_bManager%>)
			{
				alert('권한이 없습니다.');
				return;
			}
		var srtWaterTime = $("#id_select_watertime").val();
		var sData = "stid=<%=p_strSTID%>&auto=" + j_sAuto + "&time=" + srtWaterTime;   //함체는 알람값 선택 없음    
		$.get("./query/query_autosetting.jsp",sData, function(data, status)
		{
			if(status=="success")
			{
				var sResponse = "";
				if(data != null)
					sResponse = data.trim();
				if(sResponse.indexOf("OK") >= 0)
					location.href='polesControl.jsp';
				else
					alert('수정실패'); 
			}
			else if(status=="error" ||  status=="timeout") // notmodified, parsererror 
			{
				alert('실행실패'); 
			} 
		});
		 
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
	
	function FnAllWaterTimeList()
	{
		var sLine = "";
		var oHist = $('#id_all_water_time_list');	
		oHist.html(""); 	

		sLine = "<div><select id='id_select_all_watertime' name='id_select_all_watertime'  style='width:50px; margin:0px 0px 0px 0px;'>";

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
	
	//벨브상태 확인
	function CheckSensorStart(sid, bStop)
	{		
		j_bControl = false; //벨브 동작 중
		//시간 소요가 있으므로 커셔를 대기 상태로 변경
		$("body").css("cursor", "progress");
		
		
		//기존 Interval 초기화
		clearInterval(CheckQuery);  //여러번 눌렀을때 상태들을 클리어한다
		//3초마다 확인 쿼리 실행
		CheckQuery = setInterval(function() { SendCheckSensorQury(sid, bStop); }, 3000);
		//60초안에 수행하지 못하면 에러
		setTimeout(function() { CheckSensorEnd(); }, 60000);
	}	   
	   
	function SendCheckSensorQury(sid, bStop)
	{
		//센서 확인 쿼리를 실행한다
		var strQuery = "./query/query_poles_check.jsp?sid="+ sid;
		$.getJSON(strQuery, function(root,status,xhr){
		if(status == "success")
		{        		 	
			//여기서 전달받은 값에따라 체크 완료된 부분을 적어주는 게 좋을 듯...
			if(root.result =="OK")
			{
				var nWaterFlow =  root.water;
			
			
				if( (bStop == "true" && nWaterFlow == 1) || (bStop == "false" && nWaterFlow == 0) )	
				{
					CheckSuccess(); 
					j_bCheck= true;
				}
			}
		}
		else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
		{
			alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
		}
		}); 
	}
	   
	function CheckSuccess()
	{
		j_bControl = true; //벨브 동작 완료
		//20초 후 명령을 종료하고 결과를 보여준다.	
		//다시 커셔 원래대로
		$("body").css("cursor", "auto");
		//alert("벨브가 성공적으로 동작했습니다.");
		clearInterval(CheckQuery);
		location.reload();		
	}	

	function CheckSensorEnd()
	{
		
		//20초 후 명령을 종료하고 결과를 보여준다.
		if(!j_bCheck)
		{	
			j_bControl = true; //벨브 동작 완료
			clearInterval(CheckQuery);
			//다시 커셔 원래대로
			$("body").css("cursor", "auto");
			//alert("벨브가 동작하지 않았습니다.")
		}
	}
	
	
	
	//자동 물분사기능을 날짜별로 조정한다.
	function FnTimeTable()
		{	
			var oHist = $('#id_jet_table');
			oHist.html("");
			var sLine = "";
			
			var strQuery = "./query/query_jet_list.jsp?stid=<%=p_strSTID%>";
			
       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{
        			if(root.result =="OK")
        			{
						j_jaJetState =  root.jetstate;
						sLine = "<tr class='nhov'>"
						for(var nIndex = 0 ; nIndex < j_jaJetState.length ; nIndex++)
						{							
							if(nIndex == 6)sLine += "</tr><tr class='nhov'>"
							sLine += FnTimeOneTable(j_jaJetState[nIndex].month, j_jaJetState[nIndex].state);							
						}
						sLine += "</tr>"
						$('#id_jet_table').append(sLine);
						
        			}
       			}
       			else 
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
		}

		function FnTimeOneTable(month, state)
		{
			var strTableID = "id_jet_table_" + month;

			var sTHtml = "";
			
			if(state == 'on') sTHtml = "<td class = 'npointer';id='" + strTableID + "'; style='border:1px solid #aaa;'>";
			else if(state == 'off') sTHtml = "<td class = 'npointer';id='" + strTableID + "'; style='border:1px solid #aaa;'>";
		
		
			sTHtml += "<div style='float:left; width:50%; margin:4px 0px 0px 0px;' >"+month+"월</div>"
			
			sTHtml += "<div class = 'pcursor' style='float:left; width:50%; margin:5px 0px 0px 0px;' onClick='FnAJetStateToggle(\"" + month + "\")'>"
			if(state == 'on')
			{
				sTHtml += "<img id='id_jet_on" + month + "' src='./images/autoon.png'  height='20px'  style='width:50px; display:inline;'>"
				sTHtml += "<img id='id_jet_off" + month + "' src='./images/autooff.png'  height='20px'  style='width:50px; display:none;'>"	
			}
			else if(state == 'off')
			{
				sTHtml += "<img id='id_jet_on" + month + "' src='./images/autoon.png'  height='20px'  style='width:50px; display:none;'>"
				sTHtml += "<img id='id_jet_off" + month + "' src='./images/autooff.png'  height='20px'  style='width:50px; display:inline;'>"	
			}
			sTHtml += "</div>"
			sTHtml += "</td>"
			
			return sTHtml; 
		}

		function FnAJetStateToggle(month)
		{
			if(!<%=p_bManager%>)
			{
				alert('권한이 없습니다.');
				return;
			}

			var state = "";
			
			for(var nIndex = 0 ; nIndex < j_jaJetState.length ; nIndex++)
			{							
				if(j_jaJetState[nIndex].month == month)
				{
					state = j_jaJetState[nIndex].state == 'on' ? 'off' : 'on';
					break;
				}
			}
				
			var strQuery = "./query/query_jet_set.jsp?stid=<%=p_strSTID%>&month=" + month + "&state=" + state;

			$.getJSON(strQuery, function(root,status,xhr){
				if(status == "success")
				{
					if(root.result =="OK")
					{
						j_jaJetState[nIndex].state = state;
						FnJetState(month);							
					}
				}
				else 
				{
					alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
				}
			}); 
		}
		
		function FnJetState(month)
		{
			var state = "";
			
			for(var nIndex = 0 ; nIndex < j_jaJetState.length ; nIndex++)
			{							
				if(j_jaJetState[nIndex].month == month)
				{
					state = j_jaJetState[nIndex].state;
					break;
				}
			}

			var sJetOn = "id_jet_on" + month;
			var elmtJetOn = document.getElementById(sJetOn);
			var sJetOff = "id_jet_off" + month;
			var elmtJetOff = document.getElementById(sJetOff);
			if(state == 'on') 
			{
				elmtJetOn.style.display = "inline";
				elmtJetOff.style.display = "none";
			}
			else
			{
				elmtJetOn.style.display = "none";
				elmtJetOff.style.display = "inline";
			}
			
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
						<h3 class="tit-list">물 분사 자동 제어 설정</h3>
						<div class="list-wrap">	
							<div class="list-def">
								<div class="search-wrap" >
									<ul>
										<li>
											<div style="float:left; width:8%; margin:5px 0px 0px 0px; font-weight:bold;">자동 물 분사 설정 :</div>
											<div class= "pcursor";  style="float:left; width:5%; ";   onClick="FnAutoSwitchToggle()">
											<!--  아래 2개 이미지는 스크립트  FnAlarmDisplay()에서 1개만 선택하여 나타낸다. -->
												<img id="id_auto_on" src='./images/autoon.png'  height='20px'  style='width:50px;  margin:5px 0px 0px 0px;'>
												<img id="id_auto_off" src='./images/autooff.png'  height='20px'  style='width:50px;  margin:5px 0px 0px 0px;'>
											</div>
											<div style="float:left; width:8%; margin:5px 0px 0px 30px; font-weight:bold;">자동 물 분사 시간 :</div>
											<div id='id_water_time_list' style="float:left; width:5%  margin:5px 0px 0px 0px;"></div>
											<div style= "margin:0px 0px 0px 0px; float:right; width:70%;"><button class="btn-list btn-rowsearch blue" onClick='FnEditAutoSetting()'>설정 적용</button></div>
										</li>
									</ul>
								</div>	
							
							
						 		
								<table id="id_jet_table"; style="width: 100%; margin:0px 0px 40px 0px;">								
							
								</table>
							
												
								<div class="tbl-head">
									<table>
										<caption>리스트head</caption>
										
										<colgroup>	
											<col style="width:5%">
											<col style="width:5%">
											<col style="width:5%">
											<col style="width:5%">  												
										</colgroup>

										<thead>
											<tr>
												<th>측정스테이션 이름</th>
												<th>노면온도 설정</th>
												<th>초미세먼지(PM<sub>25</sub>) 설정</th>
												<th>설정 적용</th>
											</tr>
										</thead>
									</table>
								</div>

								<!-- // table-head -->
									
								<table id='id_sensor_list'>										
								</table>
									
								<div  style="margin:25px 0px 0px 0px;" >
									<h3 class="tit-list">용수 제어</h3>
								</div>
									
								<div class="search-wrap" >
									<ul>
										<li>
											<div style="float:left; width:4%; margin:5px 0px 0px 0px; font-weight:bold;">전체제어 :</div>
											<div style="float:left; width:10%; margin:2px 0px 0px 0px; font-weight:bold;">
												<div id='id_all_control'></div>
											</div>								
											<div style="float:left; width:8%; margin:5px 0px 0px 0px; font-weight:bold;">자동 물 분사 시간 :</div>
											<div id='id_all_water_time_list' style="float:left; width:5%  margin:5px 0px 0px 0px;"></div>
										</li>
									</ul>
								</div>
								
								<div class="tbl-head">
									<table>
										<caption>리스트head</caption>
											<colgroup>												
												<col style="width:3%">
												<col style="width:3%">      
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">												
												<col style="width:3%">												
											</colgroup>

											<thead>
												<tr>													
													<th>제어스테이션 이름</th>
													<th>물 흐름여부</th>
													<th>총 물사용량</th>
													<th>총 전력사용량</th>
													<th>수동 물 분사 시간</th>
													<th>용수 제어</th>
												</tr>
											</thead>
										</table>
								</div>

								<!-- // table-head -->
									
									<table id='id_sensor2_list'>										
									</table>
									
								
							</div>
						</div>
                            <!-- // list-def -->	
					</div>          <!-- // 리스트 영역 -->
			 
				</div>
           
						<!-- // container -->
				
                                <!-- //페이징 -->

			</div>    
            <!-- // contents -->
 
            
            <!-- //content-wrap -->
		
		</div>
            <!-- //wrapper -->
		<footer>
                Copyright BLAKSTONE.CO.,LTD. All Right reserved.
       </footer>
	</body>
</html>
