//
//  IconPicker.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 11/11/2025.
//


import Foundation
import NaturalLanguage

struct IconPicker {
    static let keywordMap: [String: String] = [
        "run": "🏃‍♂️",
        "jog": "🏃‍♂️",
        "walk": "🚶‍♀️",
        "steps": "🚶‍♂️",
        "workout": "🏋️‍♀️",
        "exercise": "🏋️‍♂️",
        "gym": "🏋️",
        "plank": "🧱",
        "pushup": "💪",
        "pullup": "💪",
        "squat": "🏋️",
        "lift": "🏋️‍♂️",
        "swim": "🏊‍♂️",
        "read": "📖",
        "journal": "📓",
        "meal": "🍱",
        "drink": "🥤",
        "sleep": "🛏️",
        "bed": "🛏️",
        "wake": "⏰",
        "alarm": "⏰",
        "clean": "🧹",
        "tidy": "🧹",
        "study": "📚",
        "learn": "📚",
        "practice": "📝",
        "call": "📞",
        "walked": "🚶‍♂️",
        "plants": "🪴",
        "shopping": "🛒",
        "budget": "💰",
        "finance": "💵",
        "floss": "🦷",
        "teeth": "🦷",
        "affirmation": "💭",
        "gratitude": "🙏",
        "planning": "🗓️",
        "goal": "🎯",
        "review": "🔍",
        "cleaning": "🧽",
        "sketch": "✏️",
        "photo": "📸",
        "backup": "💾",
        "coding": "💻",
        "code": "💻",
        "typing": "⌨️",
        "puzzle": "🧩",
        "volunteer": "🤝",
        "stairs": "🪜",
        "networking": "🤝",
        "post": "📬",
        "calligraphy": "✍️",
        "breathing": "💨",
        "visualization": "🖼️",
        "stretching": "🤸‍♀️",
        "mindfulness": "🧘",
        "sketching": "✏️",
        "presentation": "📊",
        "plan": "🗂️",
        "habit": "🔁",
        "tracker": "📈",
        "affirm": "💭",
        "balance": "⚖️",
        "fitness": "🏃‍♂️",
        "wellness": "🧘",
        "energy": "⚡",
        "productivity": "📈",
        "schedule": "🗓️",
        "prepare": "🛠️",
        "celebrate": "🎉",
        "result": "🏆",
        "outcome": "🏆",
        "reviewed": "🔍",
        "goalsetting": "🎯",
        "habitual": "🔁",
        "automatic": "🤖",
        "trigger": "⚡",
        "cue": "⚡",
        "reward": "🏆",
        "success": "🏆",
        "achievement": "🏆",
        "motivation": "🔥",
        "discipline": "💪",
        "streak": "🔥",
        "momentum": "⚡",
        "persist": "💪",
        "focus": "🎯",
        "intentional": "🎯",
        "action": "🏃‍♂️",
        "adapt": "🔄",
        "change": "🔄",
        "transform": "🔄",
        "refine": "🛠️",
        "optimize": "🛠️",
        "reset": "🔄",
        "restart": "🔄",
        "mindset": "🧠",
        "clarity": "💡",
        "simplify": "🧹",
        "system": "⚙️",
        "structure": "🏗️",
        "foundation": "🏗️",
        "habitloop": "🔁",
        "lifestyle": "🏖️",
        "healthy": "🍎",
        "wellbeing": "🧘",
        "growth": "🌱",
        "learning": "📚",
        "knowledge": "📘",
        "career": "💼",
        "project": "📁",
        "task": "📋",
        "challenge": "🏆",
        "experiment": "🔬",
        "reflection": "🪞",
        "journaled": "📓",
        "reading": "📖",
        "swimming": "🏊‍♂️",
        "cycling": "🚴‍♂️",
        "hiking": "🥾",
        "running": "🏃‍♂️",
        "stretch": "🤸‍♂️",
        "meditate": "🧘‍♂️",
        "yoga": "🧘‍♀️",
        "grocery": "🛒",
        "garden": "🪴",
        "cleaned": "🧹",
        "organize": "🗂️",
        "budgeting": "💰",
        "flossing": "🦷",
        "hydration": "🥤",
        "writing": "✍️",
        "drawing": "🎨",
        "piano": "🎹",
        "guitar": "🎸",
        "music": "🎶",
        "dance": "💃",
        "art": "🎨",
        "craft": "🧵",
        "cook": "🍳",
        "baking": "🍰",
        "bake": "🍰",
        "pray": "🙏",
        "meditation": "🧘",
        "relax": "🧘",
        "bible": "📖",
    ]

    static func iconUsingNLP(for title: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType])
        tagger.string = title
        var bestTokens: [String] = []

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther]
        tagger.enumerateTags(in: title.startIndex..<title.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag {
                switch tag {
                case .noun, .verb:
                    let token = String(title[tokenRange]).lowercased()
                    bestTokens.append(token)
                default:
                    break
                }
            }
            return true
        }

        for token in bestTokens {
            if let icon = keywordMap[token] { return icon }
        }
        return icon(for: title)
    }
    
    private static func icon(for title: String) -> String {
        let words = title
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }

        for w in words {
            if let icon = keywordMap[w] { return icon }
        }

        for (k, icon) in keywordMap {
            if words.contains(where: { $0.contains(k) || k.contains($0) }) {
                return icon
            }
        }

        return "➕"
    }
}


