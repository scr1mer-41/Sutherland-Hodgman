program TestPolygonOnePointOnBorder;
uses
   BGL, SUP;
const
   n = 200;
var
   p, p1: tPoly;
   
   
begin
  SetColor(Red);
  SetLength(p, 6);
  p[0].x := 300 - n;
  p[0].y := 300;
  p[1].x := 500 - n;
  p[1].y := 300;
  p[2].x := 600 - n;
  p[2].y := 400;
  p[3].x := 500 - n;
  p[3].y := 500;
  p[4].x := 300 - n;
  p[4].y := 500;
  p[5].x := 200 - n;
  p[5].y := 400;

  SetLength(p1, 6);
  p1[0].x := 300 + n;
  p1[0].y := 300;
  p1[1].x := 500 + n;
  p1[1].y := 300;
  p1[2].x := 600 + n;
  p1[2].y := 400;
  p1[3].x := 500 + n;
  p1[3].y := 500;
  p1[4].x := 300 + n;
  p1[4].y := 500;
  p1[5].x := 200 + n;
  p1[5].y := 400;

  


//  FillPoly(6, p);
  
  SmartFillPoly(6, p);
  SmartFillPoly(6, p1);
  
  Draw
  
end.