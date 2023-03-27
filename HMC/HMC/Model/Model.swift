//
//  Model.swift
//  HMC
//
//  Created by 김경호 on 2023/03/27.
// SQL Lite 사용
// NoSQL이 읽는 속도가 더 빠르기 때문에 사용. SQLite는 내장
//

import Foundation
import SQLite3
import SwiftUI

class Model{
    
    func firstStart() -> Bool{
        if UserDefaults.standard.bool(forKey: "FirstStart"){
            return true
        } else {
            @AppStorage("FirstStart") var firstBool: Bool = true
            
            return false
        }
    }
    
    
    func initDB(){
        
//        let fileManger = FileManager() // 파일 매니저 객체 생성
//        let docPathURL =
    }
    
}

class DBHelper {
    static let dbHelper = DBHelper()
    
    var db: OpaquePointer? // db를 가리키는 포인터
    // db 이름은 항상 "DB이름.sqlite" 형식으로 해줄 것.
    var path = "hmcdb.sqlite"
    
    init(){
        self.db = createDB()
    }
    
    // DB생성
    func createDB() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        do{
            let filePath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path)
            
            // 파일경로에 있는 데이터 베이스와 연결
            // 없으면 생성, 있으면 넘어감
            if sqlite3_open(filePath.path, &db) == SQLITE_OK {
                print("Succesfully create Database path : \(filePath.path)")
                return db
            }
        }
        catch{
            print("error in createDB")
        }
        print("error in createDB - sqlite3_open")
        return nil
    }
    
    // 테이블 생성
    func createTable(){
        let query = "create table if not exists record (id INTEGER primary key autoincrement, recordData text)"
        var statement: OpaquePointer? = nil
        
        // sqlite3_prepare_v2는 sqlite의 명령어를 수행
        // 위에서 생성한 DB의 주소에 query를 어디까지 읽을 것인지 check -1 == 전체를 읽는다.
        // 그 명령어를 수행하는 DB의 주소를 statement에 넣게 된다.
        // 그리고 확인 떨어지면 sqlite_step을 통해 명령 수행 완료 여부를 확인
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("Create Table Success")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Create Table step fail : \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("error: create table sqlite3 prepare fail")
        }
        
        // sqlite3를 수행하면서 생긴 메모리를 제거
        sqlite3_finalize(statement)
    }
    
    func deleteTable(){
        let query = "DROP Table record"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("Delete Table SuccessFully \(String(describing: db))")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("\n Delete Table step fail : \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\n delete Table prepare fail : \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
    }
    
    func insertDate(_ recordDate: Info){
        
        let query = "insert into record (id, recordData) values (?,?);"
        var statement: OpaquePointer? = nil
        
        do{
            // 데이터를 인코딩 & String으로 변환
            let data = try JSONEncoder().encode(recordDate)
            let dataToString = String(data: data, encoding: .utf8)
            
            print(dataToString!)
            
            if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
                sqlite3_bind_text(statement, 2, NSString(string: dataToString!).utf8String, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_DONE{
                    print("Insert data SuccessFully : \(String(describing: db))")
                } else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    print("\n insert Data sqlite3 step fail : \(errorMessage)")
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("\n insert Data prepare fail : \(errorMessage)")
            }
            
            sqlite3_finalize(statement)
        } catch{
            print("JSONEncoder Error : \(error.localizedDescription)")
        }
    }
}

struct Info: Codable{
    let date: String
    let position: String
}
