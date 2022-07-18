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

String p_strSTID = ""; 

boolean p_bManager = true;	
	
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
		}
	}
	else if(rUR.m_strAccount.equals("manager"))
	{ 
		DaoSiteRecord rSR = daoS.getUID(p_strUserID);
		if(rSR != null)
		{
			p_strSTID = rSR.m_strSTID;
		}
		p_bManager = true;
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

JSONObject joSensor = null;
JSONArray p_jaSensor = new JSONArray();

joSensor = new JSONObject();
joSensor.put("key", "f");
joSensor.put("name", "물사용량");
joSensor.put("color", "#DF0101");
joSensor.put("unit", "m³");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "e");
joSensor.put("name", "전력사용량");
joSensor.put("color", "#0000FF");
joSensor.put("unit", "kWh");
p_jaSensor.put(joSensor);

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
        <link rel="stylesheet" href="css/index.css">
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
		var j_jaSensor = <%=p_jaSensor.toString()%>;
		var jaSt = null;

      	$(function()
     	{
			
			<%
			out.println("FnSensorList();");
			%>
            $(".datepicker" ).datetimepicker({
            	dateFormat: "yy-mm-dd",
        		changeMonth: true,
        		dayNames: ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
        		dayNamesMin: ['월', '화', '수', '목', '금', '토', '일'],
        		monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
        		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
				controlType: 'select',
				oneLine: true,
				timeFormat: 'HH'
            });
      		$(".tbl-body").mCustomScrollbar();	
      		
     		j_nDispPageNum = 1;
    		clearListTable();

    		// 기본 1개월 검색
    		FnSetSearchDate(6);
    		resetListTable();
			google.charts.load('current', {'packages':['corechart']});
			google.charts.setOnLoadCallback(drawChart);

			$("#close-pop, #mask").click(function(){
				$("#mask").fadeOut("fast");
				$("#popup").fadeOut("fast",function(){});
		    });

     	});
         
       	var	j_nDispPageNum = 1;  // 현재 페이지 번호(1base) 
		var j_sLastSearchParam = ""; // 마지막 조회 조건문 
		var j_aryRecord = {};
       	//==================================
       	// 목록 갱신
       	 function resetListTable()
       	 {
//       		var nListPerPage = $('#id_selectbox_count_per_page option:selected').val();
       		
      		var sSearchParam = "";

			var sSensorID = $('#id_select_sensor').val();
      	  	var sDateStart = $('#id_date_search_start').val();
      	  	var sDateEnd = $('#id_date_search_end').val();

      		if(!checkValue(sDateStart) || !checkValue(sDateEnd) || !checkValue(sSensorID))
      		{
      	  		alert('검색 조건 부족');
      	  		return; 		
      		}
      		sSearchParam = "&dates=" + sDateStart + "&datee=" + sDateEnd + "&sid=" + sSensorID;

			//시간 설정(Hours)을 위한 값 없으면 시간을 무시한다
			sSearchParam += "&time=hours";

			// 화일 저장을 위해 마지작 조회 조건문 저장
       		j_sLastSearchParam = sSearchParam;
    		
       	 	var strQuery = "./query/query_poles_list.jsp?" + sSearchParam;
			
       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{
        			clearListTable();
        			
        			if(root.result =="OK")
        			{
	          			var nListPerPage = $('#id_selectbox_count_per_page option:selected').val();
						j_aryRecord =  root.members;
		      			$('#id_total_count').text("" + j_aryRecord.length);

						var nTotalSWater = 0.0;
						var nTotalEWater = 0.0;
						var nTotalSElec = 0.0;
						var nTotalEElec = 0.0;
						var nTemp = 0.0;

			 			for(var i = 0; i < j_aryRecord.length; i ++)
         				{
         					if(i >= nListPerPage) break;
							objItem = j_aryRecord[i];
         					addListTable(objItem);
							
							nTemp = parseFloat(objItem.swater);
							if(nTemp > 0 && !isNaN(nTemp))
							{
								if(nTotalSWater == 0) nTotalSWater = nTemp;
								if(nTotalSWater > nTemp) nTotalSWater = nTemp;
							}

							nTemp = parseFloat(objItem.selec);
							if(nTemp > 0 && !isNaN(nTemp))
							{
								if(nTotalSElec == 0) nTotalSElec = nTemp;
								if(nTotalSElec > nTemp) nTotalSElec = nTemp;
							}

							nTemp = parseFloat(objItem.ewater);
							if(nTemp > 0 && !isNaN(nTemp))
							{
								if(nTotalEWater == 0) nTotalEWater = nTemp;
								if(nTotalEWater < nTemp) nTotalEWater = nTemp;
							}

							nTemp = parseFloat(objItem.eelec);
							if(nTemp > 0 && !isNaN(nTemp))
							{
								if(nTotalEElec == 0) nTotalEElec = nTemp;
								if(nTotalEElec < nTemp) nTotalEElec = nTemp;
							}
	         		 	}

		      			$('#id_total_water').text("" + parseFloat(nTotalEWater - nTotalSWater).toFixed(0));
		      			$('#id_total_elec').text("" + parseFloat(nTotalEElec - nTotalSElec).toFixed(0));

         				// 페이지 네비게이션 
         				$("#id_page_navi").html(getPagingStyle04(1, j_aryRecord.length));
        			}
       			}
       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
       	 }
		 
       	 function resetListTable2(nPage)
       	 {
			clearListTable();
			$('#id_total_count').text("" + j_aryRecord.length);
			var nRecordPerPage = $('#id_selectbox_count_per_page option:selected').val();
			for(var i = (nPage-1) * nRecordPerPage ; i < nPage * nRecordPerPage ; i ++)
			{
				if(i >= j_aryRecord.length) break;
				objItem = j_aryRecord[i];
				addListTable(objItem);
			}
			$("#id_page_navi").html(getPagingStyle04(nPage, j_aryRecord.length));
       	 }

		function drawChart() 
		{
			var sSID =  $('#id_select_sensor').val();
			var sDateStart = $('#id_date_search_start').val();
      	  	var sDateEnd = $('#id_date_search_end').val();
			var sParam = "sid=" + sSID + "&dates=" + sDateStart +  "&datee=" + sDateEnd ;

			//시간 설정(Hours)을 위한 값 없으면 시간을 무시한다
			sParam += "&time=hours";

			$.getJSON("./query/query_graph.jsp",sParam,function(data,status){
			if(status == "success")
			{
				if(data.result	== "OK")
				{
					jaSt = data.sensor; 
					for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
					{
						drawOneChart(j_jaSensor[nIndex].key, false);
					}
				}
			}
			});
		}		

		function drawOneChart(strKey, bPopup)
		{
			var strName = "";
			var strColor = ""
			var strUnit = "";
			for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
			{
				if(j_jaSensor[nIndex].key == strKey)
				{
					strName = j_jaSensor[nIndex].name;
					strColor = j_jaSensor[nIndex].color;
					strUnit = j_jaSensor[nIndex].unit;
				}
			}
			
			var dataGraph = new google.visualization.DataTable();
			dataGraph.addColumn('date', '시간');
			dataGraph.addColumn('number', strName);

			var tempData = 0.0;
			var stdData = 0.0;
			var bPrev = false;
			var strExp = "";
			var strPrevExp = "";
			var diffValue = 0.0;
			
			if(jaSt.length > 0)
			{
				if(strKey == "f")
				{
					strPrevExp = jaSt[0].exp.f;
					strExp = jaSt[jaSt.length-1].exp.f;
				}
				if(strKey == "e")
				{
					strPrevExp = jaSt[0].exp.e;
					strExp = jaSt[jaSt.length-1].exp.e;
				}

				diffValue = parseFloat(strPrevExp) - parseFloat(strExp);
			}

			for(var i = 0; i < jaSt.length; i ++)
			{
				if(strKey == "f") strExp = jaSt[i].exp.f;
				if(strKey == "e") strExp = jaSt[i].exp.e;
				
				tempData = FnChartDataFilter(diffValue/100, stdData, strExp);
				if(tempData > -999999)
				{
					//계단식 그래프를 유지하기 위해 변화 발생시 하나 전 데이터를 추가로 출력한다
					//단 하나 전 데이터도 출력했던 경우는 출력하지 않는다
					if((i > 0) && (!bPrev))
					{
						strPrevExp = "";
						if(strKey == "f") strPrevExp = jaSt[i-1].exp.f;
						if(strKey == "e") strPrevExp = jaSt[i-1].exp.e;
						var tempPrevExp = parseFloat(strPrevExp);
						dataGraph.addRows([[parseDate(jaSt[i-1].sdate), tempPrevExp]]);
					}
					
					dataGraph.addRows([[parseDate(jaSt[i].sdate), tempData]]);
					stdData = tempData;
					bPrev = true;
				}
				else
				{
					bPrev = false;
					if(i == jaSt.length-1) dataGraph.addRows([[parseDate(jaSt[i].sdate),  parseFloat(strExp)]]);
				}
			}

			var strHDateFormatType = "yyyy-MM-dd HH:mm:ss";
			var strVDateFormatType = "#.###" + strUnit;

			var HDateFormatter = new google.visualization.DateFormat({ pattern: strHDateFormatType }); 
			HDateFormatter.format(dataGraph, 0); 
			var VDateFormatter = new google.visualization.NumberFormat({ pattern: strVDateFormatType }); 
			VDateFormatter.format(dataGraph, 1); 
						
			var optGraph = {};
			optGraph['title'] = strName + '그래프';
			optGraph['curveType'] = 'none';
			optGraph['legend'] = { position: 'bottom' };
			optGraph['series'] = {0: { color: strColor }};
			optGraph['hAxis'] = { format: strHDateFormatType };
			optGraph['vAxis'] = { format: strVDateFormatType };

			var chart = null;

			if(bPopup)
			{
				chart = new google.visualization.LineChart(document.getElementById('POP_chart'));
			}
			else
			{
				var strChartID = strKey + "curve_chart";
				chart = new google.visualization.LineChart(document.getElementById(strChartID));
			}

			chart.draw(dataGraph, optGraph);
		}

		function FnChartDataFilter(diff, exp1, exp2)
		{
			var tempExp1 = parseFloat(exp1);
			var tempExp2 = parseFloat(exp2);
//			return tempExp;
			if(tempExp1 < -30000) return -999999;
			if(tempExp2 < -30000) return -999999;
			var tempDiff = tempExp1 - tempExp2;

			//if(Math.abs(tempDiff) > 0)
			if(Math.abs(tempDiff) > Math.abs(diff))
			{
				return Math.abs(tempExp2);
			}
			else return -999999;
		}

		function FnSensorList()
		{
			var sLine = "";
			var oHist = $('#id_sensor_list');	
			oHist.html(""); 	

			var sParam = "stid=<%=p_strSTID%>";

			$.ajaxSetup( { async: false } );

			$.getJSON("./query/query_sensorList.jsp",sParam,function(data,status){
				if(status == "success")
				{
					if(data.result	== "OK")
					{
					
						var jaS = data.sensor;
					

						sLine = "<div><select id='id_select_sensor' name='select_sensor'  style=width:100px;'>";
									

						if(jaS.length>=0) 
						{	
							for(var i =0; i <  jaS.length; i++)
							{
								if(jaS[i].usegoal == 169)  
								{	
									if( jaS[i].sid == "<%=strSID%>") 
									{
										sLine += "<option value='" + jaS[i].sid + "' selected='selected'>" + jaS[i].sname + "</option>";
									}
									else									
									sLine += "<option value='" + jaS[i].sid + "'>" + jaS[i].sname + "</option>";
								}
							}
						}
						sLine += "</select>";
						sLine += "</div>"
						oHist.append(sLine);
					}
				}
		
			});	

			$.ajaxSetup( { async: true } );

			return ;
		}
	
       	
       	 function clearListTable()
       	 {   // table 은 thead, tbody 구분되어 만들어져 있어야 함
       		 var nCount = $("#id_list_sensorRecord >tbody >tr").length;
       		 for(var i = 0; i < nCount ; i ++)
       		 {  
       			 $('#id_list_sensorRecord > tbody:last > tr:last').remove();
       		 }
       		 
     		 $('#id_total_count').text('0');

       		 $("#id_page_navi").html(
                        "<a href='' class='pg-first'></a>"
                      + "<a href='' class='pg-prev'></a>"
                      + "<a href='' class='on'>1</a>"
                      + "<a href='' class='pg-next'></a>"
                      + "<a href='' class='pg-last'></a>"
                      );
       	 }
       	 
       	 function getTableData(jM)
		 {          
		    var tr_html = "<tr>" + "<td>" + jM.stime + "</td><td>" + jM.etime + "</td>";			
			var nSwater = parseFloat(jM.swater);
			var nEwater = parseFloat(jM.ewater);
			var nSelec = parseFloat(jM.selec);
			var nEelec = parseFloat(jM.eelec);
			var nHighD = parseFloat(jM.highd);
			var nLowD = parseFloat(jM.lowd);
			var nHighU = parseFloat(jM.highu);
			var nLowU = parseFloat(jM.lowu);
			var nHighP = parseFloat(jM.highp);
			var nLowP = parseFloat(jM.lowp);
			
			if(nSwater < 0 || nEwater < 0 || isNaN(nSwater) || isNaN(nEwater))
				tr_html += "<td>none</td>";
			else
				tr_html += "<td>"+ parseFloat(nEwater - nSwater).toFixed(3) + "m³</td>";
			
			if(nEwater < 0 || isNaN(nEwater))
				tr_html += "<td>"+ nSwater + "m³</td>";
			else
				tr_html += "<td>"+ nEwater + "m³</td>";


			if(nSelec < 0 || nEelec < 0 || isNaN(nSelec) || isNaN(nEelec))
				tr_html += "<td>none</td>";
			else
				tr_html += "<td>"+ parseFloat(nEelec - nSelec).toFixed(3) + "kWh</td>";

			if(nEwater < 0 || isNaN(nEwater))
				tr_html += "<td>"+ nSelec + "kWh</td>";
			else
				tr_html += "<td>"+ nEelec + "kWh</td>";

			if(nHighD < -999 || nLowD > 999 || isNaN(nHighD) || isNaN(nLowD))
				tr_html += "<td>none</td>";
			else
				tr_html += "<td>"+ nHighD + "°C->" + nLowD + "°C</td>";

			if(nHighP < -999 || nLowP > 999 || isNaN(nHighP) || isNaN(nLowP))
				tr_html += "<td>none</td>";
			else
				tr_html += "<td>"+ nHighP + "μg/m³->" + nLowP + "μg/m³</td>";

			if(nHighU < -999 || nLowU > 999 || isNaN(nHighU) || isNaN(nLowU))
				tr_html += "<td>none</td>";
			else
				tr_html += "<td>"+ nHighU + "μg/m³->" + nLowU + "μg/m³</td>";
				
			tr_html += "</tr>";
   				  
       		return tr_html;
		 }

		 function addListTable(jM)
       	 {  
       		$('#id_list_sensorRecord > tbody:last').append(getTableData(jM));
       	 }
       	 //=================================
       	//  페이지 리스트 Navi관련 
       	function Pager_SelectPage(nPage)
       	{
       		j_nDispPageNum = nPage;
			resetListTable2(nPage);
       	}
       	//처음으로
       	function Pager_FirstPage()
       	{
       		j_nDispPageNum = 1;
			resetListTable2(1);
       	}

       	//끝으로
       	function Pager_LastPage(nTotalPage)
       	{
       		j_nDispPageNum = nTotalPage;
			resetListTable2(nTotalPage);
       	}
       	
		function getPagingStyle04(nDispPage, nTotalRecordCnt) 
		{
			var nPageLinkPerDoc = 10;
			var nRecordPerPage = $('#id_selectbox_count_per_page option:selected').val();
			var nTotalPageCnt = Math.floor(nTotalRecordCnt / nRecordPerPage) + (nTotalRecordCnt % nRecordPerPage == 0 ? 0 : 1);

			var nStartPage = Math.floor((nDispPage-1) / nPageLinkPerDoc) * nPageLinkPerDoc + 1;
			var nLastPage = nStartPage + nPageLinkPerDoc - 1;
			if(nLastPage > nTotalPageCnt) nLastPage = nTotalPageCnt;
		
			var sbPageTemplate = "";
			if(nDispPage > 1)
			{
				sbPageTemplate += "<a href='javascript:Pager_FirstPage();' class='pg-first'></a>";
				sbPageTemplate += "<a href='javascript:Pager_SelectPage(" + (nDispPage-1) + ");' class='pg-prev'></a>";
			}
			else
			{
				sbPageTemplate += "<a href='#' class='pg-first'></a>";
				sbPageTemplate += "<a href='#' class='pg-prev'></a>";
			}

			for(var i = nStartPage; i <= nLastPage; i++)
			{
				if(i != nDispPage)
					sbPageTemplate += "<a href='javascript:Pager_SelectPage(" + i + ");'>" + i + "</a>";
				else
					sbPageTemplate += "<a href='#' class='on'>" + i + "</a>";
			}

			if(nDispPage < nTotalPageCnt)
			{
				sbPageTemplate += "<a href='javascript:Pager_SelectPage(" + (nDispPage+1) + ");' class='pg-next'></a>";
				sbPageTemplate += "<a href='javascript:Pager_LastPage(" + nTotalPageCnt + ");' class='pg-last'></a>";
			}
			else
			{
				sbPageTemplate += "<a href='#' class='pg-next'></a>";
				sbPageTemplate += "<a href='#' class='pg-last'></a>";
			}
			return sbPageTemplate;
		}



       	//=================================
       	// 검색 기간 설정
       	function FnSetSearchDate(nDay)
       	{
       		var dateToday = new Date();
       		var dateStart =new Date();
    		$('#id_set_search_date_0').removeClass('on');
    		$('#id_set_search_date_2').removeClass('on');
    		$('#id_set_search_date_6').removeClass('on');
      		$('#id_set_search_date_30').removeClass('on');
      		$('#id_set_search_date_60').removeClass('on');
      		$('#id_set_search_date_90').removeClass('on');
			if(nDay == 0 || nDay == 2 || nDay == 6 || nDay == 30 || nDay == 60 || nDay == 90)
			{
				var sIDon = '#id_set_search_date_' + nDay; // nDay = 0, 3, 7 , 30;
				$(sIDon).addClass('on');
			}
       		if(nDay >= 30)
       		{  // 1,2,3,달 전
       			var nYear = dateToday.getFullYear();
       			var nMonth = dateToday.getMonth();
   				nMonth -= Math.floor((nDay/30));	
       			if(nMonth < 0)
       			{
       				nMonth += 12;
       				nYear --;
       			}
       			dateStart.setFullYear(nYear);
       			dateStart.setMonth(nMonth);
       			dateStart.setDate(dateToday.getDate() +1);
       		}
       		else
       			dateStart.setDate(dateToday.getDate() - nDay);
       		
       		dateStart.setHours(0);
			$('#id_date_search_start').val(dateStart.format('yyyy-MM-dd HH'));
       		$('#id_date_search_end').val(dateToday.format('yyyy-MM-dd HH'));
       	}
       	
       	//============================ 	
       	// 엘셀 저장
       	function FnSaveToExcel()
       	{
      		//location.href='./proc/down_poles.jsp?' + j_sLastSearchParam;
			fnExcelReport();
       	}
       	
		//엑셀
		function fnExcelReport() {
			var tab_text = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
			tab_text = tab_text + '<head><meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8">';
			tab_text = tab_text + '<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>'
			tab_text = tab_text + '<x:Name>poleReport Sheet</x:Name>';
			tab_text = tab_text + '<x:WorksheetOptions><x:Panes></x:Panes></x:WorksheetOptions></x:ExcelWorksheet>';
			tab_text = tab_text + '</x:ExcelWorksheets></x:ExcelWorkbook></xml></head><body>';
			tab_text = tab_text + "<table border='1px'>";

			tab_text += '<tr><th>시작 시간</th><th>종료 시간</th><th>물 사용량</th><th>전체 물 사용량</th><th>전력 사용량</th><th>전체 전력 사용량</th><th>노면온도변화</th><th>미세먼지변화</th><th>초미세먼지변화</th></tr>';

			for(var i = 0; i < j_aryRecord.length; i ++)
			{
				tab_text += getTableData(j_aryRecord[i]);
			}
			
			tab_text = tab_text + '</table></body></html>';
			var data_type = 'data:application/vnd.ms-excel';
			var ua = window.navigator.userAgent;
			var msie = ua.indexOf("MSIE ");
			var fileName = 'poleReport.xls';
			//Explorer 환경에서 다운로드
			if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
				if (window.navigator.msSaveBlob) {
					var blob = new Blob([tab_text], {
						type: "application/csv;charset=utf-8;"
					});
					navigator.msSaveBlob(blob, fileName);
				}
			} else {
				var blob2 = new Blob([tab_text], {
					type: "application/csv;charset=utf-8;"
				});
				var filename = fileName;
				var elem = window.document.createElement('a');
				elem.href = window.URL.createObjectURL(blob2);
				elem.download = filename;
				document.body.appendChild(elem);
				elem.click();
				document.body.removeChild(elem);
			}
		}
       	//============================
       	// 조회버튼을 클릭했다.
       	function FnSearchPaymentList()
       	{
			
         //  파라메터 리스트
       	// pg : 리스트를 보여풀 페이지 번호
       	// lpp: 한페이지에 보여줄 리스트 갯수
       	// stype : 검색조건 형식, 
     	//  	     name  :   sval 파라메터로 회원 이름 이 전달된다.
     	//  	     id       :   sval 파라메터로 회원 ID가 전달된다.
     	//  	     addr   :   sval 파라메터로 주소가 전달된다.
     	  	// dtand : true 경우 
     	//  	             dates로  등록일 시작, datee로  등록일 끝이  파라메터로 전달된다. 
     	//  	             dates >=  회원등록일  <= datee 조건으로 이용됨	
     	
     		j_nDispPageNum = 1;
     		resetListTable();  
			google.charts.setOnLoadCallback(drawChart);
						
       	}
		
		//yyyy-MM-dd HH:mm:ss 형식 문자열을 파싱한다
		//Date 개체를 리턴한다.
		function parseDate(sDate)
		{
			if(sDate == null) return null;
			// 그냥 전달해도 된다.  복잡하게 하지 말자
			// 아~~ 아이폰(사파리에서는 안된다..)
			// return new Date(sDate);
			// 파싱해서 하자	

			if(sDate.length < 19) return null;
			var nY = parseInt(sDate.substring(0,4));
			var nM = parseInt(sDate.substring(5,7));
			var nD = parseInt(sDate.substring(8,10));
			var nH = parseInt(sDate.substring(11,13));
			var nMin = parseInt(sDate.substring(14,16));
			var nS = parseInt(sDate.substring(17,19));

			var oDate = new Date(nY,nM-1,nD,nH,nMin,nS,0);
			return oDate;
		}
		
		function FnOnClickGraphPopup(strKey)
		{
			$("#mask").fadeTo("fast",.5);
		    $("#popup").fadeIn("fast");

			drawOneChart(strKey, true);
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
						
                 <h3 class="tit-list">용수제어스테이션 리포트</h3>
                    <div class="search-wrap" >
                       <ul>
								<li>
								 <div class="dist">제어 스테이션 목록</div>
									<div class="dist-cont">
									
										<div id='id_sensor_list' ></div>
                              </div>
									
								</li>
								
								<li class="period">
                                    <div class="dist">조회기간</div>
                                    <div class="dist-cont">
                                        <p>
                                            <input type="text"  id='id_date_search_start'  class="datepicker" readonly placeholder="날짜선택"> ~ <input type="text"  id='id_date_search_end' class="datepicker" readonly placeholder="날짜선택">
                                        </p>
                                        <p>
                                            <button id='id_set_search_date_0' class="btn-option on"  onClick='FnSetSearchDate(0);' >오늘</button>
                                            <button id='id_set_search_date_2' class="btn-option"  onClick='FnSetSearchDate(2);'>3일</button>
                                            <button id='id_set_search_date_6' class="btn-option"  onClick='FnSetSearchDate(6);'>7일</button>
                                            <button id='id_set_search_date_30' class="btn-option"  onClick='FnSetSearchDate(30);'>1개월</button>
                                            <button id='id_set_search_date_60' class="btn-option"  onClick='FnSetSearchDate(60);'>2개월</button>
                                            <button id='id_set_search_date_90' class="btn-option"  onClick='FnSetSearchDate(90);'>3개월</button>
                                        </p>                                                                   
								</li>
								
							</ul>

							<button class="btn-list btn-search blue"  onClick='FnSearchPaymentList()'>조회</button>
							<table >
								<tr>
									<th>
										<div id="fcurve_chart" style="width: 600px; height: 300px;" onClick='FnOnClickGraphPopup("f")'></div>
									</th>
									<th>
										<div id="ecurve_chart" style="width: 600px; height: 300px;" onClick='FnOnClickGraphPopup("e")'></div>
									</th>
								</tr>	
								<tr>
							</table>	
						</div>
                        <!-- // 조회영역 -->

						<div class="list-wrap">
						
							<div class="util-btn-wrap">
								<button class="btn-list excel" onClick='FnSaveToExcel();'>엑셀저장<i><img src="images/list/bg_down.png" alt=""></i></button>
							</div>
							
							<span class="list-count" >총 <em id="id_total_count">0</em>건이 조회되었습니다.</span>
							
                       <select name="" id="id_selectbox_count_per_page" class="">
								<option value="10">10건씩보기</option>
								<option value="20">20건씩보기</option>
							</select>
							
							<span class="list-count" >기간별 물 사용량 :  <em id="id_total_water">0</em>m³ / </span>
							<span class="list-count" >기간별 전력 사용량 :   <em id="id_total_elec">0</em>kWh</span>

							<div class="list-def">
								<div class="tbl-head">
									<table summary="">
										<caption>리스트head</caption>
										
										<colgroup>
											<col style="width:4%">
											<col style="width:4%">
											<col style="width:3%"> 
											<col style="width:3%"> 
											<col style="width:3%"> 
											<col style="width:3%">
											<col style="width:5%">
											<col style="width:5%">
											<col style="width:5%">
										</colgroup>

										<thead>
											<tr>
												<th>시작 시간</th>
												<th>종료 시간</th>
												<th>물 사용량</th>
												<th>전체 물 사용량</th>
												<th>전력 사용량</th>
												<th>전체 전력 사용량</th>
												<th>노면온도변화</th>
												<th>미세먼지변화</th>
												<th>초미세먼지변화</th>																								
											</tr>
										</thead>
									</table>
								</div>
								<!-- // table-head -->
								<div class="tbl-body">
									<table id='id_list_sensorRecord'>
										<caption>리스트body</caption>
											<colgroup>
												<col style="width:4%">
												<col style="width:4%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:5%">
												<col style="width:5%">
												<col style="width:5%">
											</colgroup>
										
										<tbody>
											<tr>
												<td>1266</td>
												<td>166</td>
												<td>2016-07-01</td>
												<td>F00200FF</td>
												<td>00000072</td>
												<td>1 or 0</td>
												<td>900</td>
												<td>0</td>
												<td>0</td>
											</tr>
										</tbody>
									</table>
								</div>
									<!-- // table-body -->

		
								<div id='id_page_navi' class="paging">
									<a href="" class="pg-first"></a>
									<a href="" class="pg-prev"></a>
									<a href="" class="on">1</a>
									<a href="">2</a>
									<a href="">3</a>
									<a href="">4</a>
									<a href="">5</a>
									<a href="">6</a>
									<a href="">7</a>
									<a href="">8</a>
									<a href="">9</a>
									<a href="">10</a>
									<a href="" class="pg-next"></a>
									<a href="" class="pg-last"></a>
								</div>
                                <!-- //페이징 -->

							</div>
                            <!-- // list-def -->
						</div>
             </div>          <!-- // 리스트 영역 -->
			 
				</div>
           
						<!-- // container -->
				
                                <!-- //페이징 -->

              
            <!-- // contents -->
 
            
            <!-- //content-wrap -->
		
		</div>
            <!-- //wrapper -->
		<footer>
                Copyright BLAKSTONE.CO.,LTD. All Right reserved.
        </footer>

		<!-- popup -->
		<div id="mask"></div>
			<div id="popup" style='position:fixed;top=110px;'>
			<div class="pop-head">
				<p>그래프 팝업</p>
				<span id="close-pop"></span>
			</div>
			<div class="pop-cont">
				<div id="POP_chart" style="width: 1250px; height: 600px;"></div>
			</div>
		</div>

	</body>
</html>
