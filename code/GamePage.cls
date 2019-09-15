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
        x As Long
        y As Long
    End Type
    Private Type two048Data
        data As Integer '0 = Empty , 1 = X2 , 3 = /2
        Color As ColorData
        ColorN As ColorData
        OldPos As PosData
        FadeTime As Long
    End Type
    Dim Map(0 To 3, 0 To 3) As two048Data
'======================================
Public Function GetTwoPower(n As Integer) As Integer
    GetTwoPower = Math.Log(n) / Math.Log(2)
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
End Sub
Public Sub RandomMap(Count As Long)
    Dim data As Integer
    
    Randomize
    
    data = 2
    If Int(Rnd * 5) = 4 Then data = 4
    If Int(Rnd * 20) = 10 Then data = 1
    If Int(Rnd * 30) = 14 Then data = 3
    
    Dim Quan(0 To 3, 0 To 3) As Single
    
    Dim x As Integer, y As Integer
    
    For x = 0 To 3
        For y = 0 To 3
            If Map(x, y).data = 0 Then Quan(x, y) = Rnd
        Next
    Next
    
    Dim MaxQ As Single, cx As Integer, cy As Integer
    
    For x = 0 To 3
        For y = 0 To 3
            If MaxQ < Quan(x, y) Then
                MaxQ = Quan(x, y)
                cx = x: cy = y
            End If
        Next
    Next
    
    If MaxQ <> 0 Then
        Map(cx, cy).data = data
    End If
    
    Count = Count - 1
    
    If Count > 0 Then Call RandomMap(Count)
End Sub
Public Sub PushBlocks(XForward As Integer, YForward As Integer)
    
End Sub
Public Sub Update()
    '游戏每一帧的过程（绘制过程请放在此处）
    
    Page.Clear '清空画布

    Dim posX(3, 3) As Long, posY(3, 3) As Long
    Dim x As Long, y As Long
    
    For x = 0 To 3
        For y = 0 To 3
            posX(x, y) = GW / 2 - 230 / 2 + 60 * x
            posY(x, y) = GH / 2 - 230 / 2 + 60 * y
        Next
    Next
    
    For x = 0 To 3
        For y = 0 To 3
            If Map(x, y).data <> 0 Then
                Page.Paint 1, posX(x, y), posY(x, y), 50, 50, argb(255, 0, 176, 240)
                Select Case Map(x, y).data
                    Case 1
                    Page.Writes "x 2", posX(x, y) + 25, posY(x, y) + 25 - 15, 24, argb(255, 255, 255, 255), align:=StringAlignmentCenter
                    Case 3
                    Page.Writes "÷ 2", posX(x, y) + 25, posY(x, y) + 25 - 15, 24, argb(255, 255, 255, 255), align:=StringAlignmentCenter
                    Case Else
                    Page.Writes Map(x, y).data, posX(x, y) + 25, posY(x, y) + 25 - 15, 24, argb(255, 255, 255, 255), align:=StringAlignmentCenter
                End Select
            Else
                Page.Paint 1, posX(x, y), posY(x, y), 50, 50, argb(255, 180, 180, 180)
            End If
        Next
    Next
    
    If Mouse.button = 1 Then
        Call Clear
        Call RandomMap(3)
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
    Call RandomMap(3)
    '===============================================
    '   如果需要添加动画，请放置在此处
    
    '===============================================
End Sub
