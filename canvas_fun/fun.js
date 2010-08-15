(function() {
function draw() {
  var canvas = $('canvas');
  if(canvas.getContext) {
    var winSize = window.sizes();
    canvas.set('width', winSize.x - 20).set('height', winSize.y - 21);

    var ctx = canvas.getContext('2d');
    //draw_shapes(ctx);
    draw_editor(ctx);
  }
}

function draw_shapes(ctx) {
  /* various shapes */
  (function(ctx) {
    ctx.save();

    ctx.fillStyle = 'rgb(200, 0, 0)';
    ctx.fillRect(10, 10, 55, 50);

    ctx.fillStyle = 'rgba(0, 0, 200, 0.5)';
    ctx.fillRect(30, 30, 55, 50);

    ctx.fillStyle = 'rgb(0, 0, 0)';
    ctx.fillRect(100, 100, 100, 100);
    ctx.clearRect(120, 120, 60, 60);
    ctx.strokeRect(125, 125, 50, 50);

    ctx.fillStyle = 'rgb(173, 200, 26)';
    ctx.beginPath();
    ctx.moveTo(100, 50);
    ctx.lineTo(125, 75);
    ctx.lineTo(125, 25);
    ctx.fill();

    ctx.fillStyle = 'rgb(240, 42, 161)';
    ctx.arc(75, 250, 50, 0, Math.PI * 2, true);
    ctx.moveTo(110, 250);
    ctx.arc(75, 250, 35, 0, Math.PI, false);
    ctx.moveTo(65, 240);
    ctx.arc(60, 240, 5, 0, Math.PI * 2, true);
    ctx.moveTo(95, 240);
    ctx.arc(90, 240, 5, 0, Math.PI * 2, true);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(220, 0);
    ctx.lineTo(300, 0);
    ctx.lineTo(220, 80);
    ctx.fill();

    ctx.beginPath();
    ctx.moveTo(320, 100);
    ctx.lineTo(320, 20);
    ctx.lineTo(240, 100);
    ctx.closePath();
    ctx.stroke();

    // Quadratric curves example
    ctx.beginPath();
    //ctx.moveTo(75,25);
    ctx.moveTo(300, 225);
    ctx.quadraticCurveTo(250, 225, 250, 262.5);
    ctx.quadraticCurveTo(250, 300, 275, 300);
    ctx.quadraticCurveTo(275, 320, 255, 325);
    ctx.quadraticCurveTo(285, 320, 285, 300);
    ctx.quadraticCurveTo(350, 300, 350, 262.5);
    ctx.quadraticCurveTo(350, 225, 300, 225);
    ctx.stroke();

    // Bezier curves example
    ctx.beginPath();
    ctx.moveTo(75, 340);
    ctx.bezierCurveTo(75, 337, 70, 325, 50, 325);
    ctx.bezierCurveTo(20, 325, 20, 362.5, 20, 362.5);
    ctx.bezierCurveTo(20, 380, 40, 402, 75, 420);
    ctx.bezierCurveTo(110, 402, 130, 380, 130, 362.5);
    ctx.bezierCurveTo(130, 362.5, 130, 325, 100, 325);
    ctx.bezierCurveTo(85, 325, 75, 337, 75, 340);
    ctx.fill();

    ctx.restore();
  })(ctx);

  /* Gradient Examples */
  /* linearGradientExample */
  (function(ctx) {
    // Create gradients
    var lingrad = ctx.createLinearGradient(340, 340, 340, 490);
    lingrad.addColorStop(0, '#00ABEB');
    lingrad.addColorStop(0.5, '#fff');
    lingrad.addColorStop(0.5, '#26C000');
    lingrad.addColorStop(1, '#fff');

    var lingrad2 = ctx.createLinearGradient(340, 390, 340, 435);
    lingrad2.addColorStop(0.5, '#000');
    lingrad2.addColorStop(1, 'rgba(0,0,0,0)');

    // assign gradients to fill and stroke styles
    ctx.fillStyle = lingrad;
    ctx.strokeStyle = lingrad2;

    // draw shapes
    ctx.fillRect(350, 350, 130, 130);
    ctx.strokeRect(390, 390, 50, 50);
  })(ctx);

  /* shadowExample */
  (function(ctx) {
    ctx.save();
    ctx.shadowOffsetX = 2;
    ctx.shadowOffsetY = 2;
    ctx.shadowBlur = 2;
    ctx.shadowColor = "rgba(0, 0, 0, 0.5)";

    ctx.font = "20px 宋体";
    ctx.fillStyle = "Black";
    ctx.fillText("一串中文字", 340, 30); /* it does not work */
    // ctx.fillText("Text Sample", 340, 30);
    ctx.restore();
  })(ctx);

  /* translateExample */
  (function(ctx) {
    function drawSpirograph(ctx,R,r,O){
      var x1 = R-O;
      var y1 = 0;
      var i  = 1;
      ctx.beginPath();
      ctx.moveTo(x1, y1);
      do {
        if (i > 20000) break;
        var x2 = (R+r)*Math.cos(i*Math.PI/72) - (r+O)*Math.cos(((R+r)/r)*(i*Math.PI/72))
        var y2 = (R+r)*Math.sin(i*Math.PI/72) - (r+O)*Math.sin(((R+r)/r)*(i*Math.PI/72))
        ctx.lineTo(x2,y2);
        x1 = x2;
        y1 = y2;
        i++;
      } while (x2 != R-O && y2 != 0 );
      ctx.stroke();
    }

    function draw() {
      ctx.save();
      ctx.fillStyle = "black";
      ctx.fillRect(450, 0, 300, 300);
      ctx.strokeStyle = "#9CFF00";
      for(var i = 0; i < 3; i++) {
        for(var j = 0; j < 3; j++) {
          ctx.save();
          ctx.translate(500 + j * 100 , 50 + i * 100);
          drawSpirograph(ctx, 20 * (j + 2) / (j + 1), -8 * (i + 3) / (i + 1), 10);
          ctx.restore();
        }
      }
      ctx.restore();
    }

    draw();
  })(ctx);
  
  /* rotateExample */
  (function(ctx) {
    ctx.save();
    ctx.translate(600, 380);

    for (var i=1;i<6;i++){ // Loop through rings (from inside to out)
      ctx.save();
      ctx.fillStyle = 'rgb('+(51*i)+','+(255-51*i)+',255)';

      for (var j = 0; j < i * 6; j++){ // draw individual dots
        ctx.rotate(Math.PI * 2 / (i * 6));
        ctx.beginPath();
        ctx.arc(0,i*12.5,5,0,Math.PI*2,true);
        ctx.fill();
      }

      ctx.restore();
    }
    ctx.restore();
  })(ctx);

  /* a sum-up */
  (function(ctx) {
    function roundedRect(ctx,x,y,width,height,radius){
      ctx.beginPath();
      ctx.moveTo(x,y+radius);
      ctx.lineTo(x,y+height-radius);
      ctx.quadraticCurveTo(x,y+height,x+radius,y+height);
      ctx.lineTo(x+width-radius,y+height);
      ctx.quadraticCurveTo(x+width,y+height,x+width,y+height-radius);
      ctx.lineTo(x+width,y+radius);
      ctx.quadraticCurveTo(x+width,y,x+width-radius,y);
      ctx.lineTo(x+radius,y);
      ctx.quadraticCurveTo(x,y,x,y+radius);
      ctx.stroke();
    }

    function draw() {
      roundedRect(ctx,12,12,150,150,15);
      roundedRect(ctx,19,19,150,150,9);
      roundedRect(ctx,53,53,49,33,10);
      roundedRect(ctx,53,119,49,16,6);
      roundedRect(ctx,135,53,49,33,10);
      roundedRect(ctx,135,119,25,49,10);

      ctx.beginPath();
      ctx.arc(37,37,13,Math.PI/7,-Math.PI/7,true);
      ctx.lineTo(31,37);
      ctx.fill();
      for(var i=0;i<8;i++){
        ctx.fillRect(51+i*16,35,4,4);
      }
      for(i=0;i<6;i++){
        ctx.fillRect(115,51+i*16,4,4);
      }
      for(i=0;i<8;i++){
        ctx.fillRect(51+i*16,99,4,4);
      }
      ctx.beginPath();
      ctx.moveTo(83,116);
      ctx.lineTo(83,102);
      ctx.bezierCurveTo(83,94,89,88,97,88);
      ctx.bezierCurveTo(105,88,111,94,111,102);
      ctx.lineTo(111,116);
      ctx.lineTo(106.333,111.333);
      ctx.lineTo(101.666,116);
      ctx.lineTo(97,111.333);
      ctx.lineTo(92.333,116);
      ctx.lineTo(87.666,111.333);
      ctx.lineTo(83,116);
      ctx.fill();
      ctx.fillStyle = "white";
      ctx.beginPath();
      ctx.moveTo(91,96);
      ctx.bezierCurveTo(88,96,87,99,87,101);
      ctx.bezierCurveTo(87,103,88,106,91,106);
      ctx.bezierCurveTo(94,106,95,103,95,101);
      ctx.bezierCurveTo(95,99,94,96,91,96);
      ctx.moveTo(103,96);
      ctx.bezierCurveTo(100,96,99,99,99,101);
      ctx.bezierCurveTo(99,103,100,106,103,106);
      ctx.bezierCurveTo(106,106,107,103,107,101);
      ctx.bezierCurveTo(107,99,106,96,103,96);
      ctx.fill();
      ctx.fillStyle = "black";
      ctx.beginPath();
      ctx.arc(101,102,2,0,Math.PI*2,true);
      ctx.fill();
      ctx.beginPath();
      ctx.arc(89,102,2,0,Math.PI*2,true);
      ctx.fill();
    }

    function init() {
      ctx.save();
      ctx.translate(0, 500);
      draw();
      ctx.restore();
    }

    init();
  })(ctx);

  // clipExample
  (function(ctx) {
  })(ctx);

  // Animation Clock
  (function(ctx) {
    function init(){
      clock();
      setInterval(clock, 1000);
    }

    function clock(){
      ctx.save();
      ctx.translate(800, 0);
      ctx.clearRect(0, 0, 150, 150);
      ctx.translate(75, 75);
      ctx.scale(0.4, 0.4);
      ctx.rotate(-Math.PI/2);
      ctx.strokeStyle = "black";
      ctx.fillStyle = "white";
      ctx.lineWidth = 8;
      ctx.lineCap = "round";

      // Hour marks
      ctx.save();
      for (var i=0;i<12;i++){
        ctx.beginPath();
        ctx.rotate(Math.PI/6);
        ctx.moveTo(100,0);
        ctx.lineTo(120,0);
        ctx.stroke();
      }
      ctx.restore();

      // Minute marks
      ctx.save();
      ctx.lineWidth = 5;
      for (i=0;i<60;i++){
        if (i%5 != 0) {
          ctx.beginPath();
          ctx.moveTo(117,0);
          ctx.lineTo(120,0);
          ctx.stroke();
        }
        ctx.rotate(Math.PI/30);
      }
      ctx.restore();

      var now = new Date(),
          sec = now.getSeconds(),
          min = now.getMinutes(),
          hr  = now.getHours();
      hr = hr >= 12 ? hr - 12 : hr;

      ctx.fillStyle = "black";

      // write Hours
      ctx.save();
      ctx.rotate(hr*(Math.PI/6) + (Math.PI/360)*min + (Math.PI/21600)*sec)
      ctx.lineWidth = 14;
      ctx.beginPath();
      ctx.moveTo(-20, 0);
      ctx.lineTo(80, 0);
      ctx.stroke();
      ctx.restore();

      // write Minutes
      ctx.save();
      ctx.rotate( (Math.PI/30)*min + (Math.PI/1800)*sec )
      ctx.lineWidth = 10;
      ctx.beginPath();
      ctx.moveTo(-28,0);
      ctx.lineTo(112,0);
      ctx.stroke();
      ctx.restore();

      // Write seconds
      ctx.save();
      ctx.rotate(sec * Math.PI/30);
      ctx.strokeStyle = "#D40000";
      ctx.fillStyle = "#D40000";
      ctx.lineWidth = 6;
      ctx.beginPath();
      ctx.moveTo(-30,0);
      ctx.lineTo(83,0);
      ctx.stroke();
      ctx.beginPath();
      ctx.arc(0,0,10,0,Math.PI*2,true);
      ctx.fill();
      ctx.beginPath();
      ctx.arc(95,0,10,0,Math.PI*2,true);
      ctx.stroke();
      ctx.fillStyle = "rgba(85, 85, 85, 0.5)";
      ctx.arc(0,0,3,0,Math.PI*2,true);
      ctx.fill();
      ctx.restore();

      ctx.beginPath();
      ctx.lineWidth = 14;
      ctx.strokeStyle = '#325FA2';
      ctx.arc(0,0,142,0,Math.PI*2,true);
      ctx.stroke();

      ctx.restore();
    }

    init();
  })(ctx);

  // Animation Looping Image
  (function(ctx) {
    var img = new Image();

    //User Variables
    img.src = 'Capitan_Meadows,_Yosemite_National_Park.jpg';
    var width = 400;
    var speed = 30; //lower is faster
    var scale = 1.05;
    var y = -4.5; //vertical offset
    ////End User Variables

    var imgW = img.width;
    var imgH = img.height;
    var height = imgH * scale;

    var x = 0,
        dx = 0.75;

    function init() {
      //Set Refresh Rate
      img.onload = function() {
        //draw();
        return setInterval(draw, speed);
      };
    }

    function draw() {
      /* This algorithm is *only* suitable when img is wider than canvas is.*/
      ctx.save();
      ctx.translate(800, 200);
      //Clear Canvas
      ctx.clearRect(0, 0, width * scale, height);

      /* ----> */
      var rightW = width - x;
      if(rightW > 0) {
        ctx.drawImage(img, 0, 0, rightW, imgH, x * scale, 0, rightW * scale, height);
      }
      if(x > 0) {
        var leftW = x > width ? width : x;
        ctx.drawImage(img, imgW - x, 0, leftW, imgH, 0, 0, leftW * scale, height);
      }

      x += dx;
      if(x > imgW) x = x - imgW;
      ctx.restore();
    }

    init();
  })(ctx);
}

function draw_editor(ctx) {
  var Editor = new Class({
    initialize: function(ctx) {
      $('canvas').on({
        'mousedown': function() { alert('hey') },
        'mouseup':   function() { alert('man') }
      });
      this.ctx = ctx;
      this.line_height = 18;
    },

    draw: function() {
      var ctx = this.ctx, line_height = this.line_height;
      ctx.save();
      ctx.font = line_height - 5 + 'px 宋体';
      var lingrad = ctx.createLinearGradient(0, 0, 0, line_height);
      lingrad.addColorStop(0, '#06ADB4');
      lingrad.addColorStop(1, '#03787D');
      var width = ctx.canvas.width,
          white = '#FFF';
      /*Object.keys(ctx).sort().*/['A', 'B', 'f'].each(function(key, i) {
        ctx.save();
        ctx.translate(0, i * line_height);
        ctx.fillStyle = lingrad;
        ctx.fillRect(0, 0, width, line_height);
        ctx.fillStyle = white;
        ctx.fillText(key, 0, line_height - 5);
        ctx.restore();
      });
      ctx.restore();
    }
  });

  new Editor(ctx).draw();
}

document.onReady(function() {
  draw();
});
})();
