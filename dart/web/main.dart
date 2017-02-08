library DigitalRails;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'shape.dart';
part 'canvasmanager.dart';
part 'grid.dart';



void main(){
  var canvasState = new CanvasManager();

  DivElement screen = querySelector("#screen");
  screen.onMouseDown.listen((MouseEvent e){
    if(canvasState.gridFullCount == 0){
      var timer = new Timer(const Duration(milliseconds: 100), showHelp);
      timer.cancel();
    }
  });
}








