# HGCLockScreenUtil

监听锁屏/解锁的消息，无论是否越狱环境都可以使用。

使用：

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化
    [HGCLockScreenUtil observe];
	
    return YES;
}
```

```
// 不想用的时候可以清理掉
[HGCLockScreenUtil unobserve];
```

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenLockStateDidChangedNoti:) name:HGCLockScreenStateDidChangeNotification object:nil];

- (void)handleScreenLockStateDidChangedNoti:(NSNotification *)noti {
    NSLog(@"vc ** 当前锁屏状态：isLocked = %zd", [HGCLockScreenUtil isScreenLocked]);
}
```

Demo 代码引用了：[xindawndev/RecordMyScreen-iOS10](https://github.com/xindawndev/RecordMyScreen-iOS10)

可以测试 App 后台被挂起和 App 后台长驻（用 Airplay 录屏时，App 长驻后台）的情况。
