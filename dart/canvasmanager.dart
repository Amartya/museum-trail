part of DigitalRails;

class CanvasManager{
  static const xGridNum = 5;
  static const yGridNum = 8;

  Shape target = new Shape();

  CanvasElement canvas = new CanvasElement();
  CanvasRenderingContext2D ctx;

  var canvasImageData;
  var pix;

  var canvasGrid = [];
  num gridFullCount = 0;
  num prevMsgWidth = 0;

  bool animating = false;
  bool dragging = false;

  CanvasManager(){
    canvas = document.querySelector("#trace-img");
    ctx = canvas.getContext('2d');

    target.traceImage = new ImageElement(src: "img/oracle_bone_inscribed.png");
    target.traceImage.onLoad.listen((e){
      target.drawShape(canvas, ctx);
    });

    canvas.onMouseDown.listen((MouseEvent e){
      dragging = true;
    });

    canvas.onMouseMove.listen((MouseEvent e){
      //get coordinates relative to the canvas
      if(dragging){
        Point mousePos = getCanvasXandY(e);
        testColor(mousePos);
        updateMessageWidth();
      }
    });

    canvas.onMouseUp.listen((MouseEvent e){
      dragging = false;
      target.drawShapeThroughOutlinePoints(ctx);
      target.shapeOutlineCoords.clear();
    });

    createGridList();
  }

  void testColor(Point mousePos){
    //get  1-pixel data at that coordinate
    canvasImageData = ctx.getImageData(mousePos.x, mousePos.y, 1, 1);
    pix = canvasImageData.data;

    // Loop over the pixels and check color
    for (var i = 0, n = pix.length; i < n; i += 4) {
      // R: pix[i], G: pix[i+1]; B: pix[i+2], i+3 is alpha (the fourth element)
      var red = pix[i];
      var green = pix[i+1];
      var blue = pix[i+2];

      if(red == 255 && green == 255 && blue == 255){
        target.fillActiveArea(mousePos, canvas, ctx);
        target.addPointToOutline(mousePos);

        checkGridStatus(mousePos);
      }
    }
  }

  //get coordinates in Canvas space, instead of client space
  Point getCanvasXandY(e){
    var rect = canvas.getBoundingClientRect();

    var x = (e.client.x-rect.left)/(rect.right-rect.left)*canvas.width;
    var y = (e.client.y-rect.top)/(rect.bottom-rect.top)*canvas.height;

    return new Point(x,y);
  }

  void createGridList(){
    var gridWidth = canvas.width/xGridNum;
    var gridHeight = canvas.height/yGridNum;

    for(int i=0; i< xGridNum; i++){
      for(int j=0; j< yGridNum; j++){
        var gridEl = new GridElement();

        gridEl.width = gridWidth;
        gridEl.height = gridHeight;
        gridEl.topLeft = new Point(i*gridWidth, j*gridHeight);

        canvasGrid.add(gridEl);
      }
    }

    //drawGrid();
  }

  void checkGridStatus(mousePos){
    for(GridElement g in canvasGrid){
      if(g.withinBounds(mousePos)){
        g.pointCount++;

        if(g.gridFull() && !g.stopTesting){
          gridFullCount++;
          g.stopTesting = true;
        }
      }
    }
  }

  void updateMessageWidth(){
    DivElement msg = querySelector("#main-message");
    var nextPage = querySelector("#next-page");

    num width = 50*gridFullCount;


    if(!isOverflowed(msg)){
      msg.style.width = "750px";

      if(nextPage.style.opacity == ""){
        var animation = querySelector("#next-page").animate([{"opacity": 0},
        {"opacity": 100}], 3000);
        animation.addEventListener("finish", (e) {
          animating = false;
          querySelector("#next-page").style.opacity = 100.toString();
        });
      }
    }
    else {
      if (prevMsgWidth != width && !animating) {
        animating = true;
        var animation = msg.animate([{"width": prevMsgWidth.toString() + "px"},
                                      {"width": width.toString() + "px"}], 500);
        animation.addEventListener("finish", (e) {
          animating = false;
          prevMsgWidth = width;
          msg.style.width = width.toString() + "px";
        });
      }
    }
  }

  void drawGrid(){
    for(GridElement g in canvasGrid){
      ctx.strokeStyle = "rgba(188, 76, 78, 0.5)";
      ctx.strokeRect(g.topLeft.x, g.topLeft.y, g.width, g.height);
    }
  }

  bool isOverflowed(Element element){
    return element.scrollHeight > element.clientHeight || element.scrollWidth > element.clientWidth;
  }
}