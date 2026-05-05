program TestPright;
uses
   BGL, SUP;
var
   p: tPoly;
   
begin
  SetColor(Red);
  SetLength(p, 8);
  p[0].x := 700;
  p[0].y := 700;
  p[1].x := 700;
  p[1].y := 500;
  p[2].x := 900;
  p[2].y := 500;
  p[3].x := 900;
  p[3].y := 300;
  p[4].x := 700;
  p[4].y := 300;
  p[5].x := 700;
  p[5].y := 100;
  p[6].x := 1000;
  p[6].y := 100;
  p[7].x := 1000;
  p[7].y := 700;
  
//  FillPoly(9, p);
  
  SmartFillPoly(8, p);
  
  Draw
  
end.