program TestPolygonOnePointOnCorner;
uses
   BGL, SUP;
const
   n = 300;
var
   p, p1: tPoly;
   
   
begin
  SetColor(Red);
  SetLength(p, 4);
  p[0].x := 300-n;
  p[0].y := 300-n;
  p[1].x := 500-n;
  p[1].y := 300-n;
  p[2].x := 500-n;
  p[2].y := 500-n;
  p[3].x := 300-n;
  p[3].y := 500-n;

  SetLength(p1, 4);
  p1[0].x := 300+n;
  p1[0].y := 300-n;
  p1[1].x := 500+n;
  p1[1].y := 300-n;
  p1[2].x := 500+n;
  p1[2].y := 500-n;
  p1[3].x := 300+n;
  p1[3].y := 500-n;

//  FillPoly(6, p);
  
  SmartFillPoly(4, p);
  SmartFillPoly(4, p1);
  
  Draw
  
end.