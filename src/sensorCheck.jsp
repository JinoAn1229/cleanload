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
		
		var m_tCheckTime = null;
		var m_aryState = null;

      	$(function()
     	{	     		
			SensorCheck();
     	});
       	
		function SensorCheck()
		{
       		m_tCheckTime =  new Date();
//			m_tCheckTime.setTime(m_tCheckTime.getTime()+10000);
			m_tCheckTime.setTime(<%=p_lTime%>-10000);
			m_aryState = new Array();
			var strQuery = "./query/query_sensorList.jsp?stid="+ "<%=p_strSTID%>";
       		$.getJSON(strQuery, function(root,status,xhr){
				if(status == "success")
				{        		 	
        			if(root.result =="OK")
        			{
						var aryRecord =  root.sensor;
						for(var i = 0; i < aryRecord.length; i ++)
						{
							objItem = aryRecord[i];
							var tr_html = "<tr><td style='width:30%'>" + objItem.sname + "</td><td style='width:30%'>확인중</td></tr>";
							$('#id_sensor_list').append(tr_html);

							var data = new Object() ;
							data.sid = objItem.sid;
							data.sname = objItem.sname;
							data.state = 0; //0:확인중 / 1:정상 / 2:오류
							m_aryState.push(data);

							SendSensorCheck(objItem.sid);
						}
						CheckSensorStart();
        			}
       			}
       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
		}

		function SendSensorCheck(strSID)
		{
			var sParam = "cmd=check_msg&sid=" + strSID;
			
			$.ajaxSetup( { async: false } );
	
			$.getJSON("./query/query_gate_send_msg.jsp",sParam, function(data, status)
			{
				if(status == "success")
				{
					var sResponse = "";
					if(data != null) sResponse = data.result;
					if(sResponse.indexOf("OK") < 0) alert(strSID + '전송 실패'); 
				}
				else if(status=="error" ||  status=="timeout") // notmodified, parsererror 
				{
					alert(strSID + '전송 실패'); 
				} 
			});

			$.ajaxSetup( { async: true } );
		}
		 
       	function CheckSensorStart()
       	{
			//시간 소요가 있으므로 커셔를 대기 상태로 변경
			$("body").css("cursor", "progress");
			
			//여기서 서버에 센서 값 가져오는 명령 실행

			//5초마다 확인 쿼리 실행
			CheckQuery = setInterval(function() { SendCheckSensorQury(); }, 5000);
			setTimeout(function() { CheckSensorEnd(); }, 180000);
		}

       	function SendCheckSensorQury()
       	{
			//센서 확인 쿼리를 실행한다
			var strQuery = "./query/query_sensorList.jsp?stid="+ "<%=p_strSTID%>";
       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{        		 	
					//여기서 전달받은 값에따라 체크 완료된 부분을 적어주는 게 좋을 듯...
					if(root.result =="OK")
        			{
						$('#id_sensor_list').empty();
						var aryRecord =  root.sensor;
						var nCount = 0;
						for(var i = 0; i < aryRecord.length; i ++)
						{
							objItem = aryRecord[i];
							if(addListTable(objItem)) nCount++;
						}
						
						if(aryRecord.length == nCount)
							CheckSensorEnd();
        			}
       			}
       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
		}

       	function CheckSensorEnd()
       	{
			//성공적으로 확인된 경우 반복 명령을 종료한다
			clearInterval(CheckQuery);

			//다시 커셔 원래대로
			$("body").css("cursor", "auto");

			$('#id_sensor_list').empty();
			for(var i = 0; i < m_aryState.length; i ++)
			{
				var tr_html = "<tr><td style='width:30%'>" + m_aryState[i].sname + "</td>";
				if(m_aryState[i].state == 0)
				{
					tr_html += "<td style='width:30%'>시간초과</td></tr>";
				}
				else if(m_aryState[i].state == 1)
				{
					tr_html += "<td style='width:30%'>정상</td></tr>";
				}
				else
				{
					tr_html += "<td style='width:30%'>오류</td></tr>";
				}
				$('#id_sensor_list').append(tr_html);
			}
		}

       	function addListTable(jM)
       	{  
			var tr_html = "<tr><td style='width:30%'>" + jM.sname + "</td>";
			var cutTime = parseDate(jM.date);
			var bGetData = false;

			if(m_tCheckTime < cutTime)
			{
				bGetData = true;
				if(jM.action == "0")
				{
					tr_html += "<td style='width:30%'>정상</td></tr>";
					setSensorState(jM.sid, 1);
				}
				else
				{
					tr_html += "<td style='width:30%'>오류</td></tr>";
					setSensorState(jM.sid, 2);
				}
			}
			else
			{
				tr_html += "<td style='width:30%'>확인중</td></tr>";
			}

			$('#id_sensor_list').append(tr_html);
			return bGetData;
		}

       	function setSensorState(sid, state)
		{
			for(var i = 0; i < m_aryState.length; i ++)
			{
				if(m_aryState[i].sid == sid)
				{
					m_aryState[i].state = state
				}
			}
		}

		function parseDate(sDate)
		{
			if(sDate == null) return null;
			if(sDate.length < 19) return null;
			
			var nY = parseInt(sDate.substring(0,4));
			var nM = parseInt(sDate.substring(5,7));
			var nD = parseInt(sDate.substring(8,10));
			var nH = parseInt(sDate.substring(11,13));
			var nMin = parseInt(sDate.substring(14,16));
			var nS = parseInt(sDate.substring(17,19));

			var nSSS = 0;
			if(sDate.length == 23) nSSS = parseInt(sDate.substring(21,24));
			
			var oDate = new Date(nY,nM-1,nD,nH,nMin,nS,nSSS);
			return oDate;
		}

       	</script>         
    </head>

    <body>
		<div class="content-wrap">
			<h3 class="tit-list">센서 확인</h3>
			<div class="search-wrap" >
				<div class="list-wrap">
					<div class="list-def">
						<div class="tbl-head">
							<table summary="">
								<caption>리스트head</caption>
								<colgroup>
									<col style="width:30%">
									<col style="width:30%">
								</colgroup>
								<thead>
									<tr>
										<th>폴대이름</th>
										<th>상태</th>
									</tr>
								</thead>
							</table>
						</div>
						<table id='id_sensor_list'>
						</table>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
