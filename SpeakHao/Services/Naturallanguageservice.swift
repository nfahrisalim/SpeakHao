//
//  Naturallanguageservice.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/4/26.
//
import Foundation
import NaturalLanguage

struct LanguageAnalysisResult {
    let detectedLanguage: String?      // e.g. "zh-Hans", "en"
    let isChinese: Bool
    let tokens: [String]               // Tokenized words/characters
    let isRelevantToContext: Bool      // Whether response touches the expected topic
    let sentiment: SentimentType        // Emotional tone
}

enum SentimentType {
    case positive    // Happy, satisfied, cooperative
    case neutral     // Normal response
    case negative    // Frustrated, angry, rude
    case confused    // Off-topic or unclear
}

class NaturalLanguageService {

    private let languageRecognizer = NLLanguageRecognizer()

    // MARK: - Language Detection

    func detectLanguage(in text: String) -> String? {
        languageRecognizer.reset()
        languageRecognizer.processString(text)
        return languageRecognizer.dominantLanguage?.rawValue
    }

    // MARK: - Tokenization

    func tokenize(_ text: String, language: NLLanguage = NLLanguage("zh-Hans")) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.setLanguage(language)
        tokenizer.string = text

        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let token = String(text[range]).trimmingCharacters(in: .whitespaces)
            if !token.isEmpty {
                tokens.append(token)
            }
            return true
        }
        return tokens
    }

    // MARK: - Number Extraction
    
    func extractNumbers(from text: String) -> [String] {
        let pattern = "[0-9]+|零|一|二|三|四|五|六|七|八|九|十|百|千|万|兆|两"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        
        return matches.compactMap { match -> String? in
            if let range = Range(match.range, in: text) {
                return String(text[range])
            }
            return nil
        }
    }

    // MARK: - Sentiment Analysis
    
    func detectSentiment(in text: String) -> SentimentType {
        let lower = text.lowercased()
        
        let negativeKeywords = [
            "草你妈", "cao ni ma", "傻", "stupid", "蠢", "dumb", "烦", "烦死了",
            "滚", "fuck", "shit", "damn", "去死", "die", "垃圾", "garbage",
            "你妈", "bastard", "操", "烦你", "讨厌", "hate"
        ]
        
        let positiveKeywords = [
            "好", "好的", "很好", "太好了", "谢谢", "谢谢你", "可以", "行", "可以啊",
            "great", "good", "thank", "thanks", "perfect", "ok", "sure", "happy",
            "很开心", "开心", "高兴", "满意", "非常满意"
        ]
        
        let hasNegative = negativeKeywords.contains { lower.contains($0) }
        let hasPositive = positiveKeywords.contains { lower.contains($0) }
        
        if hasNegative {
            return .negative
        } else if hasPositive {
            return .positive
        } else if lower.isEmpty || lower.count < 2 {
            return .confused
        } else {
            return .neutral
        }
    }
    
    func extractTimelineKeywords(from text: String) -> [String] {
        let timelineKeywords = [
            "天", "天", "日", "周", "月", "年", "小时", "分钟", "秒",
            "day", "days", "week", "weeks", "month", "months", "year", "years",
            "hour", "hours", "minute", "minutes", "second", "seconds",
            "hari", "minggu", "bulan", "tahun", "jam"
        ]
        
        var found: [String] = []
        let lower = text.lowercased()
        
        for keyword in timelineKeywords {
            if lower.contains(keyword) {
                found.append(keyword)
            }
        }
        
        return found
    }

    // MARK: - Full Analysis

    func analyze(userText: String, expectedKeywords: [String] = []) -> LanguageAnalysisResult {
        let detectedLang = detectLanguage(in: userText)
        let isChinese = detectedLang?.hasPrefix("zh") ?? false

        let language: NLLanguage = isChinese ? NLLanguage("zh-Hans") : NLLanguage("en")
        let tokens = tokenize(userText, language: language)

        let loweredText = userText.lowercased()
        let isRelevant: Bool
        if expectedKeywords.isEmpty {
            isRelevant = true
        } else {
            isRelevant = expectedKeywords.contains(where: { loweredText.contains($0.lowercased()) })
        }
        
        let sentiment = detectSentiment(in: userText)

        return LanguageAnalysisResult(
            detectedLanguage: detectedLang,
            isChinese: isChinese,
            tokens: tokens,
            isRelevantToContext: isRelevant,
            sentiment: sentiment
        )
    }
}
