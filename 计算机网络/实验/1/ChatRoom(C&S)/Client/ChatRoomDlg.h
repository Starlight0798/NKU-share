
// ChatRoomDlg.h: 头文件
//

#pragma once

#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS

#include <WinSock2.h>


// CChatRoomDlg 对话框
class CChatRoomDlg : public CDialogEx
{
// 构造
public:
	CChatRoomDlg(CWnd* pParent = nullptr);	// 标准构造函数

// 对话框数据
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_CHATROOM_DIALOG };
#endif

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV 支持


// 实现
protected:
	HICON m_hIcon;

	// 生成的消息映射函数
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnBnClickedButtonExit();						// 退出按钮
	afx_msg void OnBnClickedButtonSend();						// 发送按钮
	afx_msg void OnBnClickedButtonConnect();					// 连接按钮

	// 添加变量和函数
	static constexpr UINT BufferSize = 1024;					// 缓冲区大小
	virtual void OnClose();										// 重写关闭窗口函数
	SOCKET SockClient = INVALID_SOCKET;							// 客户端套接字
	HANDLE hThread = NULL;										// 线程句柄
	CString UserName;											// 用户名
	void PrintMsg(const CString& Name, const CString& strMsg);	// 打印消息
	static DWORD WINAPI ReceiveMessages(LPVOID pParam);			// 接收消息线程函数
	LRESULT OnUpdateChatMsg(WPARAM wParam, LPARAM lParam);		// 更新聊天消息
};
