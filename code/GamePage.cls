VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "GamePage"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'======================================
'   页面绘制器
    Dim Page As GPage
    Private Type ColorData
        r As Long
        g As Long
        b As Long
    End Type
    Private Type PosData
        X As Long
        y As Long
    End Type
    Private Type two048Data
        data As Integer '0 = Empty , 1 = X2 , 3 = /2
        power As Integer
        Color As Long
        OldPos As PosData
        CoverPos As PosData
        FadeTime As Long
        FadeStyle As Integer
    End Type
    Dim PowerColor(11) As Long
    Dim Map(0 To 4, 0 To 4) As two048Data
    Dim Score As Long, HighScore As Long
    Dim NewRecordTime As Long, StartTime As Long
    Private Const MapWidth As Integer = 4
'======================================
Public Function GetTwoPower(n As Integer) As Integer
    If n <> 0 Then GetTwoPower = Math.Log(n) / Math.Log(2)
End Function
Public Function ToTimeStr(t As Long) As String
    t = t / 1000
    ToTimeStr = Int(t / 60) & ":" & format(t Mod 60, "00")
End Function
Public Function max(v1, v2)
    If v1 > v2 Then
        max = v1
    Else
        max = v2
    End If
End Function
Public Sub Clear()
    HighScore = Val(ESave.GetData("HighScore"))
    Erase Map()
    NewRecordTime = 0
    StartTime = GetTickCount
    For X = 0 To 3
        For y = 0 To 3
            Map(X, y).OldPos.X = X
            Map(X, y).OldPos.y = y
        Next
    Next
End Sub
Public Sub RefreshColor()
    Dim X As Long, y As Long, pro As Single
    
    For X = 0 To MapWidth
        For y = 0 To MapWidth
            If Map(X, y).data = 1 Then Map(X, y).Color = argb(255, 255, 152, 0): GoTo Skips
            If Map(X, y).data = 3 Then Map(X, y).Color = argb(255, 128, 128, 128): GoTo Skips
             
            Map(X, y).power = GetTwoPower(Map(X, y).data)
            pro = Map(X, y).power / 11
            If pro > 1 Then pro = 1
            '27,175,255
            Select Case pro
                Case Is <= 0.3
                    pro = pro / 0.3
                    Map(X, y).Color = argb(255, 236 + (51 - 236) * pro, 240 + (203 - 240) * pro, 241 + (186 - 241) * pro)
                Case Is <= 0.6
                    pro = pro / 0.6
                    Map(X, y).Color = argb(255, 236 + (27 - 236) * pro, 240 + (175 - 240) * pro, 241 + (255 - 241) * pro)
                Case Is <= 1
                    pro = pro / 1
                    Map(X, y).Color = argb(255, 236 + (250 - 236) * pro, 240 + (74 - 240) * pro, 241 + (37 - 241) * pro)
            End Select
Skips:
        Next
    Next
End Sub
Public Sub RandomMap(Count As Long)
    Dim data As Integer
    
    Randomize
    
    data = 2
    If Int(Rnd * 5) = 4 Then data = 4
    If Int(Rnd * 50) = 25 Then data = 1
    If Int(Rnd * 60) = 30 Then data = 3
    
    Dim Quan(0 To MapWidth, 0 To MapWidth) As Single
    
    Dim X As Integer, y As Integer
    
    For X = 0 To MapWidth
        For y = 0 To MapWidth
            If Map(X, y).data = 0 Then Quan(X, y) = Rnd
        Next
    Next
    
    Dim MaxQ As Single, cx As Integer, cy As Integer
    
    For X = 0 To MapWidth
        For y = 0 To MapWidth
            If MaxQ < Quan(X, y) Then
                MaxQ = Quan(X, y)
                cx = X: cy = y
            End If
        Next
    Next
    
    If MaxQ <> 0 Then
        Map(cx, cy).data = data
        Map(cx, cy).FadeTime = GetTickCount + 400
        'Map(cx, cy).OldPos.X = MapWidth / 2
        'Map(cx, cy).OldPos.y = -2
        Map(cx, cy).FadeStyle = 2
    End If
    
    Count = Count - 1
    
    Call RefreshColor
    
    If Count > 0 Then Call RandomMap(Count)
End Sub
Public Sub PushBlocks(XForward As Integer, YForward As Integer)
    Dim X As Long, y As Long, Moveable As Boolean

    For X = 0 To MapWidth
        For y = 0 To MapWidth
            Map(X, y).OldPos.X = X
            Map(X, y).OldPos.y = y
            Map(X, y).CoverPos.X = X
            Map(X, y).CoverPos.y = y
        Next
    Next

    Dim cx As Long, cy As Long, CX2 As Long, CY2 As Long
    If XForward <> 0 Then
        Moveable = True
        Do While Moveable
            Moveable = False
            For y = 0 To MapWidth
                For X = IIf(XForward < 0, 0, MapWidth) To IIf(XForward < 0, MapWidth - 1, 0 + 1) Step -XForward
                    cx = -1
                    If (Map(X, y).data = 1 And Map(X - XForward, y).data <> 0) Or (Map(X, y).data = 3 And Map(X - XForward, y).data > 2) Then
                        cx = X: cy = y: CX2 = X - XForward: CY2 = y
                    End If
                    If (Map(X - XForward, y).data = 1 And Map(X, y).data <> 0) Or (Map(X - XForward, y).data = 3 And Map(X, y).data > 2) Then
                        CX2 = X: CY2 = y: cx = X - XForward: cy = y
                    End If
                    If cx <> -1 And Map(CX2, CY2).data <> 1 And Map(CX2, CY2).data <> 3 Then
                        Score = Score + Map(CX2, CY2).data
                        
                        Map(cx, cy).data = Map(CX2, CY2).data * IIf(Map(cx, cy).data = 1, 2, 0.5)
                        
                        Map(cx, cy).FadeTime = GetTickCount
                        Map(cx, cy).FadeStyle = 1
                        
                        Map(cx, cy).CoverPos = Map(CX2, CY2).CoverPos
                        Map(CX2, CY2).CoverPos.X = X - XForward
                        Map(CX2, CY2).CoverPos.y = y
                        
                        Map(CX2, CY2).data = 0
                        Moveable = True
                        GoTo Skip1
                    End If
                    
                    If Map(X, y).data = Map(X - XForward, y).data And Map(X, y).data <> 0 And Map(X, y).data <> 1 And Map(X, y).data <> 3 Then
                        Score = Score + Map(X, y).data
                    
                        Map(X, y).data = Map(X, y).data * 2
                        
                        Map(X, y).FadeTime = GetTickCount
                        Map(X, y).FadeStyle = 1
                        
                        Map(X, y).CoverPos = Map(X - XForward, y).CoverPos
                        Map(X - XForward, y).CoverPos.X = X - XForward
                        Map(X - XForward, y).CoverPos.y = y
                        
                        Map(X - XForward, y).data = 0
                        Moveable = True
                    Else
                        If Map(X, y).data = 0 And Map(X - XForward, y).data <> 0 Then
                            Map(X, y).data = Map(X - XForward, y).data
                            Map(X, y).OldPos = Map(X - XForward, y).OldPos
                            Map(X - XForward, y).OldPos.X = X - XForward
                            Map(X - XForward, y).OldPos.y = y
                            Map(X - XForward, y).FadeTime = 0
                            Map(X, y).FadeStyle = 0
                            
                            Map(X, y).FadeTime = GetTickCount
                            Map(X - XForward, y).data = 0
                            Moveable = True
                        End If
                    End If
Skip1:
                Next
            Next
            If Not Moveable Then Exit Do
        Loop
        Call RefreshColor
        Call RandomMap(1)
    End If
    
    If YForward <> 0 Then
        Moveable = True
        Do While Moveable
            Moveable = False
            For X = 0 To MapWidth
                For y = IIf(YForward < 0, 0, MapWidth) To IIf(YForward < 0, MapWidth - 1, 0 + 1) Step -YForward
                    cx = -1
                    If (Map(X, y).data = 1 And Map(X, y - YForward).data <> 0) Or (Map(X, y).data = 3 And Map(X, y - YForward).data > 2) Then
                        cx = X: cy = y: CX2 = X: CY2 = y - YForward
                    End If
                    If (Map(X, y - YForward).data = 1 And Map(X, y).data <> 0) Or (Map(X, y - YForward).data = 3 And Map(X, y).data > 2) Then
                        cx = X: cy = y - YForward: CX2 = X: CY2 = y
                    End If
                    If cx <> -1 And Map(CX2, CY2).data <> 1 And Map(CX2, CY2).data <> 3 Then
                        Score = Score + Map(CX2, CY2).data
                        
                        Map(cx, cy).data = Map(CX2, CY2).data * IIf(Map(cx, cy).data = 1, 2, 0.5)
                        
                        Map(cx, cy).FadeTime = GetTickCount
                        Map(cx, cy).FadeStyle = 1
                        
                        Map(cx, cy).CoverPos = Map(CX2, CY2).CoverPos
                        Map(CX2, CY2).CoverPos.X = X - XForward
                        Map(CX2, CY2).CoverPos.y = y
                        
                        Map(CX2, CY2).data = 0
                        Moveable = True
                        GoTo Skip2
                    End If
                    
                    If Map(X, y).data = Map(X, y - YForward).data And Map(X, y).data <> 0 And Map(X, y).data <> 1 And Map(X, y).data <> 3 Then
                        Score = Score + Map(X, y).data
                    
                        Map(X, y).data = Map(X, y).data * 2
                        
                        Map(X, y).CoverPos = Map(X, y - YForward).CoverPos
                        Map(X, y - YForward).CoverPos.X = X
                        Map(X, y - YForward).CoverPos.y = y - YForward
                        
                        Map(X, y).FadeTime = GetTickCount
                        Map(X, y).FadeStyle = 1
                        
                        Map(X, y - YForward).data = 0
                        Moveable = True
                    Else
                        If Map(X, y).data = 0 And Map(X, y - YForward).data <> 0 Then
                            Map(X, y).data = Map(X, y - YForward).data
                            Map(X, y).OldPos = Map(X, y - YForward).OldPos
                            Map(X, y - YForward).OldPos.X = X
                            Map(X, y - YForward).OldPos.y = y - YForward
                            Map(X, y - YForward).FadeTime = 0
                            Map(X, y).FadeStyle = 0
                            
                            Map(X, y).FadeTime = GetTickCount
                            Map(X, y - YForward).data = 0
                            Moveable = True
                        End If
                    End If
Skip2:
                Next
            Next
            If Not Moveable Then Exit Do
        Loop
        Call RefreshColor
        If Rnd >= 0.4 Then Call RandomMap(1)
    End If
    
    If Score > HighScore Then
        HighScore = Score
        ESave.PutData "HighScore", Score
        If NewRecordTime = 0 Then
            ECore.NewTransform transHighLight, 500
            NewRecordTime = GetTickCount
        End If
    End If
End Sub
Public Sub Update()
    '游戏每一帧的过程（绘制过程请放在此处）
    
    'Page.Clear argb(255, 32, 32, 50)

    'Page.Paint 0, 0, 0, GW + 1, 40, argb(255, 76, 76, 76)

    'Page.DrawImage "bg.jpg", 0, 0

    Page.Paint 0, 0, 0, GW + 1, GH + 1, argb(255, 32, 32, 32)
    
    Dim posX(MapWidth, MapWidth) As Long, posY(MapWidth, MapWidth) As Long, proMap(MapWidth, MapWidth) As Single
    Dim X As Long, y As Long, Color As Long
    Dim MapFWidth As Long
    Dim pro As Single
    
    MapFWidth = (60 * MapWidth + 50)
    Page.Paint 2, GW / 2, GH / 2, MapFWidth + 70, MapFWidth + 70, argb(255, 64, 64, 72), Radius:=32, pos:=posOnCenter
    
    For X = 0 To MapWidth
        For y = 0 To MapWidth
            posX(X, y) = GW / 2 - MapFWidth / 2 + 60 * X
            posY(X, y) = GH / 2 - MapFWidth / 2 + 60 * y
            'Map(X, y).data = 2048
            If Map(X, y).FadeTime <> 0 Then
                pro = Cubic((GetTickCount - Map(X, y).FadeTime) / IIf(Map(X, y).FadeStyle = 0, 500, 1000), 0, 1, 1, 1)
                If pro < 0 Then pro = 0.001
                If pro > 1 Then pro = 1: Map(X, y).FadeTime = 0
                proMap(X, y) = pro
                'If Map(X, y).FadeStyle = 1 Then
                 '   posX(X, y) = GW / 2 - MapFWidth / 2 + 60 * X
                 '   posY(X, y) = GH / 2 - MapFWidth / 2 + 60 * y
                'Else
                    posX(X, y) = GW / 2 - MapFWidth / 2 + 60 * (Map(X, y).OldPos.X + (X - Map(X, y).OldPos.X) * pro)
                    posY(X, y) = GH / 2 - MapFWidth / 2 + 60 * (Map(X, y).OldPos.y + (y - Map(X, y).OldPos.y) * pro)
                'End If
                
            End If
        Next
    Next
    
    Dim cColor(3) As Byte, DrawColor As Long
    
    For X = 0 To MapWidth
        For y = 0 To MapWidth
            'Page.Paint 1, posX(X, y), posY(X, y), 50, 50, argb(100, 236, 240, 241)
            If Map(X, y).data <> 0 Then
                Color = Map(X, y).Color
                
                CopyMemory cColor(0), Color, 4
                If Map(X, y).FadeStyle = 2 And proMap(X, y) <> 0 Then
                    cColor(3) = proMap(X, y) * 255
                End If
                
                CopyMemory DrawColor, cColor(0), 4
                
                Page.Paint 1, posX(X, y), posY(X, y), 50, 50, DrawColor
                
                 If Map(X, y).FadeStyle = 1 And proMap(X, y) <> 0 Then
                    Dim pro2 As Single
                    pro2 = Cubic((GetTickCount - Map(X, y).FadeTime) / 1000, 0, 1, 1, 1)
                    If pro2 > 1 Then pro2 = 1
                    
                    CopyMemory cColor(0), Color, 4
                    cColor(3) = 255 - pro2 * 255
                    CopyMemory DrawColor, cColor(0), 4
                    
                    Page.Paint 1, GW / 2 - MapFWidth / 2 + 60 * (Map(X, y).CoverPos.X + (X - Map(X, y).CoverPos.X) * pro2), _
                                GH / 2 - MapFWidth / 2 + 60 * (Map(X, y).CoverPos.y + (y - Map(X, y).CoverPos.y) * pro2), _
                                50, 50, DrawColor

                    Page.Paint 1, posX(X, y) + 25, posY(X, y) + 25, 50 + 100 * proMap(X, y), 50 + 100 * proMap(X, y), argb(255 - 255 * proMap(X, y), 255, 255, 255), size:=6 - 6 * proMap(X, y), style:=1, pos:=posOnCenter
                End If
                
                Dim textPro As Single
                textPro = IIf(proMap(X, y) = 0, 1, proMap(X, y))
                If Map(X, y).FadeStyle = 0 Then textPro = 1
                
                Select Case Map(X, y).data
                    Case 1
                        Page.Writes "x 2", posX(X, y) + 25, posY(X, y) + 25 - 14, 20, argb(textPro * 255, 27, 27, 27), align:=StringAlignmentCenter
                    Case 3
                        Page.Writes "÷ 2", posX(X, y) + 25, posY(X, y) + 25 - 14, 20, argb(textPro * 255, 27, 27, 27), align:=StringAlignmentCenter
                    Case Else
                        Page.Writes Map(X, y).data, posX(X, y) + 25, posY(X, y) + 25 - 14, 20, argb(textPro * 255, 27, 27, 27), align:=StringAlignmentCenter
                End Select
                
                If Map(X, y).FadeStyle = 1 And proMap(X, y) <> 0 Then
                    Page.Paint 1, posX(X, y), posY(X, y), 50, 50, argb(255 - 255 * proMap(X, y), 255, 255, 255)
                End If
                
            End If
        Next
    Next

    Page.Paint 2, GW / 2, 100, 250, 40, argb(255, 27, 175, 255), pos:=posOnCenter, Radius:=40
    Page.Writes "得分   " & Score, GW / 2, 86, 20, argb(255, 242, 242, 242), align:=StringAlignmentCenter, style:=FontStyleBold
    Page.Writes ToTimeStr(GetTickCount - StartTime), GW / 2, 140, 18, argb(200, 242, 242, 242), align:=StringAlignmentCenter, style:=FontStyleBold
    
    If Page.ShowColorButton(0, GW - 150, GH - 80, 100, 40, "重玩", argb(255, 255, 255, 255), argb(50, 255, 255, 255), argb(255, 27, 175, 255), size:=18) = 3 Then
        Call Clear
        Call RandomMap(5)
        Score = 0
    End If
    
    If GetTickCount - NewRecordTime <= 5000 Then
        Page.Writes "新纪录 !!!", GW / 2, GH - 100, 18, argb(255, 255, 0, 0), align:=StringAlignmentCenter, style:=FontStyleBold
    End If
End Sub
Public Sub KeyUp(Code As Integer)
    'If Page.ShowColorButton(1, GW / 2 - MapFWidth - 48 / 2, GH / 2 - 48 / 2, 48, 48, "←", argb(255, 255, 255, 255), argb(120, 27, 175, 255), argb(255, 27, 175, 255), size:=18) = 3 Then
        'Call PushBlocks(-1, 0)
    'End If
    'If Page.ShowColorButton(1, GW / 2 + MapFWidth - 48 / 2, GH / 2 - 48 / 2, 48, 48, "→", argb(255, 255, 255, 255), argb(120, 27, 175, 255), argb(255, 27, 175, 255), size:=18) = 3 Then
        'Call PushBlocks(1, 0)
    'End If
    'If Page.ShowColorButton(1, GW / 2 - 48 / 2, GH / 2 - MapFWidth - 48 / 2, 48, 48, "↑", argb(255, 255, 255, 255), argb(120, 27, 175, 255), argb(255, 27, 175, 255), size:=18) = 3 Then
        'Call PushBlocks(0, -1)
    'End If
    'If Page.ShowColorButton(1, GW / 2 - 48 / 2, GH / 2 + MapFWidth - 48 / 2, 48, 48, "↓", argb(255, 255, 255, 255), argb(120, 27, 175, 255), argb(255, 27, 175, 255), size:=18) = 3 Then
        'Call PushBlocks(0, 1)
    'End If
    
    Select Case Code
        Case vbKeyLeft, vbKeyA: Call PushBlocks(-1, 0)
        Case vbKeyRight, vbKeyD: Call PushBlocks(1, 0)
        Case vbKeyUp, vbKeyW: Call PushBlocks(0, -1)
        Case vbKeyDown, vbKeyS: Call PushBlocks(0, 1)
    End Select
End Sub
Public Sub Wheel(Direction As Integer, Depth As Single)
    '鼠标滚轮事件
    'Direction:方向，Depth：深度
End Sub
Public Sub AnimationMsg(ID As String, msg As String)
    '动画消息接收
End Sub
Public Sub Enter()
    '页面进入事件
End Sub
Public Sub Leave()
    '页面离开事件
End Sub
Public Sub Gotfocus()
    '窗口取得焦点事件
End Sub
Public Sub Lostfocus()
    '窗口失去焦点事件
End Sub
Public Sub AnimationDone(ID As Integer)
    '动画播放结束事件
    'id：结束的动画ID
End Sub
Private Sub Class_Initialize()
    '创建页面绘制器
    Set Page = New GPage
    Page.Create Me
    '导入游戏资源
    'Page.Res.NewImages App.Path & "\assets\background", GW, GH
    'Page.Res.ApplyBlurEffect "bg.jpg", 40, 0
    '创建页面
    ECore.Add Page, "GamePage"
    Call Clear
    Call RandomMap(5)
    
    PowerColor(1) = argb(255, 211, 245, 208)
    PowerColor(2) = argb(255, 167, 216, 197)
End Sub
