<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.dao.DaoUser"%>
<%@ page import="wguard.dao.DaoUser.DaoUserRecord"%> 
<%@ page import="wguard.dao.DaoGuestHistory"%>
<%@ page import="wguard.dao.DaoGuestHistory.DaoGuestHistoryRecord"%> 


<%!
public DaoUser.DaoUserRecord checkLogin(String id, String pw) 
{
	DaoUser DaoUser = new DaoUser();
	return DaoUser.checkLogin(id,pw);
 }
%>  

<%
HttpSession loginsession = request.getSession(true); // true : 없으면 세션 새로 만듦

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-------------------------------------

String p_strOKResponse = "sensorList.jsp";
String strID = EtcUtils.NullS(request.getParameter("id"));
String strPW = EtcUtils.NullS(request.getParameter("pw"));


DaoUser.DaoUserRecord rUser = null;
boolean p_bLogin = false;
try
{
	rUser = checkLogin(strID,strPW);
	if (rUser != null )
	{
		loginsession.setAttribute("ID", strID);
		loginsession.setAttribute("NAME",rUser.m_strName);
		p_bLogin = true;
	}
}
catch(Exception e)
{
}

if(p_bLogin)
{
	response.sendRedirect(p_strOKResponse);
	return ;
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

        <title>리스트</title>

        <link rel="stylesheet" href="css/normalize_custom.css">
        <link rel="stylesheet" href="css/jquery-ui.min.css">
        <link rel="stylesheet" href="css/jquery.mCustomScrollbar.min.css">
        <link rel="stylesheet" href="css/common.css">
        <link rel="stylesheet" href="css/index.css">
        <script src="js/jquery-1.12.1.min.js"></script>
        <script src="js/basic_utils.js"></script>
        <script src="js/date_util.js"></script>
     
        <script>

     	$(function()
     	{
     		$("#id_PW").keyup(function(e) {
     			if(e.keyCode == 13)
     				FnLoginManager();
     			});	
				
     	});
         

     	function FnLoginManager()
     	{
     		var sID = $('#id_ID').val();
     		var sPW = $('#id_PW').val();
     		
   		    if(!checkValue(sID) || !checkValue(sPW))
   			{
   				alert("값을 입력해야 합니다.");
   				return ;
   			}
   			var sData = "id=" + sID + "&pw=" + sPW;
   			$.get("./query/query_login.jsp",sData, function(data, status)
   			{
   				if(status=="success")
   				{
   					var sResponse = "";
   					if(data != null)
   						sResponse = data.trim();
   					if(sResponse.indexOf("OK") >= 0)
   					{
   						location.href="<%=p_strOKResponse%>";
   					}
   					else
   					{
   						alert("ID 또는 PW가 다릅니다.")	
   					}			
   				}
   		  });
		  
     	}
       	</script>  
        
   </head>

     <body>
         <div style='height:100%;min-width:500px;width:100%;'>
			 <header style="background: url('./images/header.png') left 0 no-repeat; background-size:contain; background-color:#4ac0ee;">
                <!--<div  style="float:left;  width:80%;  font-size:230%; margin:25px 0px 0px 50px;">Smart  IoT Clean Cooling System</div>-->
					<!--<div><button  style="float:left;  width:5%; margin:40px 0px 0px 0px; white: gold; background:gray; font-size:1em;"onClick="window.open('sensorCheck.jsp', '_blank', 'width=550 height=500')">Cheak</button></div> --> <!-- onClick안에는 임시코드 -->
            </header>  	 	
            <!-- //  header -->
            <div style='position:relative;min-height:400px'>
 		          	
                <div style='padding-left:220px;'>
                    <div style='padding:20px;'>
                        <h3 style="font-size:25px;font-weight:500;letter-spacing:-1px;margin-bottom:20px;padding-left:30px;background:url('./images/list/bull_title.png') 0 center no-repeat;">로그인</h3>

                      	<div class='search-wrap'>
                            <ul>
                                <li>
                                    <div class='dist'>ID </div>
                                    <input type="text"  id="id_ID" class="wide-input">
                                </li>
                                <li>
                                    <div class='dist'>PW </div>
                                    <input type="password"  id="id_PW" class="wide-input">
                                </li>

                            </ul>
                        </div>
						<button class="btn-list btn-search blue" style='margin-top:10px; margin-left:150px;' onClick='FnLoginManager();'>로그인</button>
 
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

