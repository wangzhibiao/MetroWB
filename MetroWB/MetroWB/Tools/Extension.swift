//
//  Extension.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/6/3.
//

import UIKit
import Foundation
import YYText
import AsyncDisplayKit
import Alamofire
import Kingfisher
import SwiftGifOrigin

extension String {
    
    /// 是否是短连接
    var isShortUrl:Bool {
        return self.contains("t.cn/")
    }

    ///获取字符串的宽度
    func getLableWidth(font:UIFont,height:CGFloat) -> CGFloat {
        
        let size = CGSize.init(width: CGFloat(MAXFLOAT), height: height)
        
        let dic = [NSAttributedString.Key.font:font] // swift 4.0
        
        let cString = self.cString(using: String.Encoding.utf8)
        let str = String.init(cString: cString!, encoding: String.Encoding.utf8)
        let strSize = str?.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context:nil).size
        return strSize?.width ?? 0
    }
    
    // 计算带有换行符的字符串高度
    func heightForContent(width: CGFloat,font: UIFont) -> CGFloat {
        
        var txt = self
        txt += "占位符"
        let textView = YYLabel(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        
        let attributeString = NSMutableAttributedString(string: txt)
        
        let size = CGSize.init(width: width, height:  CGFloat(MAXFLOAT))

        attributeString.yy_font = font
        attributeString.yy_kern = ConstFile.status_text_kern as NSNumber
        attributeString.yy_lineSpacing = ConstFile.text_marging
        textView.attributedText = attributeString
        
        let layout = YYTextLayout(containerSize: size, text: attributeString)
        textView.textLayout = layout
        
        return (layout?.textBoundingSize.height)!
    }
   
    /// 根据要求的字符数来添加 “全文”
    mutating func addAllText(maxLength: Int){
        
        var str = self
    
        let splitArray = str.components(separatedBy: "http")
        if splitArray.count == 2 {// 包换链接 要计算出去链接的长度
            if splitArray[0].count > maxLength {
                
                str = String(str.prefix(maxLength - 10))
                str += "...全文"
            }
            
        }else { // 不包含链接 直接计算数量
            if str.count > maxLength {
                str = String(str.prefix(maxLength - 10))
                str += "...全文"
            }
        }
        
        self = str
    }
   
    // 获取评论准发数的格式化
    var formatDesc: String {
        
        var result = self
        
        let num = Int64(self)!
        if num > 99999 {
            result = "10万+"
        }else if num > 9999 {// 保留一位小时 并且不四舍五入
            
            let up = NSDecimalNumberHandler.init(roundingMode: .bankers, scale: 1, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
           
            let temp:Double = Double(num) / 10000.0
            let decNumber = NSDecimalNumber(value: temp)
            let res = decNumber.rounding(accordingToBehavior: up)
            
            result = String(format: "%.1f万", arguments: [res.doubleValue])
        }
        
        return result
    }
    
}


extension Date {
    
    /// 获取新浪时间
    static func sinaDate(string: String) -> Date? {
        // 求出创建时间
        let dateformatter = DateFormatter()
        // Tue May 31 17:46:55 +0800 2011
        dateformatter.dateFormat = "EEE MMM dd HH:mm:ss z yyyy"
        dateformatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let dt = dateformatter.date(from: string)
        return dt
    }
    
    
    var dateDescription: String {
        // 取出当前日历 - 提供了大量的日历相关的操作函数
        let calendar = NSCalendar.current
        /**
         是今年：
         是今天：
         1分钟内：
         刚刚
         1小时内：
         xx分钟前
         其他：
         xx小时前
         是昨天：
         昨天 HH:mm:ss
         其他：
         MM-dd HH:mm:ss
         
         不是今年：
         yyyy-MM-dd HH:mm
         
         */
        var fmt = "yyyy-MM-dd HH:mm"
        if isDateInThisYear(date: self) {
            if calendar.isDateInToday(self) {
                let currentDate = Date()
                // 取当前时间与微博时间的差值
                let result = currentDate.timeIntervalSince(self)
                
                if result > 60 {
                    if result < 60 * 60 {
                        // xx 分钟前
                        return "\(Int(result/60))分钟前"
                    }else {
                        // xx 小时前
                        return "\(Int(result/(60*60)))小时前"
                    }
                }else {
                    return "刚刚"
                }
            }else if calendar.isDateInYesterday(self) {
                fmt = "昨天 HH:mm"
            }else{
                fmt = "MM-dd HH:mm"
            }
        }
        let df = DateFormatter()
        df.locale = NSLocale(localeIdentifier: "en_US") as Locale
        df.dateFormat = fmt
        return df.string(from: self)
    }
    
    /// 判断是否是今年
    ///
    /// - parameter date: 目标时间
    private func isDateInThisYear(date: Date) -> Bool {
        
        // 取到当前时间
        let currentDate = Date()
        // 初始化时间格式化器
        let df = DateFormatter()
        // 指定格式
        df.dateFormat = "yyyy"
        // 格式当前时间与目标时间成字符串
        let currentDateString = df.string(from: currentDate)
        let dateString = df.string(from: date)
        // 对比字符串是否相同
        return (currentDateString as NSString).isEqual(to: dateString)
    }
}


/// 基于NSRegularExpression api 的正则处理工具类
public struct Regex {
    
    private let regularExpression: NSRegularExpression
    
    //使用正则表达式进行初始化
    public init(_ pattern: String, options: Options = []) throws {
        regularExpression = try NSRegularExpression(
            pattern: pattern,
            options: options.toNSRegularExpressionOptions
        )
    }
    
    //正则匹配验证（true表示匹配成功）
    public func matches(_ string: String) -> Bool {
        return firstMatch(in: string) != nil
    }
    
    //获取第一个匹配结果
    public func firstMatch(in string: String) -> Match? {
        let firstMatch = regularExpression
            .firstMatch(in: string, options: [],
                        range: NSRange(location: 0, length: string.utf16.count))
            .map { Match(result: $0, in: string) }
        return firstMatch
    }
    
    //获取所有的匹配结果
    public func matches(in string: String) -> [Match] {
        let matches = regularExpression
            .matches(in: string, options: [],
                     range: NSRange(location: 0, length: string.utf16.count))
            .map { Match(result: $0, in: string) }
        return matches
    }
    
    //正则替换
    public func replacingMatches(in input: String, with template: String,
                                 count: Int? = nil) -> String {
        var output = input
        let matches = self.matches(in: input)
        let rangedMatches = Array(matches[0..<min(matches.count, count ?? .max)])
        for match in rangedMatches.reversed() {
            let replacement = match.string(applyingTemplate: template)
            output.replaceSubrange(match.range, with: replacement)
        }
        
        return output
    }
}

//正则匹配可选项
extension Regex {
    /// Options 定义了正则表达式匹配时的行为
    public struct Options: OptionSet {
        
        //忽略字母
        public static let ignoreCase = Options(rawValue: 1)
        
        //忽略元字符
        public static let ignoreMetacharacters = Options(rawValue: 1 << 1)
        
        //默认情况下,“^”匹配字符串的开始和结束的“$”匹配字符串,无视任何换行。
        //使用这个配置，“^”将匹配的每一行的开始,和“$”将匹配的每一行的结束。
        public static let anchorsMatchLines = Options(rawValue: 1 << 2)
        
        ///默认情况下,"."匹配除换行符(\n)之外的所有字符。使用这个配置，选项将允许“.”匹配换行符
        public static let dotMatchesLineSeparators = Options(rawValue: 1 << 3)
        
        //OptionSet的 raw value
        public let rawValue: Int
        
        //将Regex.Options 转换成对应的 NSRegularExpression.Options
        var toNSRegularExpressionOptions: NSRegularExpression.Options {
            var options = NSRegularExpression.Options()
            if contains(.ignoreCase) { options.insert(.caseInsensitive) }
            if contains(.ignoreMetacharacters) {
                options.insert(.ignoreMetacharacters) }
            if contains(.anchorsMatchLines) { options.insert(.anchorsMatchLines) }
            if contains(.dotMatchesLineSeparators) {
                options.insert(.dotMatchesLineSeparators) }
            return options
        }
        
        //OptionSet 初始化
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

//正则匹配结果
extension Regex {
    // Match 封装有单个匹配结果
    public class Match: CustomStringConvertible {
        //匹配的字符串
        public lazy var string: String = {
            return String(describing: self.baseString[self.range])
        }()
        
        //匹配的字符范围
        public lazy var range: Range<String.Index> = {
            return Range(self.result.range, in: self.baseString)!
        }()
        
        //正则表达式中每个捕获组匹配的字符串
        public lazy var captures: [String?] = {
            let captureRanges = stride(from: 0, to: result.numberOfRanges, by: 1)
                .map(result.range)
                .dropFirst()
                .map { [unowned self] in
                    Range($0, in: self.baseString)
            }
            
            return captureRanges.map { [unowned self] captureRange in
                if let captureRange = captureRange {
                    return String(describing: self.baseString[captureRange])
                }
                
                return nil
            }
        }()
        
        private let result: NSTextCheckingResult
        
        private let baseString: String
        
        //初始化
        internal init(result: NSTextCheckingResult, in string: String) {
            precondition(
                result.regularExpression != nil,
                "NSTextCheckingResult必需使用正则表达式"
            )
            
            self.result = result
            self.baseString = string
        }
        
        //返回一个新字符串，根据“模板”替换匹配的字符串。
        public func string(applyingTemplate template: String) -> String {
            let replacement = result.regularExpression!.replacementString(
                for: result,
                in: baseString,
                offset: 0,
                template: template
            )
            
            return replacement
        }
        
        //藐视信息
        public var description: String {
            return "Match<\"\(string)\">"
        }
    }
}


extension NSAttributedString {
    
    func attributesStringWith(font: UIFont, color: UIColor, kern: NSNumber, lineSpace: CGFloat)-> NSMutableAttributedString{
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace     //设置行间距
        //        paragraphStyle.firstLineHeadIndent = 40     //首行缩进距离
        //        paragraphStyle.headIndent = 50     //文本每一行的缩进距离
        //        paragraphStyle.tailIndent = 20  //文本行末缩进距离
        paragraphStyle.alignment = .justified      //文本对齐方向
        
        let attributeString = NSMutableAttributedString(attributedString: self)
        attributeString.addAttributes([NSAttributedString.Key.font : font], range: NSRange(location: 0, length: attributeString.length))
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor : color], range: NSRange(location: 0, length: attributeString.length))
        attributeString.addAttributes([NSAttributedString.Key.kern : kern], range: NSRange(location: 0, length: attributeString.length))
        
        attributeString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributeString.length))
        
        return attributeString
    }
}

extension String {
    
    func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16), let to = range.upperBound.samePosition(in: utf16) else {
            return NSMakeRange(0, 0)
        }
        return NSMakeRange(utf16.distance(from: utf16.startIndex, to: from), utf16.distance(from: from, to: to))
    }
    
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
    
    func attributesStringWith(font: UIFont, color: UIColor, kern: NSNumber, lineSpace: CGFloat)-> NSMutableAttributedString{
        
        let string = NSAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace     //设置行间距
        //        paragraphStyle.firstLineHeadIndent = 40     //首行缩进距离
        //        paragraphStyle.headIndent = 50     //文本每一行的缩进距离
        //        paragraphStyle.tailIndent = 20  //文本行末缩进距离
        paragraphStyle.alignment = .justified      //文本对齐方向
        
        let attributeString = NSMutableAttributedString(attributedString: string)
        attributeString.addAttributes([NSAttributedString.Key.font : font], range: NSRange(location: 0, length: attributeString.length))
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor : color], range: NSRange(location: 0, length: attributeString.length))
        attributeString.addAttributes([NSAttributedString.Key.kern : kern], range: NSRange(location: 0, length: attributeString.length))
        
        attributeString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributeString.length))
        
        return attributeString
    }
}


// 颜色分类
extension UIColor {
    
    func toImage(viewSize: CGSize) -> UIImage{
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(self.cgColor)
        
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsGetCurrentContext()
        
        return image!
        
    }
}

/// 给ASDK 增加tag属性
extension ASDisplayNode {
    
    private struct ASTagKey {
        static var tag: String = "tag"
    }
    
    public var tag: Int {
        get {
            return objc_getAssociatedObject(self, &ASTagKey.tag) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &ASTagKey.tag, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}



extension UIView {
    
    var ASNode: ASDisplayNode {
        return ASDisplayNode(viewBlock: { () -> UIView in
            return self
        })
    }
}

extension URL {
    func downloadImage(completion: @escaping (UIImage?) -> Void) {
        let request = URLRequest(url: self)
        Alamofire.request(request).responseData { response in
            
                let isGIF = self.absoluteString.contains(".gif")
            
                let image = response.data.flatMap(isGIF ? UIImage.gif : UIImage.init)
            completion(image)
        }
    }
}
