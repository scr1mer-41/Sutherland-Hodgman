program TestFillPoly;
uses
   BGL, SUP;
var
   p: tPoly;
   
begin
  SetColor(Red);
  SetLength(p, 9);
  p[0].x := 300;
  p[0].y := 300;
  p[1].x := 200;
  p[1].y := -200;
  p[2].x := 1000;
  p[2].y := -200;
  p[3].x := 1000;
  p[3].y := 900;
  p[4].x := 600;
  p[4].y := 900;
  p[5].x := 600;
  p[5].y := 400;
  p[6].x := 900;
  p[6].y := 400;
  p[7].x := 900;
  p[7].y := -100;
  p[8].x := 400;
  p[8].y := -100;
  
  SmartFillPoly(9, p);
  
  Draw
  
end.