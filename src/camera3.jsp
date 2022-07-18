<!DOCTYPE html>
<html>
	 <script type="text/javascript">
        //Using jQuery for simplicity


		function motionjpeg(id) {
		    var image = $(id), src;

		    if (!image.length) return;

		    src = image.attr("src");
		    if (src.indexOf("?") < 0) {
				image.attr("src", src + "?"); // must have querystring
		    }

		    image.on("load", function() {
        // this cause the load event to be called "recursively"
				this.src = this.src.replace(/\?[^\n]*$/, "?") +
	            (new Date()).getTime(); // 'this' refers to the image
		    });
		}
    </script>

<head>
    <title>ipCam</title>
</head>

<body>
    <h1>ipCam</h1>
    <img id="motionjpeg" src="http://root:root@192.168.0.187:81/live/media/WINDOWS-5UD50EP/DeviceIpint.1/SourceEndpoint.video:0:0?w=1600&h=0" />
</body>

</html>