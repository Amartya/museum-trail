part of DigitalRails;

class GridElement{
  Point topLeft;
  num width;
  num height;
  num pointCount;
  bool stopTesting;

  static const GRIDFULLCOUNT = 3;

  GridElement(){
    pointCount = 0;
    stopTesting = false;
  }

  bool withinBounds(Point p){
    bool withinBounds = false;
    if ((topLeft.x <= p.x) && (p.x <= topLeft.x + width)){
      if ((topLeft.y <= p.y) && (p.y <= topLeft.y + height)) {
        withinBounds = true;
      }
    }
    return withinBounds;
  }

  //function to check if there are enough points traced in grid
  bool gridFull(){
    bool gridFull = false;

    if(pointCount >= GRIDFULLCOUNT){
      gridFull = true;
    }

    return gridFull;
  }
}