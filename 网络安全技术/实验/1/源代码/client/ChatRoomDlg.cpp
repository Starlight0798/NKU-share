// ChatRoomDlg.cpp: 实现文件
//

#include "pch.h"
#include "framework.h"
#include "ChatRoom.h"
#include "ChatRoomDlg.h"
#include "afxdialogex.h"
#include <string>

#pragma comment(lib, "ws2_32.lib")
#define WM_UPDATE_CHAT_MSG (WM_USER + 1)

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// 获取当前时间信息
static inline CString GetCurrTime() {
	CTime time = CTime::GetCurrentTime();
	CString strTime = time.Format("%Y-%m-%d %H:%M:%S");
	return strTime;
}

// 用于应用程序“关于”菜单项的 CAboutDlg 对话框

class CAboutDlg : public CDialogEx {
public:
	CAboutDlg();

	// 对话框数据
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_ABOUTBOX };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持

	// 实现
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(IDD_ABOUTBOX) {
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX) {
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()

// CChatRoomDlg 对话框

CChatRoomDlg::CChatRoomDlg(CWnd* pParent /*=nullptr*/)
	: CDialogEx(IDD_CHATROOM_DIALOG, pParent) {
	m_hIcon = AfxGetApp()->LoadIcon(IDI_ICON1);
}

void CChatRoomDlg::DoDataExchange(CDataExchange* pDX) {
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CChatRoomDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BUTTON_EXIT, &CChatRoomDlg::OnBnClickedButtonExit)
	ON_BN_CLICKED(IDC_BUTTON_SEND, &CChatRoomDlg::OnBnClickedButtonSend)
	ON_BN_CLICKED(IDC_BUTTON_CONNECT, &CChatRoomDlg::OnBnClickedButtonConnect)
	ON_MESSAGE(WM_UPDATE_CHAT_MSG, &CChatRoomDlg::OnUpdateChatMsg)
	ON_WM_CLOSE()
END_MESSAGE_MAP()

// CChatRoomDlg 消息处理程序

BOOL CChatRoomDlg::OnInitDialog() {
	CDialogEx::OnInitDialog();

	// 将“关于...”菜单项添加到系统菜单中。

	// IDM_ABOUTBOX 必须在系统命令范围内。
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != nullptr) {
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty()) {
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// 设置此对话框的图标。  当应用程序主窗口不是对话框时，框架将自动
	//  执行此操作
	SetIcon(m_hIcon, TRUE);				// 设置大图标
	SetIcon(m_hIcon, FALSE);			// 设置小图标

	//ShowWindow(SW_MAXIMIZE);
	//ShowWindow(SW_MINIMIZE);

	//显示在屏幕中央
	CenterWindow();
	ShowWindow(SW_SHOW);

	// TODO: 在此添加额外的初始化代码
	GetDlgItem(IDC_IPADDRESS)->SetWindowText(_T("127.0.0.1"));
	GetDlgItem(IDC_EDIT_PORT)->SetWindowText(_T("12720"));
	GetDlgItem(IDC_DES_KEY)->SetWindowText(_T("133457799BBCDFF1"));
	GetDlgItem(IDC_DES_KEY)->EnableWindow(FALSE);

	return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

void CChatRoomDlg::OnSysCommand(UINT nID, LPARAM lParam) {
	if ((nID & 0xFFF0) == IDM_ABOUTBOX) {
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else {
		CDialogEx::OnSysCommand(nID, lParam);
	}
}

// 如果向对话框添加最小化按钮，则需要下面的代码
//  来绘制该图标。  对于使用文档/视图模型的 MFC 应用程序，
//  这将由框架自动完成。

void CChatRoomDlg::OnPaint() {
	if (IsIconic()) {
		CPaintDC dc(this); // 用于绘制的设备上下文

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// 使图标在工作区矩形中居中
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// 绘制图标
		dc.DrawIcon(x, y, m_hIcon);
	}
	else {
		CDialogEx::OnPaint();
	}
}

//当用户拖动最小化窗口时系统调用此函数取得光标
//显示。
HCURSOR CChatRoomDlg::OnQueryDragIcon() {
	return static_cast<HCURSOR>(m_hIcon);
}

// 退出客户端
void CChatRoomDlg::OnBnClickedButtonExit() {
	if (MessageBox("确定要退出聊天室？", "提示", MB_YESNO | MB_DEFBUTTON2) == IDYES) {
		// 首先关闭套接字，将导致接收消息的线程退出其循环
		if (SockClient != INVALID_SOCKET) {
			// 向服务器发送一个退出消息
			std::vector<uint8_t> exitMsg = des->encrypt(DES::strToVec("exit"));
			send(SockClient, reinterpret_cast<const char*>(exitMsg.data()), exitMsg.size(), 0);
			closesocket(SockClient);
			SockClient = INVALID_SOCKET;
		}

		// 关闭线程
		if (hThread != NULL) {
			CloseHandle(hThread);
			hThread = NULL;
		}

		delete des;
		WSACleanup();  // 结束 Winsock 使用
		EndDialog(0);  // 关闭对话框
	}
}

// 发送消息
void CChatRoomDlg::OnBnClickedButtonSend() {
	bool isConnect = true;
	CString strMsg;
	GetDlgItemText(IDC_EDIT_INPUT, strMsg);
	if (strMsg.IsEmpty()) {
		MessageBox("不能发送空消息！");
		return;
	}
	else if (SockClient == INVALID_SOCKET) {
		MessageBox("请先连接服务器！");
		isConnect = false;
	}
	// 连接服务器已发送用户名，不需要再发送用户名
	else {
		// 加密消息
		std::vector<uint8_t> encMsg = des->encrypt(DES::strToVec(strMsg.GetBuffer()));
		if (send(SockClient, reinterpret_cast<const char*>(encMsg.data()), encMsg.size(), 0) == SOCKET_ERROR) {
			MessageBox("发送消息失败！");
			isConnect = false;
		}
	}

	// 发送消息失败
	if (isConnect == false) {
		// 如果控件不可编辑，那么转为可编辑
		if (GetDlgItem(IDC_IPADDRESS)->IsWindowEnabled() == FALSE) {
			GetDlgItem(IDC_IPADDRESS)->EnableWindow(TRUE);
			GetDlgItem(IDC_EDIT_PORT)->EnableWindow(TRUE);
			GetDlgItem(IDC_EDIT_NAME)->EnableWindow(TRUE);
		}
	}
}

// 连接服务器
void CChatRoomDlg::OnBnClickedButtonConnect() {
	// 判断是否已经连接
	if (SockClient != INVALID_SOCKET) {
		MessageBox("已经连接到服务器！");
		return;
	}

	// 初始化 Winsock
	WSADATA wsaData = { 0 };
	if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
		MessageBox("初始化Winsock失败！");
		return;
	}

	// 获取IP和端口
	CString strIP, strPort;
	GetDlgItemText(IDC_EDIT_PORT, strPort);
	CIPAddressCtrl* pIP = (CIPAddressCtrl*)GetDlgItem(IDC_IPADDRESS);
	{
		BYTE nf1, nf2, nf3, nf4;
		pIP->GetAddress(nf1, nf2, nf3, nf4);
		strIP.Format("%d.%d.%d.%d", nf1, nf2, nf3, nf4);
	}

	// 获取DES密钥
	GetDlgItemText(IDC_DES_KEY, key);
	if (key.GetLength() == 16) {
		des = new DES(key.GetBuffer());
	}
	else {
		MessageBox("无效的DES密钥！(应为16个16进制数)");
		WSACleanup();
		return;
	}

	// 获取用户名
	GetDlgItemText(IDC_EDIT_NAME, UserName);

	// 判断上述信息合法
	if (strIP.IsEmpty() || strPort.IsEmpty() || UserName.IsEmpty()) {
		MessageBox("请填写完整信息！");
		WSACleanup();
		return;
	}

	// 创建套接字
	SockClient = socket(AF_INET, SOCK_STREAM, 0);
	if (SockClient == INVALID_SOCKET) {
		MessageBox("创建套接字失败！");
		WSACleanup();
		return;
	}

	// 设置服务器地址
	sockaddr_in serverAddr;
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(_ttoi(strPort));
	if (inet_pton(AF_INET, CT2A(strIP.GetBuffer()), &(serverAddr.sin_addr)) != 1) {
		MessageBox("无效的IP地址！");
		WSACleanup();
		return;
	}

	// 连接服务器
	if (connect(SockClient, (SOCKADDR*)&serverAddr, sizeof(serverAddr)) == SOCKET_ERROR) {
		MessageBox("连接服务器失败！");
		closesocket(SockClient);
		SockClient = INVALID_SOCKET;
		WSACleanup();
		return;
	}

	// 发送用户名给服务器
	std::vector<uint8_t> encName = des->encrypt(DES::strToVec(UserName.GetBuffer()));
	send(SockClient, reinterpret_cast<const char*>(encName.data()), encName.size(), 0);
	MessageBox("连接成功!");

	// IP, 端口，用户名，不再可编辑
	GetDlgItem(IDC_IPADDRESS)->EnableWindow(FALSE);
	GetDlgItem(IDC_EDIT_PORT)->EnableWindow(FALSE);
	GetDlgItem(IDC_EDIT_NAME)->EnableWindow(FALSE);

	// 创建一个新线程来持续接收来自服务器的消息
	hThread = CreateThread(NULL, 0, ReceiveMessages, this, 0, NULL);
}

// 接收服务器消息线程函数
DWORD WINAPI CChatRoomDlg::ReceiveMessages(LPVOID pParam) {
	CChatRoomDlg* pThis = reinterpret_cast<CChatRoomDlg*>(pParam);
	std::vector<uint8_t> buffer(BUFFER_SIZE);
	// 循环接收服务器消息
	while (true) {
		buffer.clear();
		buffer.resize(BUFFER_SIZE);
		// 约定: 服务器发送的消息格式为: 用户名:消息
		int ret = recv(pThis->SockClient, reinterpret_cast<char*>(buffer.data()), BUFFER_SIZE, 0);
		if (ret <= 0) {
			pThis->MessageBox("与服务器断开连接！");
			closesocket(pThis->SockClient);
			pThis->SockClient = INVALID_SOCKET;
			return 0;
		}
		buffer.resize(ret);
		// 将接收到的消息解密并发送给主线程
		std::string decmsg = DES::vecToStr(pThis->des->decrypt(buffer));
		pThis->PostMessage(WM_UPDATE_CHAT_MSG, 0, (LPARAM)new CString(decmsg.c_str()));
	}
	closesocket(pThis->SockClient);
	pThis->SockClient = INVALID_SOCKET;
	delete pThis->des;
	return 0;
}

// 更新聊天消息(主线程)
LRESULT CChatRoomDlg::OnUpdateChatMsg(WPARAM wParam, LPARAM lParam) {
	CString* pStrMsg = (CString*)lParam;
	int separatorPos = -1;
	separatorPos = pStrMsg->Find(":");
	// 切分用户名和消息
	CString senderName, actualMessage;
	if (separatorPos != -1) {
		senderName = pStrMsg->Left(separatorPos);
		actualMessage = pStrMsg->Mid(separatorPos + 1);
	}
	else {
		actualMessage = *pStrMsg;
	}
	PrintMsg(senderName, actualMessage);
	delete pStrMsg;
	return 0;
}

// 将信息和时间打印到聊天框
void CChatRoomDlg::PrintMsg(const CString& Name, const CString& strMsg) {
	CEdit* pEdit = (CEdit*)GetDlgItem(IDC_EDIT_CHAT);

	// 获取编辑框的全部内容
	CString currentText;
	pEdit->GetWindowText(currentText);

	// 构建输出消息
	CString outMsg = "";
	if (!currentText.IsEmpty() && currentText[currentText.GetLength() - 1] != '\n') {
		outMsg += "\n";
	}
	outMsg += GetCurrTime() + " " + Name + ": " + strMsg + "\n";

	// 将消息添加到编辑框
	pEdit->SetSel(-1, -1);
	pEdit->ReplaceSel(outMsg);
}

void CChatRoomDlg::OnClose() {
	OnBnClickedButtonExit();
}

// 重写预处理消息函数
BOOL CChatRoomDlg::PreTranslateMessage(MSG* pMsg) {
	// 捕获回车键
	if (pMsg->message == WM_KEYDOWN && pMsg->wParam == VK_RETURN) {
		return TRUE;
	}
	// 其他情况下，调用基类的函数
	return CDialog::PreTranslateMessage(pMsg);
}