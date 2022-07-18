<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="java.util.Date"%>
<%@ page import="wguard.dao.DaoUser"%>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord"%>
<%@ page import="wguard.dao.DaoSite"%>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord"%>
<%@ page import="wguard.dao.DaoFamily" %>  
<%@ page import="wguard.dao.DaoFamily.DaoFamilyRecord" %>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Locale"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="common.util.UTF8ResourceBundle"%> 

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
        <script src="js/jquery-1.12.1.min.js"></script>
        <script src="js/jquery-ui.min.js"></script>
        <script src="js/jquery.mCustomScrollbar.concat.min.js"></script>
        <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
         
    	<script>
      
      	$(function()
     	{
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
    			
    		// 기본 일주 검색
    		FnSetSearchDate(6);
    		resetListTable();
			FnSetLeftMenu();
     		
     	});
         
       	var	j_nDispPageNum = 1;  // 현재 페이지 번호(1base)
       	var j_sLastSearchParam = ""; // 마지막 조회 조건문 
       	//==================================
       	// 목록 갱신
       	 function resetListTable()
       	 {
       		var nListPerPage = $('#id_selectbox_count_per_page option:selected').val();
       		
       		// lpp 페이지에 표시할 리스트의 최대 갯수(List Per Page))
       		// pg 현재 페이지 번호(1base)
       		var sPageParam = "pg=" + j_nDispPageNum +"&lpp=" + nListPerPage;
      		var sSearchValParam = "";
      		var sSearchDateParam = "";
      		
      		var sSearchParam = "";

      		var sSearchValue = '<%=p_strUserID%>';
      		var bAndDate = true;
      		var bSearchValue = checkValue(sSearchValue);
      		if(!bSearchValue && !bAndDate)
    		{
      			alert('검색 조건 부족1');
      			return; 		
    		}
      		if(bAndDate)
      		{
      	  		var sDateStart = $('#id_date_search_start').val();
      	  		var sDateEnd = $('#id_date_search_end').val();
      			if(!checkValue(sDateStart) || !checkValue(sDateEnd))
      			{
      	  			alert('검색 조건 부족2');
      	  			return; 		
      			}
      			sSearchDateParam = "&dtand=true&dates=" + sDateStart + "&datee=" + sDateEnd;
      		}
      		
      		if(bSearchValue)
      		{
          		var sSearchType = "id";
          	  	var sSearchValue = '<%=p_strUserID%>';
      			sSearchValParam = "stype=" + sSearchType + "&sval=" + sSearchValue;
      		}
      		else
      			sSearchValParam = "stype=none";
      		
      		sSearchParam = 	sSearchValParam + sSearchDateParam;

       		// 화일 저장을 위해 마지작 조회 조건문 저장
       		j_sLastSearchParam = sSearchParam;
       		
       		var strQuery = "./query/query_pushHistory_list.jsp?" + sPageParam + "&" + sSearchParam;

       		$.getJSON(strQuery, function(root,status,xhr){
       			if(status == "success")
       			{
        			clearListTable();
        			
        			if(root.result =="OK")
        			{
          			var aryRecord =  root.members;
          			$('#id_total_count').text("" + root.tot_count);
         			for(var i = 0; i < aryRecord.length; i ++)
         			{
         				objItem = aryRecord[i];
         				addListTable(objItem);
         		 	}
         			// 페이지 네비게이션 
         			$("#id_page_navi").html(root.PageNavi);
        			}
       			}
       			else //if(status == "notmodified" || status == "error" || status == "timeout" || status == "parsererror")
       			{
       				alert('[fail] status:'+status+ ' / message:' + xhr.responseText); 	
       			}
       	    }); 
       	 }
       	
       	
       	 function clearListTable()
       	 {   // table 은 thead, tbody 구분되어 만들어져 있어야 함
       		 var nCount = $("#id_list_push_history >tbody >tr").length;
       		 for(var i = 0; i < nCount ; i ++)
       		 {  
       			 $('#id_list_push_history > tbody:last > tr:last').remove();
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
/*
 <tr>
      <td>1266</td>
      <td>홍길동</td>
      <td>aaa@aaa.com</td>
      <td>2016-07-01 09:50 </td>
      <td>경기도 부천시 XXX구 XXX로 888 (XX1동) 151-85 </td>
      <td>우리집 현관 1 열렸습니다. </td>
</tr>
*/
       	    var tr_html = "<tr>"
       	                  + "<td>" +  jM.no + "</td>"
       	                  + "<td>" + jM.name +"</td>"
       	                  + "<td>" + jM.id + "</td>"
       	                  + "<td>" + jM.date + "</td>"
     	            	  + "<td>" + jM.msg + "</td>"
       				  + "</tr>";
   				  
       		$('#id_list_push_history > tbody:last').append(tr_html);
       	 }
       	 //=================================
       	//  페이지 리스트 Navi관련 
       	function Pager_SelectPage(nPage)
       	{
       		j_nDispPageNum = nPage;
       		resetListTable();
       	}
       	//처음으로
       	function Pager_FirstPage()
       	{
       		j_nDispPageNum = 1;
       		resetListTable();
       	}

       	//끝으로
       	function Pager_LastPage(nTotalPage)
       	{
       		j_nDispPageNum = nTotalPage;
       		resetListTable();
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

			if(nDay == 0 || nDay == 2 || nDay == 6 || nDay == 30 )
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
       		location.href='./proc/down_pushHistory_list.jsp?' + j_sLastSearchParam;
       	}
       	
       	
       	//============================
       	// 조회버튼을 클릭했다.
       	function FnSearchPushHistoryList()
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
       	}

		function FnSetLeftMenu()
       	{
			if(<%=p_bManager%>)
			{
				var sLine = '<ul><li><a href="./SensorStRecord.jsp" class="navi_link">센서상태</a></li></ul>'
				$('#lnb').append(sLine);
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
                        <h3 class="tit-list">알람이력보기</h3>
						<div class="search-wrap">
                            <ul>                               
                                <li class="period">
                                    <div class="dist">등록일 조회</div>
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
                                        
                                    </div>
                                </li>
                            </ul>

                            <button class="btn-list btn-search blue"  onClick='FnSearchPushHistoryList()'>조회</button>
                        </div>
                        <!-- // 조회영역 -->

                        <div class="list-wrap">
                            <span class="list-count" ><em id="id_total_count">0</em>건 조회되었습니다.</span>
                            <select name="" id="id_selectbox_count_per_page" class="">
                                <option value="10">10건씩보기</option>
                                <option value="20">20건씩보기</option>
                            </select>

							<!-- 상단버튼 -->
                            <div class="util-btn-wrap">
                                <button class="btn-list excel" onClick='FnSaveToExcel();'>엑셀<i><img src="images/list/bg_down.png" alt=""></i></button>
                            </div>
							<!--// 상단버튼 -->


                            <div class="list-def">
                                <div class="tbl-head">
                                    <table summary="">
                                        <caption>리스트head</caption>
                                        <colgroup>
                                           <col style="width:5%">
                                            <col style="width:8%">
                                            <col style="width:15%">
                                            <col style="width:15%">
                                            <col style="width:30%">
                                        </colgroup>

                                        <thead>
                                            <tr>
                                                <th>번호</th>
                                                <th>이름</th>
                                                <th>아이디(이메일)</th>
                                                <th>발송일시</th>
                                                <th>메세지</th>
                                            </tr>
                                        </thead>
                                    </table>
                                </div>
								<!-- // table-head -->
                                <div class="tbl-body">
                                    <table id='id_list_push_history'>
                                        <caption>리스트body</caption>
                                        <colgroup>
                                            <col style="width:5%">
                                            <col style="width:8%">
                                            <col style="width:15%">
                                            <col style="width:15%">
                                            <col style="width:30%">
                                        </colgroup>
                                        <tbody>
                                            <tr>
                                                <td>1266</td>
                                                <td>홍길동</td>
                                                <td>aaa@aaa.com</td>
                                                <td>2016-07-01 09:50 </td>
                                                <td>경기도 부천시 XXX구 XXX로 888 (XX1동) 151-85 </td>
                                                <td>우리집 현관 1 열렸습니다. </td>
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
                        <!-- // 리스트 영역 -->
						
                    </div>
                    <!-- // container -->


                </div>
                <!-- // contents -->


            </div>
            <!-- //content-wrap -->

            <footer>
                Copyright BLAKSTONE.CO.,LTD. All Right reserved.
            </footer>
            <!-- // footer -->

        </div>
        <!-- //wrapper -->



    </body>
</html>

