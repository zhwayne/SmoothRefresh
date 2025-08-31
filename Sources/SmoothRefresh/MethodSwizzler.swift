//
//  MethodSwizzler.swift
//  SmoothRefresh
//
//  Created by W Zh on 2025/8/31.
//

import Foundation
import ObjectiveC.runtime

class MethodSwizzler {
    
    /// 交换实例方法
    /// - Parameters:
    ///   - targetClass: 目标类
    ///   - originalSelector: 原始方法的选择器
    ///   - swizzledSelector: 交换方法的选择器
    static func swizzleInstanceMethod(targetClass: AnyClass,
                                      originalSelector: Selector,
                                      swizzledSelector: Selector) {
        // 获取交换方法
        guard let swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector) else {
            print("Swizzled method not found: \(swizzledSelector)")
            return
        }
        
        // 尝试给目标类添加原始方法（注意：class_getInstanceMethod会沿着继承链查找，
        // 但这里使用class_addMethod仅在目标类自身不存在该方法时才会成功添加）
        let didAddMethod = class_addMethod(targetClass,
                                           originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            // 如果添加成功，说明目标类本身没有实现该方法，
            // 尝试从父类获取原始实现
            if let superClass = class_getSuperclass(targetClass),
               let superMethod = class_getInstanceMethod(superClass, originalSelector) {
                class_replaceMethod(targetClass,
                                    swizzledSelector,
                                    method_getImplementation(superMethod),
                                    method_getTypeEncoding(superMethod))
            } else {
                // 如果父类也没有实现，则提供一个默认的空实现，避免调用 nil 导致崩溃
                let emptyIMP: IMP = imp_implementationWithBlock({ (_self: AnyObject) in
                    print("Warning: \(originalSelector) not implemented.")
                } as @convention(block) (AnyObject) -> Void)
                class_replaceMethod(targetClass,
                                    swizzledSelector,
                                    emptyIMP,
                                    method_getTypeEncoding(swizzledMethod))
            }
        } else if let originalMethod = class_getInstanceMethod(targetClass, originalSelector) {
            // 如果目标类中已经存在原始方法，直接交换实现
            method_exchangeImplementations(originalMethod, swizzledMethod)
        } else {
            print("Failed to retrieve original method for \(originalSelector)")
        }
    }
}
