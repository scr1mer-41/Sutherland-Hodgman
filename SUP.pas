unit SUP;

interface

uses BGL;


const
   NumberOfPolygonsInArray = 100;


type
   tEdge = record
      head, tail: tPoint;
   end;

   tPolyOfEdges = array of tEdge;
   
   tEvent = record
      coord: integer;
      weight: integer;
   end;
   
   tEvents = array of tEvent;
   
   tPolygons = array of tPoly;
   
   

function Cross(a, b, c, d: tPoint): Boolean;
function IsSimplePoly(p: tPoly): Boolean;
procedure WritePoly(n: integer; var p: tPoly);
procedure SmartFillPoly(n: integer; p: tPoly);
function OnBorder(p: tPoint): Boolean;

implementation

function Scalar(p0, p1, p2: tPoint): integer;
begin
   Scalar := (p1.x - p0.x)*(p2.x - p1.x) + (p1.y - p0.y)*(p2.y - p1.y)
end;

function Orient(a, b, c: tPoint): integer;
begin
   Orient := (b.y - a.y)*(c.x - b.x) - (b.x - a.x)*(c.y - b.y)
end;


function IsClockwise(p: tPoly): Boolean;
var
   i, n: integer;
   sum: longint;
begin
   sum := 0;
   n := p.Length;
   for i := 0 to n-1 do begin
     
      sum := sum + (p[(i+1) mod n].x - p[i].x) * (p[(i+1) mod n].y + p[i].y);
   end;
   IsClockwise := (sum < 0); 
end;


procedure ReversePolygon(var p: tPoly);
var
   i, n: integer;
   temp: tPoint;
begin
   n := p.Length;
   for i := 0 to (n div 2) - 1 do begin
      temp := p[i];
      p[i] := p[n - 1 - i];
      p[n - 1 - i] := temp;
   end;
end;













function OnBorder(p: tPoint): Boolean;
begin
   if (((p.x = GetXRight) or (p.x = GetXLeft)) and (p.y >= GetYTop) and (p.y <= GetYBottom)) or
   (((p.y = GetYTop) or (p.y = GetYBottom)) and (p.x >= GetXLeft) and (p.x <= GetXRight)) then
      OnBorder := True;
end;


procedure SetPixel(var point: tPoint; x, y: integer);
begin
   point.x := x;
   point.y := y;
end;



function Cross(a, b, c, d: tPoint): Boolean; // A != C, A != D, B != C, B != D
var
   orABC, orABD, orCDA, orCDB: integer;
begin
   orABC := Orient(a, b, c);
   orABD := Orient(a, b, d);
   orCDA := Orient(c, d, a);
   orCDB := Orient(c, d, b);
   if (((orABC > 0) and (orABD < 0)) or ((orABC < 0) and (orABD > 0))) and
   (((orCDA > 0) and (orCDB < 0)) or ((orCDA < 0) and (orCDB > 0))) then
      Cross := True
   else 
      Cross := False;
end;

function IsSimplePoly(p: tPoly): Boolean;
   var
      n, i, j: integer;
      p0, p1, p2, p3, vect1, vect2: tPoint;
      res: Boolean;
begin
  
   n := p.Length;
   IsSimplePoly := True;
   res := True;

   //Уникальность вершин
   if p.Distinct.Count <> n then begin
      IsSimplePoly := False;
      res := False;
   end;
   
   
   //Наложение вектров
   for i := 0 to n-1 do begin
      if (Scalar(p[i], p[(i+1) mod n], p[(i+2) mod n]) < 0) and 
      (Orient(p[i], p[(i+1) mod n], p[(i+2) mod n]) = 0) then begin
         IsSimplePoly := False;
         res := False;
      end;
   end;
   
   if n < 3 then begin
      IsSimplePoly := False;
      res := False;
   end;
   
   if (n > 3) and res then begin
      i := 0;
      while ((i mod n) <> n-2) and res do begin
         p0 := p[i mod n];
         p1 := p[(i+1) mod n];
         j := (i+2) mod n;
         if (i mod 2) = 0 then
            while ((j mod n) <> n-1) and res do begin
               p2 := p[j mod n];
               p3 := p[(j+1) mod n];
               if Cross(p0, p1, p2, p3) then begin
                  res := False;
                  IsSimplePoly := False;
               end;
               j := (j+1) mod n;
            end
         else
            while ((j mod n) <> 0) and res do begin
               p2 := p[j mod n];
               p3 := p[(j+1) mod n];
               if Cross(p0, p1, p2, p3) then begin
                  res := False;
                  IsSimplePoly := False;
               end;
               j := (j+1) mod n;
            end;
          i := (i + 1) mod n;
      end;
   end
end;



procedure WritePoly(n: integer; var p: tPoly);
var
   i: integer;
begin
   WriteLn;
   WriteLn('Список вершин.');
   WriteLn('Кол-во вершин: ', n);
   WriteLn('Точка  ', '  x  ', '  y  ');
   for i := 0 to n-1 do begin
      WriteLn(i:5, p[i].x:5, p[i].y:5);
   end;
   WriteLn;
end;


procedure SortEvents(var evs: array of tEvent; count: integer);
var
  i, j: integer;
  temp: tEvent;
begin
   if count >= 2 then 
      for i := 0 to count - 2 do
           for j := 0 to count - 2 - i do
              begin
                 if evs[j].coord > evs[j + 1].coord then
                    begin
                       temp := evs[j];
                       evs[j] := evs[j + 1];
                       evs[j + 1] := temp;
                    end;
              end;
end;






procedure RemoveBridgesLeft(mEdges: integer; Edges: tPolyOfEdges;
          var mInside: integer; var EdgesInside: tPolyOfEdges);
          
          
var
   Events: tEvents;
   i, mEvents, cnt: integer;
   
begin
   mEvents := mEdges*2;
   SetLength(Events, mEvents);
   for i := 0 to mEdges-1 do begin
      Events[2*i].coord := Edges[i].head.y;
      Events[2*i+1].coord := Edges[i].tail.y;
      
      Events[2*i].weight := 1;
      Events[2*i+1].weight := -1;
      
      
//      if Edges[i].head.y < Edges[i].tail.y then begin
//         //Events[2*i].coord := Edges[i].head.y;
//         Events[2*i].weight := -1;
//         //Events[2*i+1].coord := Edges[i].tail.y;
//         Events[2*i+1].weight := 1;
//      end
//      else begin
//         //Events[2*i].coord := Edges[i].head.y;
//         Events[2*i].weight := 1;
//         //Events[2*i+1].coord := Edges[i].tail.y;
//         Events[2*i+1].weight := -1;
//      end;
      
      
      
   end;
   
   SortEvents(Events, mEvents);
   cnt := 0;
   for i := 0 to mEvents-2 do begin
      cnt := cnt + Events[i].weight;
      if ((cnt mod 2) <> 0) and (Events[i+1].coord <> Events[i].coord) then begin
         EdgesInside[mInside].head.x := GetXLeft;
         EdgesInside[mInside].tail.x := GetXLeft;
         if cnt < 0 then begin
            //EdgesInside[mInside].head.x := GetXLeft;
            EdgesInside[mInside].head.y := Events[i+1].coord;
            //EdgesInside[mInside].tail.x := GetXLeft;
            EdgesInside[mInside].tail.y := Events[i].coord;
            //mInside := mInside + 1;
         end
         else begin
            //EdgesInside[mInside].head.x := GetXLeft;
            EdgesInside[mInside].head.y := Events[i].coord;
            //EdgesInside[mInside].tail.x := GetXLeft;
            EdgesInside[mInside].tail.y := Events[i+1].coord;
            //mInside := mInside + 1;
         end;
         mInside := mInside + 1;
      end; 
   end;
end;



procedure RemoveBridgesTop(mEdges: integer; Edges: tPolyOfEdges;
          var mInside: integer; var EdgesInside: tPolyOfEdges);
          
          
var
   Events: tEvents;
   i, mEvents, cnt: integer;
   
begin
   mEvents := mEdges*2;
   SetLength(Events, mEvents);
   for i := 0 to mEdges-1 do begin
      Events[2*i].coord := Edges[i].head.x;
      Events[2*i+1].coord := Edges[i].tail.x;
      
      Events[2*i].weight := 1;
      Events[2*i+1].weight := -1;
      
//      if Edges[i].head.x < Edges[i].tail.x then begin
//         //Events[2*i].coord := Edges[i].head.x;
//         Events[2*i].weight := 1;
//         //Events[2*i+1].coord := Edges[i].tail.x;
//         Events[2*i+1].weight := -1;
//      end
//      else begin
//         //Events[2*i].coord := Edges[i].head.x;
//         Events[2*i].weight := -1;
//         //Events[2*i+1].coord := Edges[i].tail.x;
//         Events[2*i+1].weight := 1;
//      end;
      
      
      
   end;
   
   SortEvents(Events, mEvents);
   cnt := 0;
   for i := 0 to mEvents-2 do begin
      cnt := cnt + Events[i].weight;
      if ((cnt mod 2) <> 0) and (Events[i+1].coord <> Events[i].coord) then begin
         EdgesInside[mInside].head.y := GetYTop;
         EdgesInside[mInside].tail.y := GetYTop;
         if cnt < 0 then begin
            EdgesInside[mInside].head.x := Events[i+1].coord;
            //EdgesInside[mInside].head.y := GetYTop;
            EdgesInside[mInside].tail.x := Events[i].coord;
            //EdgesInside[mInside].tail.y := GetYTop;
            //mInside := mInside + 1;
         end
         else begin
            EdgesInside[mInside].head.x := Events[i].coord;
            //EdgesInside[mInside].head.y := GetYTop;
            EdgesInside[mInside].tail.x := Events[i+1].coord;
            //EdgesInside[mInside].tail.y := GetYTop;
            //mInside := mInside + 1;
         end;
         mInside := mInside + 1;
      end;   
   end;
end;






procedure RemoveBridgesRight(mEdges: integer; Edges: tPolyOfEdges;
          var mInside: integer; var EdgesInside: tPolyOfEdges);
          
          
var
   Events: tEvents;
   i, mEvents, cnt: integer;
   
begin
   mEvents := mEdges*2;
   SetLength(Events, mEvents);
   for i := 0 to mEdges-1 do begin
      Events[2*i].coord := Edges[i].head.y;
      Events[2*i+1].coord := Edges[i].tail.y;
      
      Events[2*i].weight := 1;
      Events[2*i+1].weight := -1;
      
//      if Edges[i].head.y < Edges[i].tail.y then begin
//         //Events[2*i].coord := Edges[i].head.y;
//         Events[2*i].weight := 1;
//         //Events[2*i+1].coord := Edges[i].tail.y;
//         Events[2*i+1].weight := -1;
//      end
//      else begin
//         //Events[2*i].coord := Edges[i].head.y;
//         Events[2*i].weight := -1;
//         //Events[2*i+1].coord := Edges[i].tail.y;
//         Events[2*i+1].weight := 1;
//      end;
      
      
      
   end;
   
   SortEvents(Events, mEvents);
   cnt := 0;
   for i := 0 to mEvents-2 do begin
      cnt := cnt + Events[i].weight;
      if ((cnt mod 2) <> 0) and (Events[i+1].coord <> Events[i].coord) then begin
         EdgesInside[mInside].head.x := GetXRight;
         EdgesInside[mInside].tail.x := GetXRight;
         if cnt < 0 then begin
            //EdgesInside[mInside].head.x := GetXRight;
            EdgesInside[mInside].head.y := Events[i+1].coord;
            //EdgesInside[mInside].tail.x := GetXRight;
            EdgesInside[mInside].tail.y := Events[i].coord;
            //mInside := mInside + 1;
         end
         else begin
            //EdgesInside[mInside].head.x := GetXRight;
            EdgesInside[mInside].head.y := Events[i].coord;
            //EdgesInside[mInside].tail.x := GetXRight;
            EdgesInside[mInside].tail.y := Events[i+1].coord;
            //mInside := mInside + 1;
         end;
         mInside := mInside + 1;
      end; 
   end;
end;





procedure RemoveBridgesBottom(mEdges: integer; Edges: tPolyOfEdges;
          var mInside: integer; var EdgesInside: tPolyOfEdges);
          
var
   Events: tEvents;
   i, mEvents, cnt: integer;
   
begin
   mEvents := mEdges*2;
   SetLength(Events, mEvents);
   for i := 0 to mEdges-1 do begin
      Events[2*i].coord := Edges[i].head.x;
      Events[2*i+1].coord := Edges[i].tail.x;
      
      Events[2*i].weight := 1;
      Events[2*i+1].weight := -1;
      
      
//      if Edges[i].head.x < Edges[i].tail.x then begin
//         //Events[2*i].coord := Edges[i].head.x;
//         Events[2*i].weight := -1;
//         //Events[2*i+1].coord := Edges[i].tail.x;
//         Events[2*i+1].weight := 1;
//      end
//      else begin
//         //Events[2*i].coord := Edges[i].head.x;
//         Events[2*i].weight := 1;
//         //Events[2*i+1].coord := Edges[i].tail.x;
//         Events[2*i+1].weight := -1;
//      end;
      
      
      
   end;
   
   SortEvents(Events, mEvents);
   cnt := 0;
   for i := 0 to mEvents-2 do begin
      cnt := cnt + Events[i].weight;
      if ((cnt mod 2) <> 0) and (Events[i+1].coord <> Events[i].coord) then begin
         EdgesInside[mInside].head.y := GetYBottom;
         EdgesInside[mInside].tail.y := GetYBottom;
         if cnt < 0 then begin
            EdgesInside[mInside].head.x := Events[i+1].coord;
            //EdgesInside[mInside].head.y := GetYBottom;
            EdgesInside[mInside].tail.x := Events[i].coord;
            //EdgesInside[mInside].tail.y := GetYBottom;
            //mInside := mInside + 1;
         end
         else begin
            EdgesInside[mInside].head.x := Events[i].coord;
            //EdgesInside[mInside].head.y := GetYBottom;
            EdgesInside[mInside].tail.x := Events[i+1].coord;
            //EdgesInside[mInside].tail.y := GetYBottom;
            //mInside := mInside + 1;
         end;
         mInside := mInside + 1;
      end; 
   end;
end;






procedure CompoundEdges(mInside: integer; EdgesInside: tPolyOfEdges;
                        var mPolygons: integer; var Polygons: tPolygons;
                        var nPoly: array of integer);
var
   EdgesToPoly: tPolyOfEdges;
   Edge: tEdge;
   cnt, i, n, mE: integer;
   Poly: tPoly;
   EdgeMarker: tEdge;
   
begin
   EdgeMarker.head.x := -1;
   EdgeMarker.head.y := -1;
   EdgeMarker.tail.x := -1;
   EdgeMarker.tail.y := -1;
   
   SetLength(EdgesToPoly, mInside);
   while (cnt <> mInside) do begin
      
      mE := 0;
      Edge := EdgeMarker;
      while Edge = EdgeMarker do begin
         for i := 0 to mInside-1 do begin
            if (EdgesInside[i] <> EdgeMarker) and (Edge = EdgeMarker) then begin
               Edge := EdgesInside[i];
               EdgesInside[i] := EdgeMarker;
            end;
         end;
      end;
      

      EdgesToPoly[mE] := Edge;
      mE := mE + 1;
      cnt := cnt + 1;
      
      while (EdgesToPoly[mE-1].tail <> EdgesToPoly[0].head) do begin
         for i := 0 to mInside-1 do begin
            if (EdgesInside[i] <> EdgeMarker) and (EdgesInside[i].head = EdgesToPoly[mE-1].tail) then begin
               EdgesToPoly[mE] := EdgesInside[i];
               mE := mE + 1;
               EdgesInside[i] := EdgeMarker;
               cnt := cnt + 1;
            end;
         end;
      end;
      
      SetLength(Poly, mE);
      for i := 0 to mE-1 do begin
         Poly[i] := EdgesToPoly[i].head;
      end;
      
      Polygons[mPolygons] := Poly;
      nPoly[mPolygons] := mE;
      mPolygons := mPolygons + 1;
      SetLength(Poly, 0);
   end;
end;


















procedure PostProcessing(n: integer; p0: tPoly; var mPolygons: integer;
                            var Polygons: tPolygons; var nPoly: array of integer);
var
   marker: tPoint;
   p1, p2: tPoly;
   m1, m2, i, mleft, mtop, mright, mbottom, mInside: integer;
   EdgesInside, left, top, right, bottom: tPolyOfEdges;
   
   Events1: tEvents;
   me: integer;
   
   cnt: integer;
   
begin
   SetLength(p1, n);
   SetLength(p2, n);
   
   p1[0] := p0[0];
   m1 := 1;
   for i := 1 to n-1 do begin
      if p0[i] <> p0[i-1] then begin
         p1[i] := p0[i];
         m1 := m1 + 1;
      end;
   end;
   
   if p1[0] = p1[m1-1] then begin
      for i := 0 to m1-2 do begin
         p1[i] := p1[i+1]
      end;
      m1 := m1 - 1;
   end;
   
   
   m2 := 0;
   for i := 0 to m1 - 1 do begin
      if Orient(p1[i], p1[(i+1) mod m1], p1[(i+2) mod m1]) <> 0 then begin
         p2[m2] := p1[(i+1) mod m1];
         m2 := m2 + 1;
      end;
   end;
   
   
   
   SetLength(EdgesInside, m2);
   SetLength(left, m2);
   SetLength(top, m2);
   SetLength(right, m2);
   SetLength(bottom, m2);
   
   for i := 0 to m2-1 do begin
      if (p2[i].x = GetXLeft) and (p2[(i+1) mod m2].x = GetXLeft) then begin
         left[mleft].head.x := p2[i].x;
         left[mleft].head.y := p2[i].y;
         left[mleft].tail.x := p2[(i+1) mod m2].x;
         left[mleft].tail.y := p2[(i+1) mod m2].y;
         mleft := mleft + 1;
      end
      else if (p2[i].y = GetYTop) and (p2[(i+1) mod m2].y = GetYTop) then begin
         top[mtop].head.x := p2[i].x;
         top[mtop].head.y := p2[i].y;
         top[mtop].tail.x := p2[(i+1) mod m2].x;
         top[mtop].tail.y := p2[(i+1) mod m2].y;
         mtop := mtop + 1;
      end
      else if (p2[i].x = GetXRight) and (p2[(i+1) mod m2].x = GetXRight) then begin
         right[mright].head.x := p2[i].x;
         right[mright].head.y := p2[i].y;
         right[mright].tail.x := p2[(i+1) mod m2].x;
         right[mright].tail.y := p2[(i+1) mod m2].y;
         mright := mright + 1;
      end
      else if (p2[i].y = GetYBottom) and (p2[(i+1) mod m2].y = GetYBottom) then begin
         bottom[mbottom].head.x := p2[i].x;
         bottom[mbottom].head.y := p2[i].y;
         bottom[mbottom].tail.x := p2[(i+1) mod m2].x;
         bottom[mbottom].tail.y := p2[(i+1) mod m2].y;
         mbottom := mbottom + 1;
      end
      else begin
         EdgesInside[mInside].head.x := p2[i].x;
         EdgesInside[mInside].head.y := p2[i].y;
         EdgesInside[mInside].tail.x := p2[(i+1) mod m2].x;
         EdgesInside[mInside].tail.y := p2[(i+1) mod m2].y;
         mInside := mInside + 1;
      end;
      
   end;
   
   RemoveBridgesLeft(mleft, left, mInside, EdgesInside);
   RemoveBridgesTop(mtop, top, mInside, EdgesInside);
   RemoveBridgesRight(mright, right, mInside, EdgesInside);
   RemoveBridgesBottom(mbottom, bottom, mInside, EdgesInside);
   
   CompoundEdges(mInside, EdgesInside, mPolygons, Polygons, nPoly);
end;





procedure SmartFillPoly(n: integer; p: tPoly);
var
   p1, p2: tPoly;
   m1, m2: integer;
   i: integer;
   mPolygons: integer;
   Polygons: tPolygons;
   nPoly: array of integer;
   
begin
   SetLength(nPoly, NumberOfPolygonsInArray);
   SetLength(Polygons, NumberOfPolygonsInArray);

   if IsSimplePoly(p) then begin
     
      
      if not IsClockwise(p) then begin
         ReversePolygon(p);
      end;
     
     
      SetLength(p1, 2*n);
      SetLength(p2, 2*n);
      
      WriteLn('Исходный многоугольник: ');
      WritePoly(n, p);
      
      WriteLn('Отсечение слева...');
      ClipLeft(n, p, m2, p2); // Вместо p1 поставил p
      WritePoly(m2, p2);
      if m2 > 0 then begin
         WriteLn('Отсечение сверху...');
         ClipTop(m2, p2, m1, p1);
         WritePoly(m1, p1);
         if m1 > 0 then begin
            WriteLn('Отсечение справа...');
            ClipRight(m1, p1, m2, p2);
            WritePoly(m2, p2);
            if m2 > 0 then begin
               WriteLn('Отсечение снизу...');
               ClipBottom(m2, p2, m1, p1);
               WritePoly(m1, p1);
               if m1 > 0 then begin
                  PostProcessing(m1, p1, mPolygons, Polygons, nPoly);
                  if mPolygons <> 0 then
                     for i := 0 to mPolygons-1 do begin
                       WritePoly(nPoly[i], Polygons[i]);
                       DrawFillPoly(nPoly[i], Polygons[i]);
                     end;
               end;
            end;
         end;
      end;
   end;
end;






begin
   
end.