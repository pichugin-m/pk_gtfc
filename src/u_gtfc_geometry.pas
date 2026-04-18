unit u_gtfc_geometry;

interface

uses math;

type
   TGTFPoint = record
    X, Y, Z :Integer;
   end;

   TGTFRect = record
    ID            :String;
    TopLeftX,
    TopLeftY,
    TopLeftZ      :Integer;
    BottomRightX,
    BottomRightY,
    BottomRightZ  :Integer;
   end;

   TArrayGTFPoint     = Array of TGTFPoint;
   TArrayGTFRect      = Array of TGTFRect;

function PointInRect2D(PointX,PointY,TopLeftX,TopLeftY,
  BottomRightX,BottomRightY: Integer): Boolean;
//Поиск точки пересечения линий
function isLinesHasIntersection(X1,Y1,X2,Y2,X3,Y3,X4,Y4: Integer): Boolean;

function isEqual2DPoint(A1,A2:TGTFPoint):Boolean;
function isEqual3DPoint(A1,A2:TGTFPoint):Boolean;
function isCross2DLines(A1,B1,A2,B2:TGTFPoint):integer;

function GetCoordinatesFromGTFRect(RectUseCoordinates:TGTFRect;
  index:integer):TGTFPoint;
//Проверка координаты внутри одной из областей массива
function IsCoordinatesInRectArray(var ArrayUseCoordinates:TArrayGTFRect;
  X,Y:Integer):boolean;
//Проверка координаты внутри одной из областей массива
function IsXCoordinatesInRectArray(var ArrayUseCoordinates:TArrayGTFRect;
  X:Integer):boolean;
//Функция возвращает индекс если прямоугольные области пересекаются
function isCrossARectAndBRect(ARect,BRect:TGTFRect):integer;
//Функция возвращает индекс расположения координаты XY относительно
//заданной прямоугольной области
function IsCoordinatesInRect(AUseCoordinates:TGTFRect; X,Y:Integer):Integer;
//Функция сравнивает два массива прямоугольных областей и
// если один из эл-тов набора накладывается на другой, то возвращается True
function IsCoordinatesArrayInRectArray(var MainArrayCoordinates,
  SecondaryArrayCoordinates:TArrayGTFRect):boolean;

implementation

function PointInRect2D(PointX,PointY,TopLeftX,TopLeftY,
  BottomRightX,BottomRightY: Integer): Boolean;
begin
  Result:=False;
  if (PointX>=TopLeftX)and(PointX<=BottomRightX) then
  begin
      if (PointY>=TopLeftY)and(PointY<=BottomRightY) then
      begin
          Result:=True;
      end;
  end;
end;

function isLinesHasIntersection(X1,Y1,X2,Y2,X3,Y3,X4,Y4: Integer): Boolean;
var
  denominator:Integer;
  ua,ub: Integer;
begin
  denominator := ((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1));
  if(denominator = 0) then
		  // прямые паралельны
		  // Если и числитель и знаменатель равны нулю, то прямые совпадают.
		  Result:=false
  else begin
      ua:=((x4-x3)*(y1-y3)-(y4-y3)*(x1-x3)) div ((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1));
      ub:=((x2-x1)*(y1-y3)-(y2-y1)*(x1-x3)) div ((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1));

      Result:=true;
		  // Если u12 и u34 на промежутке [0,1], значит отрезки имеют точку пересечения
		  if(ua < 0)or (ua > 1) then // точка пересечения не на отрезке p1, p2
			  Result:=false;
		  if(ub < 0 )or(ub > 1) then // точка пересечения не на отрезке p3, p4
			  Result:=false;
  end;
end;

function isEqual2DPoint(A1,A2:TGTFPoint):Boolean;
begin
     Result:=False;
     if (A1.X=A2.X)and(A1.Y=A2.Y)then
     Result:=True;
end;

function isEqual3DPoint(A1,A2:TGTFPoint):Boolean;
begin
     Result:=False;
     if (A1.X=A2.X)and(A1.Y=A2.Y)and(A1.Z=A2.Z)then
     Result:=True;
end;

function isCross2DLines(A1,B1,A2,B2:TGTFPoint):integer;
begin
   Result:=0;

   if isEqual2DPoint(A1,A2)or isEqual2DPoint(A1,B2)then
   begin
     Result:=2;
     if isEqual2DPoint(B1,A2)or isEqual2DPoint(B1,B2)then
     begin
        Result:=3;
     end;
   end
   else if isEqual2DPoint(B1,A2)or isEqual2DPoint(B1,B2)then
   begin
     Result:=2;   // Имеют общую точку
     if isEqual2DPoint(A1,A2)or isEqual2DPoint(A1,B2)then
     begin
        Result:=3; // Линии совпадают
     end;
   end;

   if Result=0 then
   begin
      if isLinesHasIntersection(A1.X,A1.Y,B1.X,B1.Y,A2.X,A2.Y,B2.X,B2.Y)then
      Result:=1;  //Пересекаются
   end;

   if Result=1 then
   begin
      if ((A1.X=B1.X)and(A2.X=B2.X)and(A1.X=A2.X)) or
      ((A1.Y=B1.Y)and(A2.Y=B2.Y)and(A1.Y=A2.Y))then
      Result:=4; //Параллельны
   end;

end;

//Проверка координаты внутри одной из областей массива
function IsCoordinatesInRectArray(var ArrayUseCoordinates:TArrayGTFRect;
  X,Y:Integer):boolean;
var
   i:integer;
begin
   Result:=False;
   for i:=high(ArrayUseCoordinates) downto low(ArrayUseCoordinates) do
   begin
       if IsCoordinatesInRect(ArrayUseCoordinates[i], X,Y)=1 then
       begin
          Result:=True;
          break;
       end;
   end;
end;

//Проверка координаты внутри одной из областей массива
function IsXCoordinatesInRectArray(var ArrayUseCoordinates:TArrayGTFRect;
  X:Integer):boolean;
var
   i:integer;
begin
   Result:=False;
   for i:=high(ArrayUseCoordinates) downto low(ArrayUseCoordinates) do
   begin
    if (ArrayUseCoordinates[i].TopLeftX>X)or
    (ArrayUseCoordinates[i].BottomRightX>X) then
    begin
      Result:=True;
      break;
    end;
   end;
end;

function GetCoordinatesFromGTFRect(RectUseCoordinates:TGTFRect;
  index:integer):TGTFPoint;
begin
   if index=1 then
   begin
     Result.X:=RectUseCoordinates.TopLeftX;
     Result.Y:=RectUseCoordinates.TopLeftY;
     Result.Z:=RectUseCoordinates.TopLeftZ;
   end
   else if index=2 then
   begin
     Result.X:=RectUseCoordinates.BottomRightX;
     Result.Y:=RectUseCoordinates.TopLeftY;
     Result.Z:=RectUseCoordinates.TopLeftZ;
   end
   else if index=3 then
   begin
     Result.X:=RectUseCoordinates.BottomRightX;
     Result.Y:=RectUseCoordinates.BottomRightY;
     Result.Z:=RectUseCoordinates.TopLeftZ;
   end
   else if index=4 then
   begin
     Result.X:=RectUseCoordinates.TopLeftX;
     Result.Y:=RectUseCoordinates.BottomRightY;
     Result.Z:=RectUseCoordinates.TopLeftZ;
   end
   else if index=5 then
   begin
     Result.X:=RectUseCoordinates.TopLeftX;
     Result.Y:=RectUseCoordinates.TopLeftY;
     Result.Z:=RectUseCoordinates.BottomRightZ;
   end
   else if index=6 then
   begin
     Result.X:=RectUseCoordinates.BottomRightX;
     Result.Y:=RectUseCoordinates.TopLeftY;
     Result.Z:=RectUseCoordinates.BottomRightZ;
   end
   else if index=7 then
   begin
     Result.X:=RectUseCoordinates.BottomRightX;
     Result.Y:=RectUseCoordinates.BottomRightY;
     Result.Z:=RectUseCoordinates.BottomRightZ;
   end
   else if index=8 then
   begin
     Result.X:=RectUseCoordinates.TopLeftX;
     Result.Y:=RectUseCoordinates.BottomRightY;
     Result.Z:=RectUseCoordinates.BottomRightZ;
   end;
end;

//Функция возвращает индекс если прямоугольные области пересекаются
function isCrossARectAndBRect(ARect,BRect:TGTFRect):integer;
var
   A1,B1,
   A2,B2:TGTFPoint;
   i1,k1,
   i2,k2:integer;
begin
     Result:=0;
     for i1:=1 to 4 do
     begin
       A1:=GetCoordinatesFromGTFRect(ARect,i1);
       for k1:=1 to 4 do
       begin
          if i1<>k1 then
          begin
               B1:=GetCoordinatesFromGTFRect(ARect,k1);
               for i2:=1 to 4 do
               begin
                 A2:=GetCoordinatesFromGTFRect(BRect,i2);
                 for k2:=1 to 4 do
                 begin
                    if i2<>k2 then
                    begin
                         B2:=GetCoordinatesFromGTFRect(BRect,k2);
                         //проверка пересечения
                         if isCross2DLines(A1,B1,A2,B2)=1 then
                         begin
                            inc(Result);
                         end;
                    end;
                 end;
               end;
          end;
       end;
     end;
end;

//Функция возвращает индекс расположения координаты XY относительно
//заданной прямоугольной области
function IsCoordinatesInRect(AUseCoordinates:TGTFRect; X,Y:Integer):Integer;
begin
   Result:=0;
   //Попадание внутрь контура
   if (AUseCoordinates.TopLeftX<X)and(AUseCoordinates.BottomRightX>X) then
   begin
       if (AUseCoordinates.TopLeftY>Y)and(AUseCoordinates.BottomRightY<Y) then
       begin
          Result:=1;
       end;
   end;
   //Попадание на верхнюю грань
   if (AUseCoordinates.TopLeftX<X)and(AUseCoordinates.BottomRightX>X) then
   begin
       if (AUseCoordinates.TopLeftY=Y) then
       begin
          Result:=2;
       end;
   end;
   //Попадание на нижную грань
   if (AUseCoordinates.TopLeftX<X)and(AUseCoordinates.BottomRightX>X) then
   begin
       if (AUseCoordinates.BottomRightY=Y) then
       begin
          Result:=4;
       end;
   end;
   //Попадание на левую грань
   if (AUseCoordinates.TopLeftX=X) then
   begin
       if (AUseCoordinates.TopLeftY>Y)and(AUseCoordinates.BottomRightY<Y) then
       begin
          Result:=5;
       end;
   end;
   //Попадание на правую грань
   if (AUseCoordinates.BottomRightX=X) then
   begin
       if (AUseCoordinates.TopLeftY>Y)and(AUseCoordinates.BottomRightY<Y) then
       begin
          Result:=3;
       end;
   end;

   if (AUseCoordinates.TopLeftX=X) then
   begin
       if (AUseCoordinates.TopLeftY=Y) then
       begin
          Result:=6;  //угол 1
       end;
   end;

   if (AUseCoordinates.BottomRightX=X) then
   begin
       if (AUseCoordinates.TopLeftY=Y) then
       begin
          Result:=7;  //угол 2
       end;
   end;

   if (AUseCoordinates.BottomRightX=X) then
   begin
       if (AUseCoordinates.BottomRightY=Y) then
       begin
          Result:=8; //угол 3
       end;
   end;

   if (AUseCoordinates.TopLeftX=X) then
   begin
       if (AUseCoordinates.BottomRightY=Y) then
       begin
          Result:=9;  //угол 4
       end;
   end;

end;

//Функция сравнивает два массива прямоугольных областей и
// если один из эл-тов набора накладывается на другой, то возвращается True
function IsCoordinatesArrayInRectArray(var MainArrayCoordinates,
  SecondaryArrayCoordinates:TArrayGTFRect):boolean;
var
   i,k,r,j,n,
   j1,j2,j3,j4:integer;
   X,Y:Integer;
   Crd:TGTFPoint;
begin
   Result:=False;
   for i:=high(SecondaryArrayCoordinates) downto low(SecondaryArrayCoordinates) do
   begin
     for k:=high(MainArrayCoordinates) downto low(MainArrayCoordinates) do
     begin
       r:=0;
       for n:=1 to 4 do
       begin
         Crd:=GetCoordinatesFromGTFRect(SecondaryArrayCoordinates[i],n);
         X:=Crd.X;
         Y:=Crd.Y;
         j:=IsCoordinatesInRect(MainArrayCoordinates[k], X,Y);
         case n of
              1:j1:=j;
              2:j2:=j;
              3:j3:=j;
              4:j4:=j;
         end;
         case j of
              1:
              begin
                inc(r);
                inc(r);
                inc(r);
                inc(r);
              end;
              2:begin
                inc(r);
                if (n=1) then inc(r);
              end;
              3:begin
                inc(r);
                if (n=2) then inc(r);
              end;
              4:begin
                inc(r);
                if (n=4) then inc(r);
              end;
              5:begin
                inc(r);
                if (n=1) then inc(r);
              end;
              6:begin
                inc(r);
                if n=1 then inc(r);
              end;
              7:begin
                inc(r);
                if n=2 then inc(r);
              end;
              8:begin
                inc(r);
                if n=3 then inc(r);
              end;
              9:begin
                inc(r);
                if n=4 then inc(r);
              end;
         end;
       end;

       //Пересечение плоскостей

       if (r>2) then  //Общий случай пересечений
       begin
          Result:=True;
          break;
       end
       else if (r>0) then//Часный случай пересечений
       begin
          if (j1=0)and(j2=0)and(j3=0)and(j4=2) then
          begin
            //Совпадение по левому нижнему углу
            Result:=True;
            break;
          end
          else if (j1=0)and(j2=0)and(j3=0)and(j4=4) then
          begin
            //Совпадение по левому нижнему углу и нижней грани
            Result:=True;
            break;
          end
          else if (j1=0)and(j2=0)and(j3=0)and(j4=9) then
          begin
            //Совпадение по левому нижнему углу
            Result:=True;
            break;
          end
          else if (j1=0)and(j2=6)and(j3=0)and(j4=0) then
          begin
            //Совпадение по правому верхнему углу и левому верхнему
            Result:=True;
            break;
          end;
       end;
     end;
     if Result=True then
     begin
          break
     end;
   end;
end;



end.
