part of DigitalRails;

class Shape{
  static const int traceEnd = 100;
  ImageElement traceImage;
  List<Point> shapeOutlineCoords = [];

  int trace = 0;

  void animateTrace(){

  }

  void setTrace(int currTrace){
    trace = currTrace;
  }

  void resetTrace(){
    trace = 0;
  }

  void drawShape(CanvasElement canvas, CanvasRenderingContext2D ctx){
      var imgAspectRatio = traceImage.width/traceImage.height;
      var scaledWidth = imgAspectRatio*canvas.width;
      var scaledHeight = imgAspectRatio*canvas.height;

      ctx.drawImageScaled(traceImage, (canvas.width - scaledWidth)/2,
          (canvas.height - scaledHeight)/2, scaledWidth, scaledHeight);
  }


  void fillActiveArea(Point mousePos, CanvasElement canvas,
      CanvasRenderingContext2D ctx){
    var rect = canvas.getBoundingClientRect();
    var widthRatio = canvas.width/(rect.right-rect.left);
    var heightRatio = canvas.height/(rect.bottom-rect.top);

    num radius = 10;
    ctx.beginPath();
    ctx.fillStyle = "rgba(188, 76, 78, 0.5)";

    ctx.ellipse(mousePos.x,mousePos.y,radius*widthRatio,radius*heightRatio,0,0,
        2*PI,false);
    ctx.fill();
  }

  void addPointToOutline(Point mousePos){
    shapeOutlineCoords.add(new Point(mousePos.x, mousePos.y));
  }

  void drawShapeThroughOutlinePoints(CanvasRenderingContext2D ctx){
    ctx.fillStyle = "rgba(0, 76, 78, 1)";
    ctx.lineWidth = 5;

    // move to the first point
    ctx.moveTo(shapeOutlineCoords[0].x, shapeOutlineCoords[0].y);

    num i = 1;
    for (i = 1; i < shapeOutlineCoords.length - 2; i ++)
    {
      var xc = (shapeOutlineCoords[i].x + shapeOutlineCoords[i + 1].x) / 2;
      var yc = (shapeOutlineCoords[i].y + shapeOutlineCoords[i + 1].y) / 2;
      ctx.quadraticCurveTo(shapeOutlineCoords[i].x, shapeOutlineCoords[i].y, xc, yc);
      ctx.stroke();
    }
    // curve through the last two points
    //ctx.quadraticCurveTo(shapeOutlineCoords[i].x, shapeOutlineCoords[i].y, shapeOutlineCoords[i+1].x,shapeOutlineCoords[i+1].y);
    ctx.stroke();
  }
}