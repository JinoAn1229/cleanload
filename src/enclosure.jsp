<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoSite"%>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord"%>
<%@ page import="wguard.dao.DaoSensor"%>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord"%>
<%@ page import="wguard.dao.DaoViewSensorList"%>
<%@ page import="wguard.dao.DaoViewSensorList.DaoViewSensorListRecord"%>
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

JSONObject joS = null;
JSONArray p_jaSList = new JSONArray();

String p_strSTID = "";
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
		joS.put("viewsensor",rSR.m_nViewSensorList);
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


	float p_fTempAlarm = 0.0f;
	float p_fDustAlarm = 0.0f;
	
	String[] astrSensorExp= EtcUtils.splitString(p_strExp,"=\\",true,false);
	if(astrSensorExp.length > 1)
	{
		for(int i=0; i<astrSensorExp.length; i+=2)
		{
			if(i+1>astrSensorExp.length)
				break;
			
			if(astrSensorExp[i].equals("d"))
			{
				p_fTempAlarm =  Float.parseFloat(astrSensorExp[i+1]);
			}
			else if(astrSensorExp[i].equals("u"))
			{
				p_fDustAlarm =  Float.parseFloat(astrSensorExp[i+1]);
			}
		}
	}


JSONObject joSensor = null;
JSONArray p_jaSensor = new JSONArray();

DaoViewSensorList daoViewSensorList = new DaoViewSensorList();
ArrayList<DaoViewSensorListRecord> aryViewSensor =  daoViewSensorList.getAllViewSensorList(true);

for(DaoViewSensorListRecord rVSL : aryViewSensor)
{
	joSensor = new JSONObject();
	joSensor.put("key", rVSL.m_strKey);
	joSensor.put("keyindex", rVSL.m_nKeyIndex);
	joSensor.put("name", rVSL.m_strName);
	joSensor.put("color", rVSL.m_strColor);
	joSensor.put("minValue", rVSL.m_fMinValue);
	joSensor.put("maxValue", rVSL.m_fMaxValue);
	joSensor.put("unit", rVSL.m_strUnit);
	
	if(rVSL.m_strKey.equals("d"))joSensor.put("alram", p_fTempAlarm); 
	else if(rVSL.m_strKey.equals("u"))joSensor.put("alram", p_fDustAlarm); 
	
	p_jaSensor.put(joSensor);
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
		var j_jaSList = <%=p_jaSList.toString()%>;
		var bChk = false;
		var jaSt = null;
			
			
      	$(function()
     	{
			
			<%
			out.println("FnSensorList();");
			%>

			FnGraphTable();

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

    		// 기본 1개월 검색 수정해서 하루 30 ->1로 수정
    		FnSetSearchDate(30);
    		//resetListTable(true);수정
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
       	 function resetListTable(nPage)//수정
       	 {
			clearListTable();
			clearListTable();
			$('#id_total_count').text("" + jaSt.length);
			var nRecordPerPage = $('#id_selectbox_count_per_page option:selected').val();
			for(var i = (nPage-1) * nRecordPerPage ; i < nPage * nRecordPerPage ; i++)
			{
				if(i >= jaSt.length) break;
				$('#id_list_sensorRecord > tbody:last').append(addListTable(jaSt[i]));
			}
			$("#id_page_navi").html(getPagingStyle04(nPage, jaSt.length));
       	 }
		 

		function drawChart() 
		{
			var nSensorIndex = $('#id_select_sensor').val();
			var sSID = j_jaSList[nSensorIndex].sid;
			var sDateStart = $('#id_date_search_start').val();
      	  	var sDateEnd = $('#id_date_search_end').val();
			var bAndDate = $('#id_chkbox_date_and').is(':checked');
			var sParam = "sid=" + sSID + "&dates=" + sDateStart +  "&datee=" + sDateEnd ;

			//시간 설정(Hours)을 위한 값 없으면 시간을 무시한다
			sParam += "&time=hours";
			j_sLastSearchParam = sParam;//수정

			$.getJSON("./query/query_graph.jsp",sParam,function(data,status){
			if(status == "success")
			{
				if(data.result	== "OK")
				{
					jaSt = data.sensor; 
					var strSensorType = $('#id_select_sensor_type').val();
					if(strSensorType == "all")
					{
						for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
						{
							if( (j_jaSensor[nIndex].keyindex & j_jaSList[nSensorIndex].viewsensor) == j_jaSensor[nIndex].keyindex)
								drawOneChart(j_jaSensor[nIndex].key, false);
						}
					}
					else
					{
						drawOneChart(strSensorType, false);
					}
					resetListTable(1); //수정
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
				}
			}
			
			var dataGraph = new google.visualization.DataTable();
			dataGraph.addColumn('date', '시간');
			dataGraph.addColumn('number', strName);

			var tempData = 0.0;
			var stdData = 0.0;
			var strExp = "";
			for(var i = jaSt.length - 1 ; i >= 0 ; i--)
			{
				strExp = jaSt[i].exp[strKey];
				tempData = FnChartDataFilter(stdData, strExp);
				if(tempData > -999999)
				{
					if((strKey == "p") || (strKey == "u"))
					{
						if(tempData > nMax) tempData = nMax;
					}
					
					dataGraph.addRows([[parseDate(jaSt[i].sdate), tempData]]);
					stdData = tempData;
				}
				else
				{
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

			optGraph['vAxis'] = {};
			optGraph['vAxis']['format'] = strVDateFormatType;
			if( (nMax < 999999) && (nMin > -999999))
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

/*				if(strKey == "t") chart = new google.visualization.LineChart(document.getElementById('tcurve_chart'));
				if(strKey == "h") chart = new google.visualization.LineChart(document.getElementById('hcurve_chart'));
				if(strKey == "c") chart = new google.visualization.LineChart(document.getElementById('ccurve_chart'));
				if(strKey == "p") chart = new google.visualization.LineChart(document.getElementById('pcurve_chart'));
				if(strKey == "u") chart = new google.visualization.LineChart(document.getElementById('ucurve_chart'));
				if(strKey == "o") chart = new google.visualization.LineChart(document.getElementById('ocurve_chart'));
				if(strKey == "i") chart = new google.visualization.LineChart(document.getElementById('icurve_chart'));
				if(strKey == "n") chart = new google.visualization.LineChart(document.getElementById('ncurve_chart'));
				if(strKey == "s") chart = new google.visualization.LineChart(document.getElementById('scurve_chart'));
*/
			}

			chart.draw(dataGraph, optGraph);
		}

		function FnChartDataFilter(diff, exp)
		{
			var tempExp = parseFloat(exp);
			if(tempExp < -10000) return -999999;
			if(tempExp > 10000) return -999999;
			var tempDiff = diff - tempExp;

			if(Math.abs(tempDiff) > Math.abs(diff/20))
			{
				return tempExp;
			}
			else return -999999;
		}

		function FnGraphTable()
		{
			var sLine = "";
			var oHist = $('#id_grapg_table');	
			oHist.html(""); 	
			var nSensorIndex = $('#id_select_sensor').val();
			var strSensorType = $('#id_select_sensor_type').val();
			if(strSensorType == "all")
			{
				sLine = "<table><tr>";
				var nChartCount = 0;
				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					if( (j_jaSensor[nIndex].keyindex & j_jaSList[nSensorIndex].viewsensor) == j_jaSensor[nIndex].keyindex)
					{
						sLine += "<th><div id='" + j_jaSensor[nIndex].key + "curve_chart' style='width: 300px; height: 200px;' onClick='FnOnClickGraphPopup(\"" + j_jaSensor[nIndex].key + "\")'></div></th>";
						nChartCount++;
						if(nChartCount == 5) sLine += "</tr><tr>";
					}
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

			sLine = "<div><select id='id_select_sensor' name='select_sensor'  style=width:100px;' onchange='SensorChange(this)'>";			
			var nSelectIndex = 0;
			
			if(j_jaSList.length>=0) 
			{	
				for(var i =0; i <  j_jaSList.length; i++)
				{
					if(j_jaSList[i].usegoal == 168)  
					{	
						if(nSelectIndex == 0) nSelectIndex = i;
						if( j_jaSList[i].sid == "<%=strSID%>") 
						{
							sLine += "<option value='" + i + "' selected='selected'>" + j_jaSList[i].sname + "</option>";
							nSelectIndex = i;
						}
						else									
							sLine += "<option value='" + i + "'>" + j_jaSList[i].sname + "</option>";
						}
					}
				}
			sLine += "</select>";

			sLine += "<b>센서목록</b>&nbsp&nbsp<select id='id_select_sensor_type' name='select_sensor_type'  float:left;  width:30%;'>";
			sLine += "<option value='all' >모든센서</option>";
			
			for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
			{
				if( (j_jaSensor[nIndex].keyindex & j_jaSList[nSelectIndex].viewsensor) == j_jaSensor[nIndex].keyindex)
					sLine += "<option value='" + j_jaSensor[nIndex].key + "'>" + j_jaSensor[nIndex].name + "</option>";
			}
			sLine += "</select>";

			sLine += "</div>"
			oHist.append(sLine);

			return ;
		}
       	
		function SensorChange(seleteSensor)
		{
			var nViewSensor = j_jaSList[seleteSensor.value].viewsensor;

			var sLine = "";
			var oHist = $('#id_select_sensor_type');	
			
			sLine = "<select id='id_select_sensor_type' name='select_sensor_type'  float:left;  width:30%;'>";
			sLine += "<option value='all' >모든센서</option>";
			
			for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
			{
				if( (j_jaSensor[nIndex].keyindex & nViewSensor) == j_jaSensor[nIndex].keyindex)
					sLine += "<option value='" + j_jaSensor[nIndex].key + "'>" + j_jaSensor[nIndex].name + "</option>";
			}
			sLine += "</select>";

			oHist.append(sLine);
		}

       	 function clearListTable()
       	 {   // table 은 thead, tbody 구분되어 만들어져 있어야 함

			//행 설절 초기화
			$('#id_list_table_head >colgroup:last').remove();
			$("#id_list_table_head >thead >tr:last").remove();
			$('#id_list_sensorRecord >colgroup:last').remove();

			//옵션에 맞게 다시 생성
			var nSensorIndex = $('#id_select_sensor').val();
			var strSensorType = $('#id_select_sensor_type').val();
			//일단 날짜
			var tempCol = "<colgroup><col style='width:8%'>";
			var tempTh = "<tr><th>날짜</th>";

			if(strSensorType == "all")
			{
				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					if( (j_jaSensor[nIndex].keyindex & j_jaSList[nSensorIndex].viewsensor) == j_jaSensor[nIndex].keyindex)
					{
						tempCol += "<col style='width:3%'>";
						tempTh += "<th>"+j_jaSensor[nIndex].name+"</th>";
					}
				}
				//tempCol += "<col style='width:3%'>";
				//tempTh += "<th></th>";
			}
			else
			{
				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					if(strSensorType == j_jaSensor[nIndex].key)
					{
						tempCol += "<col style='width:3%'>";
						tempTh += "<th>"+j_jaSensor[nIndex].name+"</th>";
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
       	 
       	function getTableData(jM)
       	{  
			var strSensorType = $('#id_select_sensor_type').val();
			var nSensorIndex = $('#id_select_sensor').val();
			var tr_html = "";
			var strTemphtml = "";
			var fExpData = 0.0;
			var bCheckAlram = false;
			tr_html = "<tr><td>" + jM.sdate + "</td>";
			if(strSensorType == "all")
			{
				for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
				{
					if( (j_jaSensor[nIndex].keyindex & j_jaSList[nSensorIndex].viewsensor) == j_jaSensor[nIndex].keyindex)
					{
						fExpData = parseFloat(jM.exp[j_jaSensor[nIndex].key]);
					    if(j_jaSensor[nIndex].alram != null)
						{
							if(jM.alarm[j_jaSensor[nIndex].key] <= fExpData)
							strTemphtml = "<td><font color=red>" + fExpData + j_jaSensor[nIndex].unit + "</font></td>";
						
							else 
							strTemphtml = "<td>" + fExpData + j_jaSensor[nIndex].unit + "</td>";
						}
						else 
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
						fExpData = parseFloat(jM.exp[j_jaSensor[nIndex].key]);
					    if(j_jaSensor[nIndex].alram != null)
						{
							if(j_jaSensor[nIndex].alram >= fExpData)
							strTemphtml = "<td><font color=red>" + fExpData + j_jaSensor[nIndex].unit + "</font></td>";
						
							else 
							strTemphtml = "<td>" + fExpData + j_jaSensor[nIndex].unit + "</td>";
						}
						else 
							strTemphtml = "<td>" + fExpData + j_jaSensor[nIndex].unit + "</td>";
					
						tr_html += strTemphtml;
					}
				}
			}			
   			tr_html += "</tr>";	  
       		return tr_html; //수정
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
		
		//한번에 가져온 쿼리 분리
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
			//var  sStype = $('#id_select_sensor_type').val();
      		//location.href='./proc/down_enclosure.jsp?' + j_sLastSearchParam + '&sensorType=' + sStype;
			fnExcelReport();
       	}
		
		//엑셀
		function fnExcelReport() {
			var nSensorIndex = $('#id_select_sensor').val();
			var tab_head = "<th>날짜</th>";
			var tab_text = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
			tab_text = tab_text + '<head><meta http-equiv="content-type" content="application/vnd.ms-excel; charset=UTF-8">';
			tab_text = tab_text + '<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>'
			tab_text = tab_text + '<x:Name>enclosure Sheet</x:Name>';
			tab_text = tab_text + '<x:WorksheetOptions><x:Panes></x:Panes></x:WorksheetOptions></x:ExcelWorksheet>';
			tab_text = tab_text + '</x:ExcelWorksheets></x:ExcelWorkbook></xml></head><body>';
			tab_text = tab_text + "<table border='1px'>";
        
			for(var nIndex = 0; nIndex < j_jaSensor.length ; nIndex++)
			{
				if( (j_jaSensor[nIndex].keyindex & j_jaSList[nSensorIndex].viewsensor) == j_jaSensor[nIndex].keyindex)
				tab_head += '<th>' + j_jaSensor[nIndex].name + '</th>';   //<th>노면온도</th><th>온도</th><th>습도</th><th>미세먼지</th><th>초미세먼지</th><th>이산화탄소</th><th>이산화질소</th><th>아황산가스</th>';
			}
			tab_text += '</tr>' + tab_head + '</tr>';
			for(var i = 0; i < jaSt.length; i ++)
			{
				tab_text += getTableData(jaSt[i]);
			}
			
			tab_text = tab_text + '</table></body></html>';
			var data_type = 'data:application/vnd.ms-excel';
			var ua = window.navigator.userAgent;
			var msie = ua.indexOf("MSIE ");
			var fileName = 'enclosure.xls';
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
     		resetListTable(true);  
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
			 <jsp:include page="./header.jsp"></jsp:include>	 	
			<div class="content-wrap">
				<jsp:include page="./left_menu.jsp"></jsp:include>
			          	
                <div id="contents">
				
              
             <div class="container" >
						
                 <h3 class="tit-list">환경 스테이션 정보</h3>
                    <div class="search-wrap" >
                       <ul>
								<li>
								 <div class="dist">측정스테이션 목록</div>
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
                                           <button id='id_set_search_date_0' class="btn-option on"  onClick='FnSetSearchDate(0);' ><font size="1px">오늘</font></button>
                                            <button id='id_set_search_date_2' class="btn-option"  onClick='FnSetSearchDate(2);'><font size="1px">3일</font></button>
                                            <button id='id_set_search_date_6' class="btn-option"  onClick='FnSetSearchDate(6);'><font size="1px">7일</font></button>
                                            <button id='id_set_search_date_30' class="btn-option"  onClick='FnSetSearchDate(30);'><font size="1px">1개월</font></button>
                                            <button id='id_set_search_date_60' class="btn-option"  onClick='FnSetSearchDate(60);'><font size="1px">2개월</font></button>
                                            <button id='id_set_search_date_90' class="btn-option"  onClick='FnSetSearchDate(90);'><font size="1px">3개월</font></button>
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
												<th>질소산화물</th>
												<th>황산화물</th>
												
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
