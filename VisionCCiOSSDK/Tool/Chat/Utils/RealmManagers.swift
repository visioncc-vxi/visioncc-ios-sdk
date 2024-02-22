//
//  RealmManagers.swift
//  YLBaseChat
//
//  Created by yl on 17/5/11.
//  Copyright © 2017年 yl. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class RealmManagers{
    
    // 单例
    static let shared = RealmManagers()
    
    /// <#Description#>
    private init(){
        /// https://www.jianshu.com/p/7b7924fa6290
        let _rconfig = RLMRealmConfiguration.default()
        _rconfig.schemaVersion = UInt64(31)//每次添加或修改字段就会更改表结构 因此每次添加或修改字段需要设置新的版本号
        _rconfig.migrationBlock = { (_migration,oldSchemaVersion) in
            if oldSchemaVersion < _rconfig.schemaVersion {
                //什么都不做，Realm会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
            }
        }
        
        //告诉其默认使用这个新的配置
        RLMRealmConfiguration.setDefault(_rconfig)
        RLMRealm.default()
    }
    
    // 提交事务
    func commitWrite(_ complated:() -> ()){
        do{
            let realm = try? Realm()
            try realm?.write {
                complated()
            }
        }
        catch(let _error){
            debugPrint(_error)
        }
    }
    
    // 同步保存数据
    func addSynModel(_ obj:Object){
        do {
            if let realm = try? Realm() {
                try realm.write {
                    realm.add(obj , update:.all)
                }
            }
        }
        catch(let _error){
            debugPrint(_error)
        }
    }
    
    // 异步保存数据
    //    func addASynModel(_ obj:Object){
    //
    //        DispatchQueue(label: "background").async {
    //            autoreleasepool {
    //
    //                let realm = try! Realm()
    //
    //                realm.beginWrite()
    //
    //                realm.add(obj , update:true)
    //
    //                // 提交写入事务以确保数据在其他线程可用
    //                try! realm.commitWrite()
    //
    //            }
    //        }
    //    }
    
    // 查询数据
    func selectModel<T: Object>(_ type:T.Type ,predicate:NSPredicate?) -> Array<T>{
        let realm = try! Realm()
        
        var objs = Array<Object>()
        
        if(predicate == nil){
            for obj in realm.objects(type) {
                objs.append(obj)
            }
        }else{
            for obj in realm.objects(type).filter(predicate!) {
                objs.append(obj)
            }
        }
        
        return objs as! Array<T>
    }
    
    // 同步删除数据
    func deleteSynModel(_ obj:Object){
        do{
            let realm = try? Realm()
            try realm?.write {
                realm?.delete(obj)
            }
        }
        catch(let _error){
            debugPrint(_error)
        }
    }
    
}
