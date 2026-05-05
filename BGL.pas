unit BGL;

interface

uses Display;

const
   Black   = $000000;
   White   = $FFFFFF;
   Red     = $FF0000;
   Green   = $00FF00;
   Blue    = $0000FF;
   Yellow  = $FFFF00;
   Magenta = $FF00FF;
   Cyan    = $00FFFF;
   
   SizeX = Display.SizeX;
   SizeY = Display.SizeY;
   GetMaxX = Display.GetMaxX;
   GetMaxY = Display.GetMaxY;

type   
   tPoint = record
      x, y: integer;
   end;   
   
   tPoly = array of tPoint;


function GetXLeft(): integer;
function GetYTop(): integer;
function GetXRight(): integer;
function GetYBottom(): integer;


procedure SetColor(C: tPixel);
procedure SetBkColor(C: tPixel);
procedure ClearDevice;

procedure PutPixel(x, y: integer; C: tPixel);
function GetPixel(x, y: integer): tPixel;

procedure LineDDA(x1, y1, x2, y2: integer);
procedure LinePP(x1, y1, x2, y2: integer);
procedure Line(x1, y1, x2, y2: integer);
procedure HLine(x1, y, x2: integer);

procedure ClipLeft(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
procedure ClipRight(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
procedure ClipTop(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
procedure ClipBottom(n: integer; p1: tPoly; var m: integer; var p2: tPoly);

procedure DrawFillPoly(n: integer; p: tPoly);

procedure Circle(xc, yc, R: integer);
procedure FillCircle(xc, yc, R: integer);

procedure FloodFill(x, y: integer; bord: tPixel);
procedure FillPoly(n: integer; p: tPoly);

procedure SetViewPort(xl, yt, xr, yb: integer);

procedure Draw;

{==================================================================}

implementation

uses
   Floats;
   
const
   nmax = 100;   
   
type
   tXbuf = record
      m: integer;
      x: array[1..nmax] of integer;
   end;   
   
   tYXbuf = array[0..GetMaxY] of tXbuf;
   
var
   YXbuf: tYXbuf;   
   CC, BC: tPixel;
   xleft, ytop, xright, ybottom: integer;




function GetXLeft(): integer;
begin
   GetXLeft := xleft
end;

function GetYTop(): integer;
begin
   GetYTop := ytop
end;

function GetXRight(): integer;
begin
   GetXRight := xright
end;

function GetYBottom(): integer;
begin
   GetYBottom := ybottom
end;


procedure SetColor(C: tPixel);
begin
   CC := C
end;

procedure SetBkColor(C: tPixel);
begin
   BC := C;
end;

procedure ClearDevice;
begin
   FillLB(0, SizeX*SizeY, BC);
end;

procedure DrawPutPixel(x, y: integer; C: tPixel);
begin
   LB[SizeX*y + x] := C;
end;

procedure LineDDA(x1, y1, x2, y2: integer);
{ Алгоритм ЦДА }
var
   x, y, xend, yend: integer;
   k, yf, xf: float;
   dx, dy: integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      k := (y2-y1)/(x2-x1);
      if x1 < x2 then begin
         x := x1;
         xend := x2;
         yf := y1;
         end
      else begin
         x := x2;
         xend := x1;
         yf := y2;
      end;
      repeat
         PutPixel(x, round(yf), CC);
         x := x + 1;
         yf := yf + k;
      until x > xend;    
      end
   else if dy > 0 then begin
      k := (x2-x1)/(y2-y1);
      if y1 < y2 then begin
         y := y1;
         yend := y2;
         xf := x1;
         end
      else begin
         y := y2;
         yend := y1;
         xf := x2;
      end;   
      repeat
         PutPixel(round(xf), y, CC);
         y := y + 1;
         xf := xf + k;
      until y > yend;
      end
   else
      PutPixel(x1, y1, CC);   
end;

procedure LinePP(x1, y1, x2, y2: integer);
{ Алгоритм Брезенхема }
var
   x, y, xend, yend: integer;
   d: integer;
   dx, dy: integer;
   inc1, inc2: integer;
   s: integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      if x1 < x2 then begin 
         x := x1; xend := x2; y := y1; 
         if y2 >= y1 then s := 1 else s := -1;
         end
      else begin 
         x := x2; xend := x1; y := y2; 
         if y2 >= y1 then s := -1 else s := 1;
      end;
      inc1 := 2*(dy - dx);
      inc2 := 2*dy;
      d := 2*dy - dx;
      PutPixel(x, y, CC);
      while x < xend do begin
         x := x + 1;
         if d > 0 then begin
            d := d + inc1;
            y := y + s
            end
         else
            d := d + inc2;   
         PutPixel(x, y, CC);
      end    
      end
   else begin
      if y1 < y2 then begin 
         y := y1; yend := y2; x := x1; 
         if x2 >= x1 then s := 1 else s := -1;
         end
      else begin 
         y := y2; yend := y1; x := x2; 
         if x2 >= x1 then s := -1 else s := 1;
      end;
      inc1 := 2*(dx - dy);
      inc2 := 2*dx;
      d := 2*dx - dy;
      PutPixel(x, y, CC);
      while y < yend do begin
         y := y + 1;
         if d > 0 then begin
            d := d + inc1;
            x := x + s
            end
         else
            d := d + inc2;   
         PutPixel(x, y, CC);
      end    
   end
end;

procedure DrawLine(x1, y1, x2, y2: integer);
{ Алгоритм Брезенхема с вычислением адреса }
var
   a, aend: integer; 
   d: integer;
   dx, dy: integer;
   inc1, inc2: integer;
   s: integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      if x1 < x2 then begin 
         a := SizeX*y1 + x1; aend := SizeX*y2 + x2;
         if y2 >= y1 then s := SizeX + 1 else s := -SizeX + 1;
         end
      else begin 
         a := SizeX*y2 + x2; aend := SizeX*y1 + x1;
         if y1 >= y2 then s := SizeX + 1 else s := -SizeX + 1;
      end;
      inc1 := 2*(dy - dx);
      inc2 := 2*dy;
      d := 2*dy - dx;
      LB[a] := CC;
      while a <> aend do begin
         if d > 0 then begin
            d := d + inc1;
            a := a + s
            end
         else begin
            d := d + inc2;   
            a := a + 1;
         end;   
         LB[a] := CC;
      end    
      end
   else begin
      if y1 < y2 then begin
         a := SizeX*y1 + x1; aend := SizeX*y2 + x2;
         if x1 <= x2 then s := SizeX + 1 else s := SizeX - 1
         end
      else begin
         a := SizeX*y2 + x2; aend := SizeX*y1 + x1;
         if x1 > x2 then s := SizeX + 1 else s := SizeX - 1
      end;
      inc1 := 2*(dx-dy);
      inc2 := 2*dx;
      d := 2*dx - dy;
      LB[a] := CC;
      while a <> aend do begin
         if d > 0 then begin
            a := a + s;
            d := d + inc1
            end
         else begin 
            d := d + inc2;
            a := a + SizeX;
         end;
         LB[a] := CC;
      end
   end
end;

procedure HLine(x1, y, x2: integer);
begin
   if x1 < x2 then
      FillLB(SizeX*y + x1, x2-x1+1, CC)
   else
      FillLB(SizeX*y + x2, x1-x2+1, CC)
end;

procedure Pixel8(xc, yc, x, y: integer);
begin
   PutPixel(xc + x, yc + y, CC);
   PutPixel(xc - x, yc + y, CC);
   PutPixel(xc + x, yc - y, CC);
   PutPixel(xc - x, yc - y, CC);
   
   PutPixel(xc + y, yc + x, CC);
   PutPixel(xc - y, yc + x, CC);
   PutPixel(xc + y, yc - x, CC);
   PutPixel(xc - y, yc - x, CC);
end;

procedure Circle(xc, yc, R: integer);
var
   x, y: integer;
   d: integer;
begin
   d := 3 - 2*R;
   x := 0;
   y := R;
   Pixel8(xc, yc, x, R);
   while x < y do begin
      if d < 0 then
         d := d + 4*x + 6
      else begin
         d := d + 4*(x - y) + 10;
         y := y - 1
      end;
      x := x + 1;
      Pixel8(xc, yc, x, y);
   end;
end;   

procedure Draw4(xc, yc, x, y: integer);
begin
   HLine(xc + x, yc + y, xc - x);
   HLine(xc - y, yc + x, xc + y);
   HLine(xc + x, yc - y, xc - x);
   HLine(xc - y, yc - x, xc + y);
end;

procedure FillCircle(xc, yc, R: integer);
var
   x, y: integer;
   d: integer;
begin
   d := 3 - 2*R;
   x := 0;
   y := R;
   Draw4(xc, yc, x, R);
   while x < y do begin
      if d < 0 then
         d := d + 4*x + 6
      else begin
         d := d + 4*(x - y) + 10;
         y := y - 1
      end;
      x := x + 1;
      Draw4(xc, yc, x, y);
   end;
end;   


function GetPixel(x, y: integer): tPixel;
begin
   GetPixel := LB[y*SizeX + x];
end;

procedure FloodFillBad(x, y: integer; bord: tPixel);
begin
   if (GetPixel(x, y) <> bord) and (GetPixel(x, y) <> CC) then begin
      PutPixel(x, y, CC);
      FloodFill(x+1, y, bord);
      FloodFill(x-1, y, bord);
      FloodFill(x, y+1, bord);
      FloodFill(x, y-1, bord);
   end;
end;

procedure FloodFill(x, y: integer; bord: tPixel);
var
   xl, xr, yy: integer;
begin
   xl := x;
   while GetPixel(xl, y) <> bord do
      xl := xl - 1;
   xl := xl + 1;
   xr := x;
   while GetPixel(xr, y) <> bord do
      xr := xr + 1;
   xr := xr - 1;
   if xl < xr then
      HLine(xl, y, xr);
   yy := y - 1;
   repeat
      x := xr;
      while x >= xl do begin
         while (x >= xl) and ((GetPixel(x, yy) = bord) or (GetPixel(x, yy) = CC)) do
            x := x - 1;
         if x >= xl then
            FloodFill(x, yy, bord);
         x := x - 1;
      end;
      yy := yy + 2;
   until yy > y + 1;     
end;

procedure Edge(x1, y1, x2, y2: integer);
{ Алгоритм ЦДА }
var
   k, xf: float;
   y, yend: integer;
begin
   k := (x2-x1)/(y2-y1);
   if y1 < y2 then begin
      y := y1; yend := y2; xf := x1; end
   else begin
      y := y2; yend := y1; xf := x2;
   end;  
   while y < yend do begin
      y := y + 1;
      xf := xf + k;
      inc(YXbuf[y].m);
      YXbuf[y].x[YXbuf[y].m] := round(xf);
   end 
end;

procedure Sort(var a: tXbuf);
{ Сортировка вставками }
var
   i, j, y  : integer;
begin
   for i := 2 to a.m do begin
      y := a.x[i];
      j := i-1;
      while ( j>0 ) and ( y < a.x[j] ) do begin
         a.x[j+1] := a.x[j];
         j := j-1;
      end;
      a.x[j+1] := y;
   end;
end;

procedure DrawFillPoly(n: integer; p: tPoly);
var
   y, ymin, ymax, i, i1, i2: integer;
begin
   ymin := p[0].y;
   ymax := ymin;
   for i := 0 to n-1 do
      if p[i].y < ymin then
         ymin := p[i].y
      else if p[i].y > ymax then
         ymax := p[i].y;
         
   for y := ymin to ymax do
      YXbuf[y].m := 0;
      
   i1 := n - 1;
   for i2 := 0 to n-1 do begin
      if p[i1].y <> p[i2].y then
         Edge(p[i1].x, p[i1].y, p[i2].x, p[i2].y);
      i1 := i2;
   end;   
 
   for y := ymin to ymax do begin
      Sort(YXbuf[y]);
      i := 1;
      while i < YXbuf[y].m do begin
         HLine(YXbuf[y].x[i], y, YXbuf[y].x[i+1]);
         i := i + 2;
      end;   
   end;   
   
end;

procedure SetViewPort(xl, yt, xr, yb: integer);
begin
   xleft := xl;
   ytop := yt;
   xright := xr;
   ybottom := yb;
end;

procedure Draw;
begin
   Display.Draw
end;

procedure PutPixel(x, y: integer; C: tPixel);
begin
   x := x + xleft; { Переход к абсолютным координатам }
   y := y + ytop;
   if (x >= xleft) and (x <= xright) and (y >= ytop) and (y <= ybottom) then
      DrawPutPixel(x, y, C);
end;

function Coding(x, y: integer): integer;
var
   code: integer;
begin
   code := 0;
   if x < xleft then
      code := code + 8
   else if x > xright then
      code := code + 4;

   if y < ytop then
      code := code + 2
   else if y > ybottom then
      code := code + 1;
   Coding := code;   
end;

procedure Line(x1, y1, x2, y2: integer);
var
   code1, code2: integer;  
   inside: Boolean;
   x, y, code: integer;
begin
   x1 := x1 + xleft;
   x2 := x2 + xleft;
   y1 := y1 + ytop;
   y2 := y2 + ytop;
   code1 := Coding(x1, y1);
   code2 := Coding(x2, y2);
   inside := code1 or code2 = 0;
   while not inside and ((code1 and code2) = 0) do begin
      if code1 = 0 then begin
         x := x1; x1 := x2; x2 := x;
         y := y1; y1 := y2; y2 := y;
         code := code1; code1 := code2; code2 := code;
      end;
      { Здесь x1, y1 - снаружи }
      if x1 < xleft then begin
         y1 := y1 + round((y2-y1)/(x2-x1)*(xleft-x1));
         x1 := xleft;
         end
      else if x1 > xright then begin
         y1 := y1 + round((y2-y1)/(x2-x1)*(xright-x1));
         x1 := xright;
         end
      else if y1 < ytop then begin   
         x1 := x1 + round((x2-x1)/(y2-y1)*(ytop-y1));
         y1 := ytop;
         end
      else { y1 > ybottom } begin
         x1 := x1 + round((x2-x1)/(y2-y1)*(ybottom-y1));
         y1 := ybottom;
      end;
      code1 := Coding(x1, y1);
      inside := code1 or code2 = 0;
   end;
   if inside then
      DrawLine(x1, y1, x2, y2);
end; 

procedure ClipLeft(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
var
   x1, y1, x2, y2: integer;
   i: integer;
   inside1, inside2: Boolean;
begin
   m := 0;
   x1 := p1[n-1].x;
   y1 := p1[n-1].y;
   inside1 := x1 >= xleft;
   for i := 0 to n-1 do begin
      x2 := p1[i].x;
      y2 := p1[i].y;
      inside2 := x2 >= xleft;
      if inside1 <> inside2 then begin
         p2[m].y := y2 + round((y1-y2)/(x1-x2)*(xleft-x2));
         p2[m].x := xleft;
         m := m + 1;
      end;   
      if inside2 then begin
         p2[m] := p1[i];
         m := m + 1;
      end;   
      x1 := x2;
      y1 := y2;
      inside1 := inside2;
   end;
end;

procedure ClipRight(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
var
   i                    : integer;
   inside1, inside2     : Boolean;
   x1, y1, x2, y2       : integer;
begin
   m := 0;
   x1 := p1[n-1].x; y1 := p1[n-1].y;
   inside1 := x1 <= xright;
   for i := 0 to n-1 do begin
      x2 := p1[i].x; y2 := p1[i].y;
      inside2 := x2 <= xright;
      if inside1 <> inside2 then begin
         p2[m].y := y2 + Trunc((y1-y2)/(x1-x2)*(xright-x2));
         p2[m].x := xright;
         m := m + 1;
      end;
      if inside2 then begin
         p2[m] := p1[i];
         m:=m + 1;
      end;
      x1 := x2;
      y1 := y2;
      inside1 := inside2;
   end;
end;

procedure ClipTop(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
var
   i                    : integer;
   inside1, inside2     : Boolean;
   x1, y1, x2, y2       : integer;
begin
   m := 0;
   x1 := p1[n-1].x; y1 := p1[n-1].y;
   inside1 := y1 >= ytop;
   for i := 0 to n-1 do begin
      x2 := p1[i].x; y2 := p1[i].y;
      inside2 := y2 >= ytop;
      if inside1 <> inside2 then begin
         p2[m].x := x1 + round((x2-x1)/(y2-y1)*(ytop-y1));
         p2[m].y := ytop;
         m := m + 1;
      end;
      if inside2 then begin
         p2[m] := p1[i];
         m:=m + 1;
      end;
      x1 := x2;
      y1 := y2;
      inside1 := inside2;
   end;
end;

procedure ClipBottom(n: integer; p1: tPoly; var m: integer; var p2: tPoly);
var
   i                    : integer;
   inside1, inside2     : Boolean;
   x1, y1, x2, y2       : integer;
begin
   m := 0;
   x1 := p1[n-1].x;
   y1 := p1[n-1].y;
   inside1 := y1 <= ybottom;
   for i := 0 to n-1 do begin
      x2 := p1[i].x; y2 := p1[i].y;
      inside2 := y2 <= ybottom;
      if inside1 <> inside2 then begin
         p2[m].x := x1 + round((x2-x1)/(y2-y1)*(ybottom-y1));
         p2[m].y := ybottom;
         m := m + 1;
      end;
      if inside2 then begin
         p2[m] := p1[i];
         m := m + 1;
      end;
      x1 := x2;
      y1 := y2;
      inside1 := inside2;
   end;
end;

procedure FillPoly(n: integer; p: tPoly);
var
   p1, p2: tPoly;
   m1, m2: integer;
   i: integer;
begin
   SetLength(p1, 2*n);
   SetLength(p2, 2*n);
//   for i := 0 to n-1 do begin
//      p1[i].x := p[i].x + xleft;
//      p1[i].y := p[i].y + ytop;
//   end;   
   ClipLeft(n, p, m2, p2);  // Вместо p1 поставил p
   if m2 > 0 then begin
      ClipTop(m2, p2, m1, p1);
      if m1 > 0 then begin
         ClipRight(m1, p1, m2, p2);
         if m2 > 0 then begin
            ClipBottom(m2, p2, m1, p1);
            if m1 > 0 then
               DrawFillPoly(m1, p1);
         end;
      end;
   end;   
end;

begin
   SetColor(Black);
   SetBkColor(White);
   ClearDevice;
   SetViewPort(0, 0, GetMaxX, GetMaxY);
end.

   