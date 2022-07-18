<%@ page language="java" contentType="text/html; charset=utf-8"   pageEncoding="utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="common.util.EtcUtils"%>
<%@ page import="wguard.web.WGuardUtil"%>
<%@ page import="wguard.dao.DaoSite"%>
<%@ page import="wguard.dao.DaoSite.DaoSiteRecord"%>
<%@ page import="wguard.dao.DaoCamera"%>
<%@ page import="wguard.dao.DaoCamera.DaoCameraRecord"%>
<%@ page import="wguard.dao.DaoSensor"%>
<%@ page import="wguard.dao.DaoSensor.DaoSensorRecord"%>
<%@ page import="wguard.dao.DaoSensorSt"%>
<%@ page import="wguard.dao.DaoSensorSt.DaoSensorStRecord"%>
<%@ page import="wguard.dao.DaoDisplay"%>
<%@ page import="wguard.dao.DaoDisplay.DaoDisplayRecord"%>
<%@ page import="wguard.dao.DaoCleanloadInfo"%>
<%@ page import="wguard.dao.DaoCleanloadInfo.DaoCleanloadInfoRecord"%>
<%@ page import="wguard.dao.DaoLinkSensor"%>
<%@ page import="wguard.dao.DaoLinkSensor.DaoLinkSensorRecord"%>

<%
boolean bError = false;

HttpSession p_Session = request.getSession(false);
if(p_Session == null)
{
	bError = true;
}
String strID = (String)p_Session.getAttribute("ID");
if(strID == null)
{
	bError = true;
}

request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
//-----------------------------	
// 사이트에 등록된  카메라 / 센서 정보를  로딩한다.
	JSONObject joReturn = new JSONObject();
	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","session not found");
		out.println(joReturn.toString());
		return ;
	}
	
	String strSTID = EtcUtils.NullS(request.getParameter("stid"));
	if(strSTID.isEmpty())
	{
		bError = true;
	}

	if(bError)
	{
		joReturn.put("result","FAIL");
		joReturn.put("msg","Parameter stid is not found.");
		out.println(joReturn.toString());
		return ;
	}
	
	joReturn.put("result","OK");
	joReturn.put("msg","success");
	
	
	if(!strSTID.isEmpty())
	{
		DaoSite daoSite = new DaoSite();
		DaoSiteRecord  rSTR = daoSite.getSite(strSTID);
	}

    // 센서 정보 수집
	DaoSensor daoSensor = new DaoSensor();
	ArrayList<DaoSensorRecord> arySensor =  daoSensor.selectSensor(strSTID,true);
	
	
	/*
	지금은 현재 메세지만 가져오는 형식
	나중에는 아이디나 사이트롤 검색해서 가져오게 변경
	*/
	DaoDisplay daoDisplay = new DaoDisplay();
	ArrayList<DaoDisplayRecord> aryDisplay =  daoDisplay.selectMessage(true);
	
	DaoCleanloadInfo daoCleanloadInfo = new DaoCleanloadInfo();
	DaoLinkSensor daoLinkSensor = new DaoLinkSensor();
	
	
	ArrayList<String> arySIDs =  new ArrayList<String>();
	HashMap<String, JSONObject> mapSensor = new HashMap<String, JSONObject>();
 	JSONObject   joSensor = null;
 	JSONArray     jaSensor  = new JSONArray();
	
	JSONObject   joEtc = null;
	JSONObject   joSvg = null;		

	for(DaoSensorRecord rSR : arySensor)
	{
		joSensor = new JSONObject();
		joSensor.put("sid",rSR.m_strSID);
		joSensor.put("name",rSR.m_strSName);
		joSensor.put("idx",rSR.m_nListIdx);
		joSensor.put("date",EtcUtils.getStrDate(rSR.m_dateReg,"yyyy-MM-dd HH:mm"));
		joSensor.put("alarm", (rSR.m_strAlarmState.equals("0") ? false : true));
		// 아래 필드는 다시 최종 센서 상태값으로 다시 설정된다.
		joSensor.put("batlv",0); // BAT레벨 50으로 
		joSensor.put("state","1"); // '0' 닫힘(대기), '1'열림(감지됨)	
		joSensor.put("alive","0"); // '0' 정상, '1' 통신불량, '2' BAT 불량, '3' 센서 불량	
		joSensor.put("usegoal",100); // '162(A2)' 보안센서, '163(A3)' 동작센서 100은 미등록값
		
		joEtc = new JSONObject();
			String[] astrEtc= EtcUtils.splitString(rSR.m_strAlarmVal,"=\\",true,false);
			for(int i=0; i<astrEtc.length; i+=2 )
			{
				if(astrEtc.length > i+1)
					joEtc.put(astrEtc[i],astrEtc[i+1]);
			}
		
		for(DaoDisplayRecord rDR : aryDisplay)
		{
			if(rDR.m_strSID.equals(rSR.m_strSID))
			{
				joSensor.put("message",rDR.m_strMessage);
				break;
			}
		}	
		
		DaoLinkSensorRecord  rLSR = daoLinkSensor.getPoles(rSR.m_strSID,true);
		if(rLSR != null) 
		{
			joSensor.put("polesid",rLSR.m_strSID);		
		}
		
		
		
		DaoCleanloadInfoRecord rCI = daoCleanloadInfo.getCleanloadInfo(rSR.m_strSID,true);
		
		joSvg = new JSONObject();
		
		String[] astrMapCode= EtcUtils.splitString(rCI.m_strMapcode,"=\\",true,false);
		
		for(int i=0; i<astrMapCode.length; i+=2 )
		{
			if(astrMapCode.length > i+1)
				joSvg.put(astrMapCode[i],astrMapCode[i+1]);
		}
		
		joSensor.put("svg",joSvg);
		
		joSensor.put("etc",joEtc);
		jaSensor.put(joSensor);

		//센서 최종 상태를 조회 하기위해 SID모음
		arySIDs.add(rSR.m_strSID);
		mapSensor.put(rSR.m_strSID,joSensor);
	}
	
	DaoSensorSt daoSSt = new DaoSensorSt();	
	ArrayList<DaoSensorStRecord> arySStR =  daoSSt.selectLastSensorSt(arySIDs);

	
	JSONObject   joExp = null;
	
	for(DaoSensorStRecord rSSt :  arySStR)
	{	
		joSensor = mapSensor.get(rSSt.m_strSensorID);
		if(joSensor != null)
		{
			joExp = new JSONObject();
			String[] astrExp= EtcUtils.splitString(rSSt.m_strExpansion,"=\\",true,false);
			for(int i=0; i<astrExp.length; i+=2 ){
				if(astrExp.length > i+1)
					joExp.put(astrExp[i],astrExp[i+1]);
			}
			
			if(rSSt.m_nUseGoal == 165) //먼지센서 165(A5)
				joSensor.put("batlv",rSSt.m_nBatteryLevel); // 먼지센서는 베터리 대신 센서값이 온다
			else
				joSensor.put("batlv",WGuardUtil.calcBatteryPercent(rSSt.m_nBatteryLevel)); // 여기서 %로 할당해서 보내야 한다. 센서에 따라서 BAT레벨을 알 방법이 없당...

			
			joSensor.put("state", rSSt.m_strSensorState); // '0' 닫힘(대기), '1'열림(감지됨)	
			joSensor.put("alive",rSSt.m_strSensorAction); // '0' 정상, '1' 통신불량, '2' BAT 불량, '3' 센서 불량	
			joSensor.put("usegoal",rSSt.m_nUseGoal); // '162(A2)' 보안센서, '163(A3)' 동작센서
			joSensor.put("action",rSSt.m_strSensorAction);
			joSensor.put("gwid",rSSt.m_strGWID); //게이트 아이디 센서에 명령을 전달하기 위해서 필요하다
			joSensor.put("date",EtcUtils.getStrDate(rSSt.m_dateReg,"yyyy-MM-dd HH:mm"));
			joSensor.put("exp",joExp);
			joSensor.put("battery",rSSt.m_nBatteryLevel);
		}
	}
    joReturn.put("members",jaSensor);
	//System.out.println(joReturn.toString());
	out.println(joReturn.toString());
	
%>