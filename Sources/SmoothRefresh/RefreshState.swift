//
//  RefreshState.swift
//  SmoothRefresh
//
//  Created by W Zh on 2025/8/29.
//

import Foundation

public enum RefreshState {
    
    /// 组件处于空闲状态，可以手动下拉刷新或者上拉加载更多
    case idle
    /// 正在拖拽，已经离开了初始位置，但还没有到达刷新的临界值
    case pulling
    /// 正在拖拽，并且拖拽程度已经达到或者超过触发的临界值
    case readyToRefresh
    /// 正在刷新
    case refreshing
    /// 刷新完毕，即将重新回到初始状态
    case completed
    /// 没有其他数据
    case noMoreData
}
