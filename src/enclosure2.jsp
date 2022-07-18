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



String p_strExp = "";

if(p_strSTID != null)
{
	DaoSensor daoSensor = new DaoSensor();
	ArrayList<DaoSensorRecord> arySensor =  daoSensor.selectSensor(p_strSTID,true);
	ArrayList<String> arySIDs =  new ArrayList<String>();
	HashMap<String, JSONObject> mapSensor = new HashMap<String, JSONObject>();

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

JSONObject joSensor = null;
JSONArray p_jaSensor = new JSONArray();

joSensor = new JSONObject();
joSensor.put("key", "t");
joSensor.put("key2", "at");
joSensor.put("name", "온도");
joSensor.put("color", "#00FFFF");
joSensor.put("minValue", -40);
joSensor.put("maxValue", 60);
joSensor.put("unit", "°C");
joSensor.put("fixed", "#");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "h");
joSensor.put("name", "습도");
joSensor.put("color", "#0000FF");
joSensor.put("minValue", 0);
joSensor.put("maxValue", 100);
joSensor.put("unit", "％");
joSensor.put("fixed", "#");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "c");
joSensor.put("name", "이산화탄소(CO₂)");
joSensor.put("color", "#088A08");
joSensor.put("minValue", 400);
joSensor.put("maxValue", 1000);
joSensor.put("unit", "ppm");
joSensor.put("fixed", "#");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "p");
joSensor.put("key2", "ap");
joSensor.put("name", "미세먼지(PM₁₀)");
joSensor.put("color", "#04B404");
joSensor.put("minValue", 0);
joSensor.put("maxValue", 200);
//joSensor.put("scaleType", "log");
joSensor.put("unit", "μg/m³");
joSensor.put("fixed", "#");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "u");
joSensor.put("key2", "au");
joSensor.put("name", "초미세먼지(PM₂₅)");
joSensor.put("color", "#2EFE2E");
joSensor.put("minValue", 0);
joSensor.put("maxValue", 200);
//joSensor.put("scaleType", "log");
joSensor.put("unit", "μg/m³");
joSensor.put("fixed", "#");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "o");
joSensor.put("name", "소음");
joSensor.put("color", "#585858");
joSensor.put("minValue", 0);
joSensor.put("maxValue", 100);
joSensor.put("unit", "dBA");
joSensor.put("fixed", "#");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "i");
joSensor.put("name", "휘발성유기화합물");
joSensor.put("color", "#DF0174");
joSensor.put("minValue", 0);
joSensor.put("maxValue", 15);
joSensor.put("unit", "ppm");
joSensor.put("fixed", "#.###");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "n");
joSensor.put("key2", "an");
joSensor.put("name", "이산화질소(NO₂)");
joSensor.put("color", "#4B610B");
joSensor.put("minValue", 0);
joSensor.put("maxValue", 0.5);
joSensor.put("unit", "ppm");
joSensor.put("fixed", "#.###");
p_jaSensor.put(joSensor);

joSensor = new JSONObject();
joSensor.put("key", "s");
joSensor.put("key2", "as");
joSensor.put("name", "아황산가스(SO₂)");
joSensor.put("color", "#DBA901");
joSensor.put("minValue", 0);
joSensor.put("maxValue", 10);
joSensor.put("unit", "ppm");
joSensor.put("fixed", "#.###");
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

        <title>리스트</title>

        <link rel="stylesheet" href="css/normalize_custom.css">
        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <link rel="stylesheet" href="css/jquery.mCustomScrollbar.min.css">
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/index.css">
        <link rel="stylesheet" href="css/view.css?ver=5">
        <script src="js/jquery-1.12.1.min.js"></script>
        <script src="js/jquery-ui.min.js"></script>
        <script src="js/jquery.mCustomScrollbar.concat.min.js"></script>
         <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
        <script src="js/jquery.ajax-cross-origin.min.js"></script>
		<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
		
    	<script type="text/javascript">
		var j_jaSensor = <%=p_jaSensor.toString()%>;
		var j_jaSList = <%=p_jaSList.toString()%>;
		var bChk = false;
		var j_aryRecord = null;

			
			
      	$(function()
     	{
			
			<%
			out.println("FnSensorList();");
			%>

			FnGraphTable();

            $(".datepicker" ).datepicker({
            	dateFormat: "yy-mm-dd",
        		changeMonth: true,
        		dayNames: ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
        		dayNamesMin: ['월', '화', '수', '목', '금', '토', '일'],
        		monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
        		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],

            });
      		$(".tbl-body").mCustomScrollbar();	
      		
     		j_nDispPageNum = 1;
    		clearListTable();

    		// 기본 1개월 검색 수정해서 하루 30 ->1로 수정
    		FnSetSearchDate(30);
			google.charts.load('current', {'packages':['corechart']});
			google.charts.setOnLoadCallback(drawChart);
	
			$("#close-pop, #mask").click(function(){
				$("#mask").fadeOut("fast");
				$("#popup").fadeOut("fast",function(){});
		    });

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
       	 function resetListTable(nPage)
       	 {
			clearListTable();
			$('#id_total_count').text("" + j_aryRecord.length);
			var nRecordPerPage = $('#id_selectbox_count_per_page option:selected').val();
			for(var i = (nPage-1) * nRecordPerPage ; i < nPage * nRecordPerPage ; i ++)
			{
				if(i >= j_aryRecord.length) break;
				$('#id_list_sensorRecord > tbody:last').append(addListTable(j_aryRecord[i]));
			}
			$("#id_page_navi").html(getPagingStyle04(nPage, j_aryRecord.length));
       	 }

		function drawChart() 
		{
			var sSID =  $('#id_select_sensor').val();
			var sDateStart = $('#id_date_search_start').val();
      	  	var sDateEnd = $('#id_date_search_end').val();
			var bAndDate = $('#id_chkbox_date_and').is(':checked');
			var sParam = "sid=" + sSID + "&dates=" + sDateStart +  "&datee=" + sDateEnd ;

			j_sLastSearchParam = sParam;

			$.getJSON("./query/query_graph_1h.jsp",sParam,function(data,status){
			if(status == "success")
			{
				if(data.result	== "OK")
				{
					j_aryRecord = data.sensor; 
					var strSensorType = $('#id_select_sensor_type').val();
					if(strSensorType == "all")
					{
						for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
						{
							drawOneChart(j_jaSensor[nIndex].key, false);
						}
					}
					else
					{
						drawOneChart(strSensorType, false);
					}
					resetListTable(1);
				}
			}
			});
		}		

		function drawOneChart(strKey, bPopup)
		{
			var strName = "";
			var strColor = "";
			var strUnit = "";
			var nMin = 0;
			var nMax = 0;
			var strScaleType = "";
			var strKey2 = "";
			var strFixed = "";

			for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
			{
				if(j_jaSensor[nIndex].key == strKey)
				{
					strName = j_jaSensor[nIndex].name;
					strColor = j_jaSensor[nIndex].color;
					nMin = j_jaSensor[nIndex].minValue;
					nMax = j_jaSensor[nIndex].maxValue;
					strUnit = j_jaSensor[nIndex].unit;
					strScaleType = j_jaSensor[nIndex].scaleType;
					strKey2 = j_jaSensor[nIndex].key2;
					strFixed = j_jaSensor[nIndex].fixed;
				}
			}
			
			var dataGraph = new google.visualization.DataTable();
			dataGraph.addColumn('date', '시간');
			dataGraph.addColumn('number', strName);
			if(strKey2) dataGraph.addColumn('number', "air" + strName);

			var tempData = 0.0;
			var stdData = 0.0;
			var strExp = "";
			for(var i = j_aryRecord.length - 1 ; i >= 0 ; i--)
			{
				strExp = j_aryRecord[i][strKey];
				if(!strExp) continue;
				tempData = FnChartDataFilter(stdData, strExp);
				if(tempData > -999999)
				{
					if((strKey == "p") || (strKey == "u"))
					{
						if(tempData > nMax) tempData = nMax;
					}
					
					if(strKey2) dataGraph.addRows([[parseDate(j_aryRecord[i].sdate), tempData, j_aryRecord[i][strKey2]] ]);
					else dataGraph.addRows([[parseDate(j_aryRecord[i].sdate), tempData]]);
					stdData = tempData;
				}
				else
				{
					if(i == 0) dataGraph.addRows([[parseDate(j_aryRecord[i].sdate),  parseFloat(strExp)]]);
				}
			}

			var strHDateFormatType = "yyyy-MM-dd HH:mm:ss";
			var strVDateFormatType = strFixed + strUnit;

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

			optGraph['vAxis'] = {};
			optGraph['vAxis']['format'] = strVDateFormatType;
			optGraph['vAxis']['viewWindow'] = { max: nMax, min: nMin };
			if(strScaleType) optGraph['vAxis']['scaleType'] = strScaleType;


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

		function FnChartDataFilter(diff, exp)
		{
			var tempExp = parseFloat(exp);
			return Math.abs(tempExp);
			if(tempExp < -30000) return -999999;
			var tempDiff = diff - tempExp;

			if(Math.abs(tempDiff) > Math.abs(diff/20))
			{
				return Math.abs(tempExp);
			}
			else return -999999;
		}

		function FnGraphTable()
		{
			var sLine = "";
			var oHist = $('#id_grapg_table');	
			oHist.html(""); 	
			var strSensorType = $('#id_select_sensor_type').val();
			if(strSensorType == "all")
			{
				sLine = "<table><tr>";

				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					sLine += "<th><div id='" + j_jaSensor[nIndex].key + "curve_chart' style='width: 300px; height: 200px;' onClick='FnOnClickGraphPopup(\"" + j_jaSensor[nIndex].key + "\")'></div></th>";
					if(nIndex == 4) sLine += "</tr><tr>";
				}
				sLine += "</tr></table>";
			}
			else
			{
				sLine = "<div id='" + strSensorType + "curve_chart' style='width: 600px; height: 400px;' onClick='FnOnClickGraphPopup(\""+strSensorType+"\")'></div>";
			}
			oHist.append(sLine);
		}

		function FnSensorList()
		{
			var sLine = "";
			var oHist = $('#id_sensor_list');	
			oHist.html(""); 	

			sLine = "<div><select id='id_select_sensor' name='select_sensor'  style=width:100px;'>";

			if(j_jaSList.length>=0) 
			{	
				for(var i =0; i <  j_jaSList.length; i++)
				{
					if(j_jaSList[i].usegoal == 168)  
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

			sLine += "<select id='id_select_sensor_type' name='select_sensor_type'  style=width:100px;'>";
			sLine += "<option value='all' >모든센서</option>";
			
			for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
			{
				sLine += "<option value='" + j_jaSensor[nIndex].key + "'>" + j_jaSensor[nIndex].name + "</option>";
			}
			sLine += "</select>";

			sLine += "</div>"
			oHist.append(sLine);

			return ;
		}
       	
       	 function clearListTable()
       	 {   // table 은 thead, tbody 구분되어 만들어져 있어야 함

			//행 설절 초기화
			$('#id_list_table_head >colgroup:last').remove();
			$("#id_list_table_head >thead >tr:last").remove();
			$('#id_list_sensorRecord >colgroup:last').remove();

			//옵션에 맞게 다시 생성
			var strSensorType = $('#id_select_sensor_type').val();
			//일단 날짜
			var tempCol = "<colgroup><col style='width:8%'>";
			var tempTh = "<tr><th>날짜</th>";

			if(strSensorType == "all")
			{
				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					tempCol += "<col style='width:3%'>";
					tempTh += "<th>"+j_jaSensor[nIndex].name+"</th>";
					if(j_jaSensor[nIndex].key2)
					{
						tempCol += "<col style='width:3%'>";
						tempTh += "<th>air"+j_jaSensor[nIndex].name+"</th>";
					}
				}
			}
			else
			{
				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					if(strSensorType == j_jaSensor[nIndex].key)
					{
						tempCol += "<col style='width:3%'>";
						tempTh += "<th>"+j_jaSensor[nIndex].name+"</th>";
						if(j_jaSensor[nIndex].key2)
						{
							tempCol += "<col style='width:3%'>";
							tempTh += "<th>air"+j_jaSensor[nIndex].name+"</th>";
						}
						break;
					}
				}
			}
			tempCol += "</colgroup>";
			tempTh += "</tr>";

			$('#id_list_table_head').append(tempCol);
			$("#id_list_table_head >thead:last").append(tempTh);
			$('#id_list_sensorRecord').append(tempCol);


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
       	 
       	 function addListTable(jM)
       	 {  
			var strSensorType = $('#id_select_sensor_type').val();
			var tr_html = "";
			var strTemphtml = "";
			var fExpData = 0.0;
			if(strSensorType == "all")
			{
       			tr_html = "<tr><td>" + jM.sdate + "</td>";
				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					fExpData = Math.abs(parseFloat(jM[j_jaSensor[nIndex].key]));
					if(j_jaSensor[nIndex].fixed == "#") fExpData = fExpData.toFixed(0);
					else  fExpData = fExpData.toFixed(3);

					strTemphtml = "<td>" + fExpData + j_jaSensor[nIndex].unit + "</td>";
					tr_html += strTemphtml;
					if(j_jaSensor[nIndex].key2)
					{
						fExpData = Math.abs(parseFloat(jM[j_jaSensor[nIndex].key2]));
						if(j_jaSensor[nIndex].fixed == "#") fExpData = fExpData.toFixed(0);
						else  fExpData = fExpData.toFixed(3);

						strTemphtml = "<td>" + fExpData + j_jaSensor[nIndex].unit + "</td>";
						tr_html += strTemphtml;
					}
				}
			 }
			 else
			 {
				var strUnit = "";
				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					if(j_jaSensor[nIndex].key == strSensorType)
					{
						fExpData = Math.abs(parseFloat(jM[j_jaSensor[nIndex].key]));
						if(j_jaSensor[nIndex].fixed == "#") fExpData = fExpData.toFixed(0);
						else  fExpData = fExpData.toFixed(3);

						strTemphtml = "<td>" + fExpData + j_jaSensor[nIndex].unit + "</td>";
						tr_html = strTemphtml;
						if(j_jaSensor[nIndex].key2)
						{
							fExpData = Math.abs(parseFloat(jM[j_jaSensor[nIndex].key2]));
							if(j_jaSensor[nIndex].fixed == "#") fExpData = fExpData.toFixed(0);
							else  fExpData = fExpData.toFixed(3);

							strTemphtml = "<td>" + fExpData + j_jaSensor[nIndex].unit + "</td>";
							tr_html += strTemphtml;
						}
					}
				}
			 }
			return tr_html;
       	 }
       	 //=================================
       	//  페이지 리스트 Navi관련 
       	function Pager_SelectPage(nPage)
       	{
       		j_nDispPageNum = nPage;
       		resetListTable(nPage);
       	}
       	//처음으로
       	function Pager_FirstPage()
       	{
       		j_nDispPageNum = 1;
       		resetListTable(1);
       	}

       	//끝으로
       	function Pager_LastPage(nTotalPage)
       	{
       		j_nDispPageNum = nTotalPage;
       		resetListTable(nTotalPage);
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
       		
       		$('#id_date_search_start').val(dateStart.format('yyyy-MM-dd'));
       		$('#id_date_search_end').val(dateToday.format('yyyy-MM-dd'));
    		$('#id_chkbox_date_and').attr('checked',true);	
       	}

       	// 등록일 and 조건 검색 책크박스 클릭
       	function FnSearchDateAnd()
       	{
       		
       		var elmtChk = $('#id_chkbox_date_and');
       		if(elmtChk.is(":checked"))
       		{
       			var sDateS = $('#id_date_search_start').val();
       			var sDateE = $('#id_date_search_end').val();
       			if(sDateS =="" || sDateE == "")
       			{
       				FnSetSearchDate(0);
       			}
       		}
       	}
       	
       	//============================ 	
       	// 엘셀 저장
       	function FnSaveToExcel()
       	{
			var  sStype = $('#id_select_sensor_type').val();
			location.href='./proc/down_enclosure2.jsp?' + j_sLastSearchParam + '&sensorType=' + sStype;
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
			FnGraphTable();
			//google.charts.setOnLoadCallback(drawChart);
			drawChart();
						
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
			 <header style="background: url('./images/header.png') center 0 no-repeat; background-size:100%; background-color: #00c1ff;">
					<img  src='./images/<%=p_strLogo%>'  height='100px'  style='width:220px;  float:left;'>
                <div  style="float:left;  width:80%;  font-size:230%; margin:25px 0px 0px 50px;"><%=p_strLocation%></div>
					<!--<div><button  style="float:left;  width:5%; margin:40px 0px 0px 0px; white: gold; background:gray; font-size:1em;"onClick="window.open('sensorCheck.jsp', '_blank', 'width=550 height=500')">Cheak</button></div> --> <!-- onClick안에는 임시코드 -->
            </header>  	 	
                      <div class="content-wrap">
           	<jsp:include page="./left_menu.jsp"></jsp:include>
			          	
                <div id="contents">
				
              
             <div class="container" >
						
                 <h3 class="tit-list">함체 정보</h3>
                    <div class="search-wrap" >
                       <ul>
								<li>
								 <div class="dist">함체 선택</div>
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
                                        </p>                                                                   
								</li>
								
							</ul>

							<button class="btn-list btn-search blue"  onClick='FnSearchPaymentList()'>조회</button>
							<div id='id_grapg_table' ></div>

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
							
							<div class="list-def">
								<div class="tbl-head">
									<table id='id_list_table_head'>
										<caption>리스트head</caption>
										
										<colgroup>
											<col style="width:8%">
											<col style="width:3%">
											<col style="width:3%">
											<col style="width:3%">       
											<col style="width:3%"> 
											<col style="width:3%">
											<col style="width:3%">
											<col style="width:5%"> 
											<col style="width:3%"> 
											<col style="width:3%"> 	
											<col style="width:3%">											
										</colgroup>

										<thead>
											<tr>
												<th>날짜</th>
												<th>온도</th>
												<th>습도</th>
												<th>이산화탄소</th>
												<th>미세먼지</th>
												<th>초미세먼지</th>
												<th>소음</th>
												<th>휘발성유기화합물</th>
												<th>질소산화물</th>
												<th>황산화물</th>
												<th>배터리</th>
											</tr>
										</thead>
									</table>
								</div>
								<!-- // table-head -->
								<div class="tbl-body">
									<table id='id_list_sensorRecord'>
										<caption>리스트body</caption>
											<colgroup>
												<col style="width:8%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
												<col style="width:3%">
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
