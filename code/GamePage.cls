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
        Y As Long
    End Type
    Private Type two048Data
        data As Integer '0 = Empty , 1 = X2 , 3 = /2
        power As Integer
        Color As Long
        OldPos As PosData
        FadeTime As Long
    End Type
    Dim PowerColor(11) As Long
    Dim Map(0 To 3, 0 To 3) As two048Data
'======================================
Public Function GetTwoPower(n As Integer) As Integer
    If n <> 0 Then GetTwoPower = Math.Log(n) / Math.Log(2)
End Function
Public Function max(v1, v2)
    If v1 > v2 Then
        max = v1
    Else
        max = v2
    End If
End Function
Public Sub Clear()
    Erase Map()
    For X = 0 To 3
        For Y = 0 To 3
            Map(X, Y).OldPos.X = X
            Map(X, Y).OldPos.Y = Y
        Next
    Next
End Sub
Public Sub RefreshColor()
    Dim X As Long, Y As Long, pro As Single
    
    For X = 0 To 3
        For Y = 0 To 3
            Map(X, Y).power = GetTwoPower(Map(X, Y).data)
            pro = Map(X, Y).power / 11
            Map(X, Y).Color = argb(100 + (100 - 255) * pro, 236 + (51 - 236) * pro, 240 + (203 - 240) * pro, 241 + (186 - 241) * pro)
        Next
    Next
End Sub
Public Sub RandomMap(Count As Long)
    Dim data As Integer
    
    Randomize
    
    data = 2
    If Int(Rnd * 5) = 4 Then data = 4
    If Int(Rnd * 20) = 10 Then data = 1
    If Int(Rnd * 30) = 14 Then data = 3
    
    Dim Quan(0 To 3, 0 To 3) As Single
    
    Dim X As Integer, Y As Integer
    
    For X = 0 To 3
        For Y = 0 To 3
            If Map(X, Y).data = 0 Then Quan(X, Y) = Rnd
        Next
    Next
    
    Dim MaxQ As Single, cx As Integer, cy As Integer
    
    For X = 0 To 3
        For Y = 0 To 3
            If MaxQ < Quan(X, Y) Then
                MaxQ = Quan(X, Y)
                cx = X: cy = Y
            End If
        Next
    Next
    
    If MaxQ <> 0 Then
        Map(cx, cy).data = data
    End If
    
    Count = Count - 1
    
    Call RefreshColor
    
    If Count > 0 Then Call RandomMap(Count)
End Sub
Public Sub PushBlocks(XForward As Integer, YForward As Integer)
    Dim X As Long, Y As Long, Moveable As Boolean
    Dim MoveMap(3, 3) As PosData, tempPos As PosData
    
    For X = 0 To 3
        For Y = 0 To 3
            Map(X, Y).OldPos.X = X
            Map(X, Y).OldPos.Y = Y
        Next
    Next
    
    For X = 0 To 3
        For Y = 0 To 3
            With MoveMap(X, Y)
                .X = X
                .Y = Y
            End With
        Next
    Next

    If XForward <> 0 Then
        Moveable = True
        Do While Moveable
            Moveable = False
            For Y = 0 To 3
                For X = IIf(XForward < 0, 0, 3) To IIf(XForward < 0, 3 - 1, 0 + 1) Step -XForward
                    '4 2 0 2
                    'First Step : 0 4 2 2
                    'Second Step : 0 0 4 4
                    'Third Step : 0 0 0 8
                    If Map(X, Y).data = Map(X - XForward, Y).data And Map(X, Y).data <> 0 Then
                        Map(X, Y).data = Map(X, Y).data * 2
                        Map(X, Y).OldPos = Map(X - XForward, Y).OldPos
                        Map(X - XForward, Y).data = 0
                        Moveable = True
                    Else
                        If Map(X, Y).data = 0 And Map(X - XForward, Y).data <> 0 Then
                            Map(X, Y).data = Map(X - XForward, Y).data
                            Map(X, Y).OldPos = Map(X - XForward, Y).OldPos
                            Map(X - XForward, Y).data = 0
                            Moveable = True
                        End If
                    End If
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
            For X = 0 To 3
                For Y = IIf(YForward < 0, 0, 3) To IIf(YForward < 0, 3 - 1, 0 + 1) Step -YForward
                    '4 2 0 2
                    'First Step : 0 4 2 2
                    'Second Step : 0 0 4 4
                    'Third Step : 0 0 0 8
                    If Map(X, Y).data = Map(X, Y - YForward).data And Map(X, Y).data <> 0 Then
                        Map(X, Y).data = Map(X, Y).data * 2
                        Map(X, Y).OldPos = Map(X, Y - YForward).OldPos
                        Map(X, Y - YForward).data = 0
                        Moveable = True
                    Else
                        If Map(X, Y).data = 0 And Map(X, Y - YForward).data <> 0 Then
                            Map(X, Y).data = Map(X, Y - YForward).data
                            Map(X, Y).OldPos = Map(X, Y - YForward).OldPos
                            Map(X, Y - YForward).data = 0
                            Moveable = True
                        End If
                    End If
                Next
            Next
            If Not Moveable Then Exit Do
        Loop
        Call RefreshColor
        Call RandomMap(1)
    End If
End Sub
Public Sub Update()
    '游戏每一帧的过程（绘制过程请放在此处）
    
    Page.Clear argb(255, 32, 32, 50)

    'Page.Paint 0, 0, 0, GW + 1, 40, argb(255, 76, 76, 76)

    Dim posX(3, 3) As Long, posY(3, 3) As Long
    Dim X As Long, Y As Long, Color As Long
    
    For X = 0 To 3
        For Y = 0 To 3
            posX(X, Y) = GW / 2 - 230 / 2 + 60 * X
            posY(X, Y) = GH / 2 - 230 / 2 + 60 * Y
        Next
    Next
    
    For X = 0 To 3
        For Y = 0 To 3
            If Map(X, Y).data <> 0 Then
                Color = Map(X, Y).Color
                If Map(X, Y).data = 1 Then Color = argb(255, 0, 176, 240)
                If Map(X, Y).data = 3 Then Color = argb(255, 255, 84, 57)
                
                Page.Paint 1, posX(X, Y), posY(X, Y), 50, 50, Color
                
                Select Case Map(X, Y).data
                    Case 1
                        Page.Writes "x 2", posX(X, Y) + 25, posY(X, Y) + 25 - 15, 24, argb(255, 27, 27, 27), align:=StringAlignmentCenter
                    Case 3
                        Page.Writes "÷ 2", posX(X, Y) + 25, posY(X, Y) + 25 - 15, 24, argb(255, 27, 27, 27), align:=StringAlignmentCenter
                    Case Else
                        Page.Writes Map(X, Y).data, posX(X, Y) + 25, posY(X, Y) + 25 - 15, 24, argb(255, 27, 27, 27), align:=StringAlignmentCenter
                        'Page.Writes Map(X, Y).OldPos.X & "," & Map(X, Y).OldPos.Y, posX(X, Y) + 25, posY(X, Y) + 25 - 15, 24, argb(255, 27, 27, 27), align:=StringAlignmentCenter
                End Select
            Else
                Page.Paint 1, posX(X, Y), posY(X, Y), 50, 50, argb(100, 236, 240, 241)
            End If
        Next
    Next
    
    If Page.ShowColorButton(1, GW / 2 - 300 - 64 / 2, GH / 2 - 64 / 2, 64, 64, "←", argb(255, 255, 255, 255), argb(180, 255, 84, 57), argb(255, 255, 84, 57), size:=18) = 3 Then
        Call PushBlocks(-1, 0)
    End If
    If Page.ShowColorButton(1, GW / 2 + 300 - 64 / 2, GH / 2 - 64 / 2, 64, 64, "→", argb(255, 255, 255, 255), argb(180, 255, 84, 57), argb(255, 255, 84, 57), size:=18) = 3 Then
        Call PushBlocks(1, 0)
    End If
    If Page.ShowColorButton(1, GW / 2 - 64 / 2, GH / 2 - 200 - 64 / 2, 64, 64, "↑", argb(255, 255, 255, 255), argb(180, 255, 84, 57), argb(255, 255, 84, 57), size:=18) = 3 Then
        Call PushBlocks(0, -1)
    End If
    If Page.ShowColorButton(1, GW / 2 - 64 / 2, GH / 2 + 200 - 64 / 2, 64, 64, "↓", argb(255, 255, 255, 255), argb(180, 255, 84, 57), argb(255, 255, 84, 57), size:=18) = 3 Then
        Call PushBlocks(0, 1)
    End If
    
    If Mouse.button = 1 Then
        'Call Clear
        'Call RandomMap(3)
    End If
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
    Page.Res.NewImages App.Path & "\assets"
    '创建页面
    ECore.Add Page, "GamePage"
    Call Clear
    Call RandomMap(3)
    
    PowerColor(1) = argb(255, 211, 245, 208)
    PowerColor(2) = argb(255, 167, 216, 197)
End Sub
