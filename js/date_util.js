
//yyyy-MM-dd HH:mm:ss 형식 문자열을 파싱한다
//Date 개체를 리턴한다.
function parseDateYMD(sDate)
{
	if(sDate == null) return null;
	// 그냥 전달해도 된다.  복잡하게 하지 말자
	// 아~~ 아이폰(사파리에서는 안된다..)
	// return new Date(sDate);
	// 파싱해서 하자	

	if(sDate.length < 10) return null;
	var nY = parseInt(sDate.substring(0,4));
	var nM = parseInt(sDate.substring(5,7));
	var nD = parseInt(sDate.substring(8,10));

	var nH = 0;
	var nMin = 0;
	var nS = 0;
	if(sDate.length >= 16)
	{	
		nH = parseInt(sDate.substring(11,13));
		nMin = parseInt(sDate.substring(14,16));
	}
	
	if(sDate.length >= 19)
		nS = parseInt(sDate.substring(17,19));

	var oDate = new Date(nY,nM-1,nD,nH,nMin,nS,0);
	return oDate;
}

//==========================================
// Date 출력 포맷 함수
// 사용방법  예시)
// var dateToDay = new Date();
// dateToDay.format('yyyy-MM-dd [E]')   ->  2016-10-31 [월요일]
 String.prototype.string = function(len){var s = '', i = 0; while (i++ < len) { s += this; } return s;};
 String.prototype.zf = function(len){return "0".string(len - this.length) + this;};
 Number.prototype.zf = function(len){return this.toString().zf(len);};
 
 Date.prototype.format = function(f) 
 {
    if (!this.valueOf()) return " ";
 
    var weekName = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
    var d = this;
     
    return f.replace(/(yyyy|yy|MM|dd|E|hh|mm|ss|a\/p)/gi, function($1) {
        switch ($1) {
            case "yyyy": return d.getFullYear();
            case "yy": return (d.getFullYear() % 1000).zf(2);
            case "MM": return (d.getMonth() + 1).zf(2);
            case "dd": return d.getDate().zf(2);
            case "E": return weekName[d.getDay()];
            case "HH": return d.getHours().zf(2);
            case "hh": return ((h = d.getHours() % 12) ? h : 12).zf(2);
            case "mm": return d.getMinutes().zf(2);
            case "ss": return d.getSeconds().zf(2);
            case "a/p": return d.getHours() < 12 ? "오전" : "오후";
            default: return $1;
        }
    });
};

