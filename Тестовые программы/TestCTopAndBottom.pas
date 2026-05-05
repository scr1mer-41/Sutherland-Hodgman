program TestCtopAndbottom;
uses
   BGL, SUP;
var
   p: tPoly;
   
begin
  SetColor(Red);
  SetLength(p, 12);
  p[0].x := 300;
  p[0].y := 200;
  p[1].x := 300;
  p[1].y := -200;
  p[2].x := 1000;
  p[2].y := -200;
  p[3].x := 1000;
  p[3].y := 1000;
  p[4].x := 300;
  p[4].y := 1000;
  p[5].x := 300;
  p[5].y := 600;
  p[6].x := 500;
  p[6].y := 600;
  p[7].x := 500;
  p[7].y := 900;
  p[8].x := 900;
  p[8].y := 900;
  p[9].x := 900;
  p[9].y := -100;
  p[10].x := 500;
  p[10].y := -100;
  p[11].x := 500;
  p[11].y := 200;
  
  //SetViewPort(100, 100, 700, 700);
  //FillPoly(12, p);
  
  SmartFillPoly(12, p);
  
  Draw
  
end.