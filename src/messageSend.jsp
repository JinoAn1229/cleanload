<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoUser"%>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord"%>
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
String p_strMap = "";
String p_strIP = "";
String p_strLogo = "";
String p_strLocation = "";

boolean p_bGuest = false;	
	
DaoUser daoU = new DaoUser(); 
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
		}
	
		p_bGuest = true;
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
유저ID에 따라 카메라, 메인 페이지에 로고들을 설정
나중에는 서버별로 나눈다.
*/
if(p_strUserID.equals("test@clean.com")) p_strMap = "MainBg.png";  
else if(p_strUserID.equals("daegu@clean.com")) p_strMap = "excoBg.png"; 
else  p_strMap = "excoBg.png"; if(p_strUserID.equals("test@clean.com")) 
{
	p_strMap = "MainBg.png";  
	p_strIP = "223.171.47.244";
	p_strLogo = "blaklogo.png";
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
		
		var SidList = "";
		var p_AryMsgList = new Array( '살수중입니다.','살수종료', '미세먼지심각', '교통사고조심', '안전운전하세요', '공사중입니다'); 
		
      	$(function()
     	{	
			<%
			out.println("FnSensorList();");
			%>
			
			$("#id_select_message").change(function(){
				document.getElementById("id_push_msg").value = $("#id_select_message option:selected").val();
			})     		
			resetListTable();
     	});
		
		function checkValue(str)
		{ 
			if(str == null)
			return false;
			var v = str.trim();
			if (v == "")
			return false;
			return true;
		}

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
			if(jM.usegoal == 168)	
			{
				var tr2_html = "<tr>"
					+ "<td style='width:3%'> <input type='checkbox' name='check' value='"+ jM.sid +"' /></td>"
					//+ "<td style='width:5%'>" + jM.sid + "</td>"
					+ "<td style='width:5%'>" + jM.name + "</td>"
					+ "<td style='width:3%'>" + jM.exp.d + "</td>"
					+ "<td style='width:3%'>" + jM.exp.c + "</td>"
					+ "<td style='width:3%'>" + jM.exp.p + "</td>"
					+ "<td style='width:8%'>" + jM.message + "</td>"
					+ "<td style='width:8%'>" + jM.date + "</td>"
					+ "</tr>";
   				  
				$('#id_sensor2_list').append(tr2_html);
			}
       	 }
 
 
		function FnSendPushMessage()	
    	{
			
			if(!<%=p_bGuest%>)
			{
				alert("권한이 없습니다.");
				return;
			}
			selectList();
       		var sMessage = $('#id_push_msg').val();
			var nChkSize = 0;
			nChkSize = cheakKor(sMessage);   //메세지가 한글인지 영문인지 체크
			    		
       		if(!checkValue(sMessage))
       		{
       			alert("보낼 메시지를 입력하세요");
       			return ;
       		}
			if(!checkValue(SidList))
       		{
       			alert("선택된 센서가 없습니다.");
       			return ;
       		}
			
			if(nChkSize < 0)
			{
				alert("한글 및 영문자 기본적인 특수문자 만 사용 가능합니다.");
				return ;
			}
			else if(nChkSize > 14)
			{
				alert("메세지 문구가 초과하였습니다.");
				return ;
			}
			
       		var sParam = "cmd=send_msg&sid=" + SidList + "&message=" + sMessage + "&stid="+ "<%=p_strSTID%>";
			
			$.ajaxSetup( { async: false } );
	
			$.getJSON("./query/query_gate_send_msg.jsp",sParam, function(data, status)
			{
		
				if(status == "success")
				{
					var sResponse = "";
					if(data != null)
					sResponse = data.result;
					if(sResponse.indexOf("OK") >= 0)
					{
						alert('전송 성공')
					}
					else
					alert('전송 실패'); 
				}
				else if(status=="error" ||  status=="timeout") // notmodified, parsererror 
				{
					alert('전송 실패'); 
				} 
			});
	
			$.ajaxSetup( { async: true } );
	
    	}
		
		function FnSensorList()
		{
			var sLine = "";
			var oHist = $('#id_message_list');	
			oHist.html(""); 	
			
			sLine = "<div><select id='id_select_message' name='select_sensor'  style=width:300px;height:100%;'>";
			for(var nIndex = 0; nIndex < p_AryMsgList.length; nIndex++)
			{
				sLine += "<option value= '" + p_AryMsgList[nIndex] + "' >" + p_AryMsgList[nIndex] + "</option>";
			}
			
			sLine += "</select>";
			sLine += "</div>"
			oHist.append(sLine);
			
			document.getElementById("id_push_msg").value = $("#id_select_message option:selected").val();

		}
		
		function selectList()
		{

			var chk = document.getElementsByName("check"); // 체크박스객체를 담는다
			var len = chk.length;    //체크박스의 전체 개수
			var strSid = '';      //체크된 체크박스의 value를 담기위한 변수
			var checkCnt = 0;        //체크된 체크박스의 개수
			var checkLast = '';      //체크된 체크박스 중 마지막 체크박스의 인덱스를 담기위한 변수
			var strSidList = '';             //체크된 체크박스의 모든 value 값을 담는다	
			var cnt = 0;                 

			for(var i=0; i<len; i++)
			{
				if(chk[i].checked == true)
				{
					checkCnt++;        //체크된 체크박스의 개수
					checkLast = i;     //체크된 체크박스의 인덱스
				}
			} 

			for(var i=0; i<len; i++)
			{
				if(chk[i].checked == true)
				{  //체크가 되어있는 값 구분
					strSid = chk[i].value;
           	
					if(checkCnt == 1)  //체크된 체크박스의 개수가 한 개 일때,
					{                            
						strSidList += strSid;        //'value'의 형태 (뒤에 ,(콤마)가 붙지않게)
					}
					else      //체크된 체크박스의 개수가 여러 개 일때,
					{                                           
						if(i == checkLast)    strSidList += strSid;   //체크된 체크박스 중 마지막 체크박스일 때,
						else  strSidList += strSid+"_";	 //sid_의 형태 (뒤에 _가 붙게)					
					}
					cnt++;
					strSid = '';    //strSid.
				}
			}	
			SidList = strSidList;  //sid목록을 메세지 전송 함수에서 보내기 위해 전역변수로 바꿈			
		}	
		
		function cheakKor(strMsg)
		{	
			var nTotalSize = 0;
			for (var nIndex = 0; nIndex < strMsg.length; nIndex++)
			{
				var chr = strMsg.substr(nIndex,1)
				chr = escape(chr);
				
				if (chr.charAt(1) == "u") 
				{
					chr = chr.substr(2, (chr.length - 1)); 

					if((chr >= "AC00") || (chr <= "D7A3")) // 한글의 범위
					{
						nTotalSize += 2; 	
					}
					else  
					{ 
						return -1;
					}
					
				}				
				else
				{
					nTotalSize ++;  
				}
				
			}
			return nTotalSize;
		}
			
     	</script>		
    </head>


    <body>
		<div  style="min-width: 400px">
            <!-- //  header -->
			<jsp:include page="./header.jsp"></jsp:include>
			<div class="content-wrap">        	
			<jsp:include page="./left_menu.jsp"></jsp:include>		   				
				<div id="contents">		       
					<div class="container" >						                
						<div class="search-wrap" >                   
							<div class="list-wrap">										
								<div class="list-def">	
								
									<div  style="margin:25px 0px 0px 0px;" >
										<h3 class="tit-list">메시지 전송</h3>
									</div>
									
									<div class="tbl-head">
										<table>
											<caption>리스트head</caption>										
											<colgroup>
												<col style="width:3%">
												
												<col style="width:5%">
												<col style="width:3%">
												
												<col style="width:3%">       
												<col style="width:3%"> 
												<col style="width:8%">
												<col style="width:8%">												
											</colgroup>

											<thead>
												<tr>
													<th>선택</th>
													
													<th>센서이름</th>
													<th>온도</th>
													
													<th>이산화탄소</th>
													<th>미세먼지</th>
													<th>전광판 상태</th>
													<th>날짜</th>													
												</tr>
											</thead>
										</table>
									</div>

									<!-- // table-head -->
									
									<table id='id_sensor2_list'>										
									</table>
									
									<div style="width:50%; height:100%; font-size : 15px; margin-top:20px;">메세지 리스트입니다. 원하는 문구를 선택하세요.</div>
									<div id='id_message_list' style="width:20%; height:100%; font-size : 30px; margin-top:5px;"></div>
									
									<div style="width:50%; height:100%; font-size : 15px; margin-top:30px;">사용자가 원하는 문구를 직접입력하는 란입니다.</div>
									<div style="width:50%; height:100%; font-size : 15px; color:red; ">*한글 7자, 영문 14자 초과입력 불가</div>
									<input type="text" id='id_push_msg'   style="width:300px;height:100%; font-size : 30px; font-weight:bold; margin-top:5px; margin-bottom:20px;">
									
									<div class="dist-cont"><button class="btn-list btn-rowsearch blue" onClick='FnSendPushMessage()'>메세지 전송</button></div>
									
						 
								</div>
                            <!-- // list-def -->							
							</div>
						</div>          <!-- // 리스트 영역 -->			 
					</div>
				</div>    
			</div>
            <!-- //wrapper -->
		</div>
		<footer>
                Copyright BLAKSTONE.CO.,LTD. All Right reserved.
		</footer>
		
	</body>
</html>
