//app.js
//该js是小程序的入口程序，用于创建一个实例，一个小程序有且只有一个。
//时刻明确，js只是获取data，等逻辑控制的。实际界面展现是由wxml控制的。

App({
  onLaunch: function () {

    
    // 获取用户信息
    wx.getSetting({
      success: res => {
        if (res.authSetting['scope.userInfo']) {
          // 已经授权，可以直接调用 getUserInfo 获取头像昵称，不会弹框
          wx.getUserInfo({
            success: res => {
              // 可以将 res 发送给后台解码出 unionId
              this.globalData.userInfo = res.userInfo
            }
          })
        }
        if (res.authSetting['scope.userLocation']) {
          // 已经授权，可以直接调用 getLocation 获取位置信息，不会弹框
          wx.getLocation({
            success: res => {
              this.globalData.location = res
            }
          })
        }
      }
    })
  },
  globalData: {
    userInfo: null,
    location: null
  }
})